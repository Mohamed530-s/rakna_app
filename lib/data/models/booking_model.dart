import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String mallName;
  final String mallId;
  final DateTime timestamp;
  final double price;
  final int duration;
  final double totalPrice;
  final String status;
  final String cardUsed;

  BookingModel({
    required this.id,
    required this.userId,
    required this.mallName,
    required this.mallId,
    required this.timestamp,
    required this.price,
    required this.duration,
    required this.totalPrice,
    required this.status,
    required this.cardUsed,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedTimestamp;
    try {
      final raw = data['timestamp'] ?? data['date'];
      if (raw is Timestamp) {
        parsedTimestamp = raw.toDate();
      } else if (raw is int) {
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(raw);
      } else {
        parsedTimestamp = DateTime.now();
      }
    } catch (_) {
      parsedTimestamp = DateTime.now();
    }

    final double basePrice = (data['price'] as num?)?.toDouble() ?? 0.0;
    final double total = (data['totalPrice'] as num?)?.toDouble() ?? basePrice;

    return BookingModel(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      mallName: (data['mallName'] as String?) ?? 'Unknown Mall',
      mallId: (data['mallId'] as String?) ?? '',
      timestamp: parsedTimestamp,
      price: basePrice,
      duration: (data['duration'] as int?) ?? 1,
      totalPrice: total,
      status: (data['status'] as String?) ?? 'ACTIVE',
      cardUsed: (data['cardUsed'] as String?) ?? 'Cash on Arrival',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mallName': mallName,
      'mallId': mallId,
      'timestamp': Timestamp.fromDate(timestamp),
      'price': price,
      'duration': duration,
      'totalPrice': totalPrice,
      'status': status,
      'cardUsed': cardUsed,
    };
  }

  String get statusDisplay => status.toUpperCase();
}
