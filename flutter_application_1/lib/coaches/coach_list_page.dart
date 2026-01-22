import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/coach.dart';
import '../services/firestore_service.dart';
import '../services/admin_service.dart';
import '../services/location_service.dart';
import 'coach_detail_page.dart';

class CoachListPage extends StatefulWidget {
  const CoachListPage({super.key});

  @override
  State<CoachListPage> createState() => _CoachListPageState();
}

class _CoachListPageState extends State<CoachListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AdminService _adminService = AdminService();
  final LocationService _locationService = LocationService();
  late Future<List<Coach>> _coachesFuture;
  bool _isAdmin = false;
  Position? _userPosition;
  bool _locationPermissionGranted = false;
  String _sortBy = 'distance'; // 'distance', 'rating', 'price'

  @override
  void initState() {
    super.initState();
    _coachesFuture = _firestoreService.getCoaches();
    _checkAdmin();
    _requestLocation();
  }

  Future<void> _checkAdmin() async {
    final isAdmin = await _adminService.isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  Future<void> _requestLocation() async {
    final hasPermission = await _locationService.requestLocationPermission();
    if (hasPermission) {
      final position = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _userPosition = position;
          _locationPermissionGranted = position != null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'Select Your Coach',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1F38),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            tooltip: 'Sort Coaches',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              if (_locationPermissionGranted)
                const PopupMenuItem(
                  value: 'distance',
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('Distance'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Rating'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'price',
                child: Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Price'),
                  ],
                ),
              ),
            ],
          ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              tooltip: "Upload Mock Data",
              onPressed: () async {
                await _firestoreService.uploadMockData();
                setState(() {
                  _coachesFuture = _firestoreService.getCoaches();
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mock data uploaded!")),
                  );
                }
              },
            )
        ],
      ),
      body: FutureBuilder<List<Coach>>(
        future: _coachesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No coaches available.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          // Create a mutable list for sorting
          List<Coach> coaches = List.from(snapshot.data!);

          // Apply sorting
          if (_sortBy == 'distance' && _locationPermissionGranted && _userPosition != null) {
            coaches.sort((a, b) {
              if (a.latitude == null || a.longitude == null) return 1;
              if (b.latitude == null || b.longitude == null) return -1;
              
              double distA = _locationService.calculateDistance(
                _userPosition!.latitude,
                _userPosition!.longitude,
                a.latitude!,
                a.longitude!
              );
              double distB = _locationService.calculateDistance(
                _userPosition!.latitude,
                _userPosition!.longitude,
                b.latitude!,
                b.longitude!
              );
              return distA.compareTo(distB);
            });
          } else if (_sortBy == 'rating') {
            coaches.sort((a, b) => b.rating.compareTo(a.rating));
          } else if (_sortBy == 'price') {
            // Simple string comparison for now, can be enhanced to parse currency
            coaches.sort((a, b) => a.price.compareTo(b.price));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coaches.length,
            itemBuilder: (context, index) {
              final coach = coaches[index];
              return _buildCoachCard(coach);
            },
          );
        },
      ),
    );
  }

  Widget _buildCoachCard(Coach coach) {
    String? distanceDisplay;
    
    if (_locationPermissionGranted && _userPosition != null && 
        coach.latitude != null && coach.longitude != null) {
      double distance = _locationService.calculateDistance(
        _userPosition!.latitude,
        _userPosition!.longitude,
        coach.latitude!,
        coach.longitude!
      );
      distanceDisplay = _locationService.formatDistance(distance);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoachDetailPage(coach: coach),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1F33),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Hero(
                    tag: 'coach-${coach.id}',
                    child: coach.imageUrl.startsWith('assets/')
                        ? Image.asset(
                            coach.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 200,
                                  color: Colors.grey,
                                  child: const Icon(Icons.person, size: 80, color: Colors.white),
                                ),
                          )
                        : Image.network(
                            coach.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 200,
                                  color: Colors.grey,
                                  child: const Icon(Icons.person, size: 80, color: Colors.white),
                                ),
                          ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              coach.rating.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (distanceDisplay != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                distanceDisplay,
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          coach.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (coach.address != null)
                        Text(
                          coach.address!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    coach.specialty,
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        coach.experience,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        coach.price,
                        style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
