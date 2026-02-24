import '../entities/parking_spot.dart';

abstract class ParkingRepository {
  Stream<List<ParkingSpot>> getParkingSpots();
  Future<void> updateSpotStatus(ParkingSpot spot, String newStatus);
  Future<bool> isUserWithinRange(double lat, double lng, double rangeInMeters);
}
