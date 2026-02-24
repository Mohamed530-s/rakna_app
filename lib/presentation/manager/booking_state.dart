import 'package:equatable/equatable.dart';
import 'package:rakna_app/data/models/booking_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final List<BookingModel> bookings;
  const BookingSuccess(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingCreated extends BookingState {
  final BookingModel booking;
  const BookingCreated(this.booking);
  @override
  List<Object?> get props => [booking];
}

class BookingCancelled extends BookingState {
  final String bookingId;
  const BookingCancelled(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
