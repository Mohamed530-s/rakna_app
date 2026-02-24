import 'package:equatable/equatable.dart';
import 'package:rakna_app/domain/entities/parking_spot.dart';

abstract class ParkingState extends Equatable {
  const ParkingState();

  @override
  List<Object> get props => [];
}

class ParkingInitial extends ParkingState {}

class ParkingLoading extends ParkingState {}

class ParkingLoaded extends ParkingState {
  final List<ParkingSpot> spots;
  const ParkingLoaded(this.spots);
  @override
  List<Object> get props => [spots];
}

class ParkingError extends ParkingState {
  final String message;
  const ParkingError(this.message);
  @override
  List<Object> get props => [message];
}

class ParkingUpdating extends ParkingState {}
