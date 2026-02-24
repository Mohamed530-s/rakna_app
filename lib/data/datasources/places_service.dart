import 'package:rakna_app/domain/entities/parking_spot.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class PlacesService {
  PlacesService();

  Future<List<ParkingSpot>> getNearbyMalls(double lat, double lng,
      {int radius = 50000}) async {
    final List<Map<String, dynamic>> localMalls = [
      {
        'id': 'mall_citystars',
        'name': 'City Stars Mall',
        'lat': 30.0733,
        'lng': 31.3458,
        'address': 'Omar Ibn El Khattab St, Heliopolis',
        'image':
            'https://images.unsplash.com/photo-1519567241046-7f570eee3ce6?w=800&q=80',
        'rating': 4.7,
      },
      {
        'id': 'mall_arabia',
        'name': 'Mall of Arabia',
        'lat': 30.0075,
        'lng': 31.0000,
        'address': '26th of July Corridor, 6th of October',
        'image':
            'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800&q=80',
        'rating': 4.5,
      },
      {
        'id': 'mall_cfc',
        'name': 'Cairo Festival City',
        'lat': 30.0308,
        'lng': 31.4089,
        'address': 'Ring Road, New Cairo',
        'image':
            'https://images.unsplash.com/photo-1581783898377-1c85bf937427?w=800&q=80',
        'rating': 4.8,
      },
      {
        'id': 'mall_egypt',
        'name': 'Mall of Egypt',
        'lat': 29.9735,
        'lng': 31.0181,
        'address': 'Wahat Road, 6th of October',
        'image':
            'https://images.unsplash.com/photo-1519567241046-7f570eee3ce6?w=800&q=80',
        'rating': 4.6,
      },
      {
        'id': 'mall_arkan',
        'name': 'Arkan Plaza',
        'lat': 30.0469,
        'lng': 30.9164,
        'address': 'El Sheikh Zayed',
        'image':
            'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&q=80',
        'rating': 4.9,
      }
    ];

    final random = Random();
    List<ParkingSpot> spots = [];

    for (var mall in localMalls) {
      final double distance = Geolocator.distanceBetween(
        lat,
        lng,
        mall['lat'],
        mall['lng'],
      );

      final int totalSpots = 50 + random.nextInt(100);
      final int availableSpots = random.nextInt(totalSpots);
      final bool isAvailable = availableSpots > 5;

      spots.add(ParkingSpot(
        id: mall['id'],
        label: mall['name'],
        latitude: mall['lat'],
        longitude: mall['lng'],
        status: isAvailable ? 'available' : 'occupied',
        lastUpdated: DateTime.now(),
        distanceInMeters: distance,
        address: mall['address'],
        rating: mall['rating'],
        imageUrl: mall['image'],
        estimatedFreeTime: isAvailable
            ? null
            : DateTime.now().add(const Duration(minutes: 45)),
      ));
    }

    spots.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

    return spots;
  }
}
