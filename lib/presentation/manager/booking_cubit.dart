import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rakna_app/presentation/manager/booking_state.dart';
import 'package:rakna_app/data/models/booking_model.dart';

class BookingCubit extends Cubit<BookingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BookingCubit() : super(BookingInitial());

  Future<void> createBooking({
    required String mallId,
    required String mallName,
    required double basePrice,
    required int duration,
    required double totalPrice,
    required String cardUsed,
  }) async {
    if (isClosed) return;
    emit(BookingLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final mallRef = _firestore.collection('malls').doc(mallId);
      final bookingsRef =
          _firestore.collection('users').doc(user.uid).collection('bookings');

      final result = await _firestore.runTransaction((transaction) async {
        final mallSnapshot = await transaction.get(mallRef);

        if (!mallSnapshot.exists) {
          transaction.set(mallRef, {
            'name': mallName,
            'spots': 49,
            'location': const GeoPoint(0, 0),
            'api_id': mallId,
          });
        } else {
          final currentSpots = (mallSnapshot.data()?['spots'] as int?) ?? 0;
          if (currentSpots <= 0) {
            throw Exception("Full Capacity");
          }
          transaction.update(mallRef, {'spots': currentSpots - 1});
        }

        final newBookingRef = bookingsRef.doc();
        final ticketData = {
          'userId': user.uid,
          'mallId': mallId,
          'mallName': mallName,
          'timestamp': FieldValue.serverTimestamp(),
          'duration': duration,
          'price': basePrice,
          'totalPrice': totalPrice,
          'status': 'ACTIVE',
          'cardUsed': cardUsed,
          'createdAt': FieldValue.serverTimestamp(),
        };

        transaction.set(newBookingRef, ticketData);
        return newBookingRef.id;
      });

      if (isClosed) return;
      emit(BookingCreated(BookingModel(
        id: result,
        userId: user.uid,
        mallId: mallId,
        mallName: mallName,
        timestamp: DateTime.now(),
        price: basePrice,
        duration: duration,
        totalPrice: totalPrice,
        status: 'ACTIVE',
        cardUsed: cardUsed,
      )));

      await fetchBookings();
    } catch (e) {
      if (isClosed) return;
      emit(BookingError(e.toString()));
    }
  }

  Future<void> fetchBookings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (!isClosed) emit(BookingInitial());
        return;
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookings')
          .orderBy('timestamp', descending: true)
          .get();

      final bookings = <BookingModel>[];
      for (final doc in querySnapshot.docs) {
        try {
          bookings.add(BookingModel.fromFirestore(doc));
        } catch (_) {}
      }

      if (isClosed) return;
      emit(BookingSuccess(bookings));
    } catch (e) {
      if (isClosed) return;
      emit(BookingError(e.toString()));
    }
  }

  Future<void> cancelBooking(String bookingId, String mallId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final bookingRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookings')
          .doc(bookingId);
      final mallRef = _firestore.collection('malls').doc(mallId);

      await _firestore.runTransaction((transaction) async {
        final bookingSnapshot = await transaction.get(bookingRef);
        final mallSnapshot = await transaction.get(mallRef);

        if (!bookingSnapshot.exists) throw Exception("Booking not found");

        final status = bookingSnapshot.data()?['status'] as String?;
        if (status?.toUpperCase() != 'ACTIVE') {
          throw Exception("Booking is not active");
        }

        transaction.update(bookingRef, {'status': 'CANCELLED'});

        if (mallSnapshot.exists) {
          final currentSpots = (mallSnapshot.data()?['spots'] as int?) ?? 0;
          transaction.update(mallRef, {'spots': currentSpots + 1});
        }
      });

      if (isClosed) return;
      emit(const BookingCancelled("Booking cancelled successfully"));
      await fetchBookings();
    } catch (e) {
      if (isClosed) return;
      emit(BookingError("Cancellation failed: $e"));
    }
  }

  Future<Map<String, dynamic>> verifyAccess(String bookingId) async {
    try {
      final query = await _firestore
          .collectionGroup('bookings')
          .where(FieldPath.documentId, isEqualTo: bookingId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return {'valid': false, 'message': 'Invalid Ticket'};
      }

      final bookingRef = query.docs.first.reference;

      final result = await _firestore.runTransaction((transaction) async {
        final bookingSnapshot = await transaction.get(bookingRef);

        if (!bookingSnapshot.exists) {
          return {'valid': false, 'message': 'Invalid Ticket'};
        }

        final data = bookingSnapshot.data();
        final status = (data?['status'] as String?)?.toUpperCase();

        if (status == 'ACTIVE') {
          transaction.update(bookingRef, {'status': 'COMPLETED'});
          return {'valid': true, 'message': 'Access Granted'};
        } else if (status == 'COMPLETED') {
          return {'valid': false, 'message': 'Already Used'};
        } else {
          return {'valid': false, 'message': 'Invalid Ticket'};
        }
      });

      return result;
    } catch (e) {
      return {'valid': false, 'message': 'Error: $e'};
    }
  }
}
