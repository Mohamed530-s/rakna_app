import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parking_spot_model.dart';

abstract class ParkingRemoteDataSource {
  Stream<List<ParkingSpotModel>> getParkingSpots();
  Future<void> updateSpotStatus(String spotId, String status);
}

class ParkingRemoteDataSourceImpl implements ParkingRemoteDataSource {
  final FirebaseFirestore firestore;

  ParkingRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<ParkingSpotModel>> getParkingSpots() {
    return firestore.collection('malls').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final geo = data['location'] as GeoPoint;
        final spots = (data['spots'] ?? 0) as int;

        return ParkingSpotModel(
          id: doc.id,
          label: data['name'] ?? 'Unknown Mall',
          latitude: geo.latitude,
          longitude: geo.longitude,
          status: spots > 0 ? 'available' : 'occupied',
          lastUpdated: DateTime.now(),
          estimatedFreeTime: null,
        );
      }).toList();
    });
  }

  @override
  Future<void> updateSpotStatus(String spotId, String status) async {
    final docRef = firestore.collection('malls').doc(spotId);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentSpots = (doc.data()?['spots'] ?? 0) as int;
      if (status == 'occupied') {
        if (currentSpots > 0) {
          await docRef.update({'spots': currentSpots - 1});
        }
      } else {
        await docRef.update({'spots': currentSpots + 1});
      }
    }
  }
}
