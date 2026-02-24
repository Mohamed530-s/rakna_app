import 'package:geolocator/geolocator.dart';

import 'package:rakna_app/data/datasources/remote_datasource.dart';
import 'package:rakna_app/domain/entities/parking_spot.dart';
import 'package:rakna_app/domain/repositories/parking_repository.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingRemoteDataSource _remoteDataSource;

  ParkingRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<ParkingSpot>> getParkingSpots() {
    return _remoteDataSource.getParkingSpots();
  }

  @override
  Future<void> updateSpotStatus(ParkingSpot spot, String status) {
    return _remoteDataSource.updateSpotStatus(spot.id, status);
  }

  @override
  Future<bool> isUserWithinRange(
      double lat, double lng, double rangeInMeters) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    Position position = await Geolocator.getCurrentPosition();
    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      lat,
      lng,
    );

    return distanceInMeters <= rangeInMeters;
  }
}
