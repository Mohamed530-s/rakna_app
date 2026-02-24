import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:rakna_app/domain/usecases/get_parking_spots_usecase.dart';
import 'package:rakna_app/domain/usecases/update_spot_status_usecase.dart';
import 'package:rakna_app/presentation/manager/parking_state.dart';
import 'package:rakna_app/domain/entities/parking_spot.dart';
import 'package:rakna_app/data/datasources/places_service.dart';

class ParkingCubit extends Cubit<ParkingState> {
  final GetParkingSpotsUseCase getParkingSpotsUseCase;
  final UpdateSpotStatusUseCase updateSpotStatusUseCase;

  final PlacesService _placesService = PlacesService();
  StreamSubscription? _subscription;

  ParkingCubit({
    required this.getParkingSpotsUseCase,
    required this.updateSpotStatusUseCase,
  }) : super(ParkingInitial());

  Future<void> fetchNearbyMalls(double lat, double lng) async {
    emit(ParkingLoading());
    try {
      final spots = await _placesService.getNearbyMalls(lat, lng);
      emit(ParkingLoaded(spots));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  void startFirestoreListening() {
    _subscription?.cancel();
    _subscription = getParkingSpotsUseCase.execute().listen(
      (spots) {
        emit(ParkingLoaded(spots));
      },
      onError: (error) {
        emit(ParkingError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> updateStatus(ParkingSpot spot, String newStatus) async {
    try {
      await updateSpotStatusUseCase.execute(spot, newStatus);
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }
}
