import '../repositories/parking_repository.dart';
import '../entities/parking_spot.dart';

class UpdateSpotStatusUseCase {
  final ParkingRepository _repository;

  UpdateSpotStatusUseCase(this._repository);

  Future<void> execute(ParkingSpot spot, String status,
      {double requiredRange = 30.0}) async {
    final bool inRange = await _repository.isUserWithinRange(
        spot.latitude, spot.longitude, requiredRange);
    if (!inRange) {
      throw Exception('Not within range');
    }
    await _repository.updateSpotStatus(spot, status);
  }
}
