import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rakna_app/domain/usecases/get_parking_spots_usecase.dart';
import 'package:rakna_app/domain/usecases/update_spot_status_usecase.dart';
import 'package:rakna_app/presentation/manager/parking_state.dart';
import 'package:rakna_app/domain/entities/parking_spot.dart';

class ParkingCubit extends Cubit<ParkingState> {
  final GetParkingSpotsUseCase getParkingSpotsUseCase;
  final UpdateSpotStatusUseCase updateSpotStatusUseCase;

  ParkingCubit({
    required this.getParkingSpotsUseCase,
    required this.updateSpotStatusUseCase,
  }) : super(ParkingInitial()) {
    _startListening();
  }

  void _startListening() {
    emit(ParkingLoading());
    getParkingSpotsUseCase.execute().listen(
      (spots) {
        emit(ParkingLoaded(spots));
      },
      onError: (error) {
        emit(ParkingError(error.toString()));
      },
    );
  }

  Future<void> updateStatus(ParkingSpot spot, String newStatus) async {
    try {
      await updateSpotStatusUseCase.execute(spot, newStatus);
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }
}
