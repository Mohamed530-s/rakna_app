import '../repositories/parking_repository.dart';
import '../entities/parking_spot.dart';

class GetParkingSpotsUseCase {
  final ParkingRepository _repository;

  GetParkingSpotsUseCase(this._repository);

  Stream<List<ParkingSpot>> execute() {
    return _repository.getParkingSpots();
  }
}
