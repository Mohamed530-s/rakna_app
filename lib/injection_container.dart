import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'package:rakna_app/data/datasources/remote_datasource.dart';
import 'package:rakna_app/data/datasources/seeding_service.dart';
import 'package:rakna_app/data/repositories/parking_repository_impl.dart';
import 'package:rakna_app/domain/repositories/parking_repository.dart';
import 'package:rakna_app/domain/usecases/get_parking_spots_usecase.dart';
import 'package:rakna_app/domain/usecases/update_spot_status_usecase.dart';
import 'package:rakna_app/presentation/manager/auth_cubit.dart';
import 'package:rakna_app/presentation/manager/booking_cubit.dart';
import 'package:rakna_app/presentation/manager/parking_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(
    () => ParkingCubit(
      getParkingSpotsUseCase: sl(),
      updateSpotStatusUseCase: sl(),
    ),
  );

  sl.registerFactory(() => AuthCubit());
  sl.registerFactory(() => BookingCubit());

  sl.registerLazySingleton(() => GetParkingSpotsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSpotStatusUseCase(sl()));

  sl.registerLazySingleton<ParkingRepository>(
    () => ParkingRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<ParkingRemoteDataSource>(
    () => ParkingRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton(() => SeedingService(firestore: sl()));

  final firestore = FirebaseFirestore.instance;
  sl.registerLazySingleton(() => firestore);
}
