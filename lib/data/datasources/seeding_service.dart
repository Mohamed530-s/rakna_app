import 'package:cloud_firestore/cloud_firestore.dart';

class SeedingService {
  final FirebaseFirestore firestore;

  SeedingService({required this.firestore});

  Future<void> seedMalls() async {
    final mallsCollection = firestore.collection('malls');
    final snapshot = await mallsCollection.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final malls = [
      {
        'name': 'City Stars',
        'location': const GeoPoint(30.0733, 31.3458),
        'price': 20,
        'spots': 1500,
        'image':
            'https://images.unsplash.com/photo-1565514020125-69b55f524d7c?q=80&w=1000'
      },
      {
        'name': 'Mall of Arabia',
        'location': const GeoPoint(30.0074, 30.9733),
        'price': 25,
        'spots': 900,
        'image':
            'https://images.unsplash.com/photo-1519567241046-7f570eee3d9f?q=80&w=1000'
      },
      {
        'name': 'Cairo Festival City',
        'location': const GeoPoint(30.0298, 31.4087),
        'price': 30,
        'spots': 600,
        'image':
            'https://images.unsplash.com/photo-1555664424-778a69022365?q=80&w=1000'
      },
      {
        'name': 'Mall of Egypt',
        'location': const GeoPoint(29.9735, 31.0181),
        'price': 25,
        'spots': 800,
        'image':
            'https://images.unsplash.com/photo-1519567241046-7f570eee3ce6?w=800&q=80'
      },
    ];

    for (var mall in malls) {
      await mallsCollection.add(mall);
    }
  }
}
