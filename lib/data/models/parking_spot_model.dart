import '../../domain/entities/parking_spot.dart';

class ParkingSpotModel extends ParkingSpot {
  const ParkingSpotModel({
    required super.id,
    required super.latitude,
    required super.longitude,
    required super.label,
    required super.status,
    required super.lastUpdated,
    super.estimatedFreeTime,
  });

  factory ParkingSpotModel.fromMap(String id, Map<String, dynamic> data) {
    return ParkingSpotModel(
      id: id,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      label: data['label'] ?? 'Unknown',
      status: data['status'] ?? 'available',
      lastUpdated: (data['lastUpdated'] as dynamic)?.toDate() ?? DateTime.now(),
      estimatedFreeTime: (data['estimatedFreeTime'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'label': label,
      'status': status,
      'lastUpdated': lastUpdated,
      'estimatedFreeTime': estimatedFreeTime,
    };
  }
}
