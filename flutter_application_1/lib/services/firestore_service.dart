import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coach.dart';

class FirestoreService {
  final CollectionReference _coachesCollection =
      FirebaseFirestore.instance.collection('coaches');

  Future<List<Coach>> getCoaches() async {
    try {
      final snapshot = await _coachesCollection.get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) =>
                Coach.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      } else {
        
        return _getMockCoaches();
      }
    } catch (e) {
      print("Error fetching coaches: $e");
     
      return _getMockCoaches();
    }
  }

  Future<void> uploadMockData() async {
    final mockCoaches = _getMockCoaches();
    for (var coach in mockCoaches) {
     
      final data = coach.toMap();
     
     
      await _coachesCollection.doc(coach.id).set(data);
    }
  }

  List<Coach> _getMockCoaches() {
    return [
      Coach(
        id: '1',
        name: 'Mike "Iron" Tyson',
        specialty: 'Power Boxing & Defense',
        experience: '20+ Years Pro',
        certifications: ['Pro Boxing Hall of Fame', 'Certified Master Trainer'],
        achievements: ['Former Heavyweight Champion', '50 Wins (44 KOs)'],
        imageUrl: 'assets/miketyson.jpeg',
        videoUrl: 'assets/heavy_bag.mp4', 
        rating: 5.0,
        price: '\$50/session',
        latitude: 40.7128,
        longitude: -74.0060,
        address: 'New York, NY',
      ),
      Coach(
        id: '2',
        name: 'Sarah "The Swift"',
        specialty: 'Speed & Agility',
        experience: '10 Years',
        certifications: ['NASM Certified', 'Olympic Boxing Coach'],
        achievements: ['National Golden Gloves Winner'],
        imageUrl: 'https://img.freepik.com/free-photo/portrait-female-boxer-posing_23-2148888448.jpg',
        videoUrl: 'assets/heavy_bag.mp4', 
        rating: 4.8,
        price: '\$40/session',
        latitude: 40.7589,
        longitude: -73.9851,
        address: 'Manhattan, NY',
      ),
      Coach(
        id: '3',
        name: 'Coach Leon',
        specialty: 'Endurance & Cardio',
        experience: '8 Years',
        certifications: ['CrossFit Level 3', 'Boxing Conditioning Specialist'],
        achievements: ['Marathon Runner', 'Pro MMA Fighter'],
        imageUrl: 'https://img.freepik.com/free-photo/boxer-man-posing-gym_23-2147983960.jpg',
        videoUrl: 'assets/heavy_bag.mp4',
        rating: 4.9,
        price: '\$45/session',
        latitude: 40.6782,
        longitude: -73.9442,
        address: 'Brooklyn, NY',
      ),
    ];
  }
}
