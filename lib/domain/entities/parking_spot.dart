class ParkingSpot {
  final String id;
  final double latitude;
  final double longitude;
  final String label;
  final String status;
  final DateTime lastUpdated;
  final DateTime? estimatedFreeTime;
  final String address;
  final double rating;
  final String imageUrl;
  final double distanceInMeters;

  const ParkingSpot({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.status,
    required this.lastUpdated,
    this.estimatedFreeTime,
    this.address = '',
    this.rating = 0.0,
    this.imageUrl = '',
    this.distanceInMeters = 0.0,
  });
}
