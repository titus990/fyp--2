import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import 'profile_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF1A1F38),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: ProfileService().currentUserProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
          }

          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text("Loading Profile...", style: TextStyle(color: Colors.white)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(profile),
                const SizedBox(height: 24),
                _buildStatsRow(profile),
                const SizedBox(height: 24),
                const ActivityGraph(weeklyActivity: [30, 45, 0, 60, 20, 90, 45]), 
                const SizedBox(height: 24),
                 _buildAchievementsSection(profile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(UserProfile profile) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFF6B6B), width: 3),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: const AssetImage('assets/miketyson.jpg'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profile.displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF6B6B)),
          ),
          child: Text(
            "${profile.level} • ${profile.xp} XP",
            style: const TextStyle(
              color: Color(0xFFFF6B6B),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(UserProfile profile) {
    final stats = profile.stats;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatCard(
          label: 'Workouts',
          value: '${stats['totalWorkouts'] ?? 0}',
          icon: Icons.fitness_center,
          color: Colors.cyan,
        ),
        StatCard(
          label: 'Minutes',
          value: '${stats['totalMinutes'] ?? 0}',
          icon: Icons.timer,
          color: Colors.orange,
        ),
        StatCard(
          label: 'Streak',
          value: '${stats['streak'] ?? 0} 🔥',
          icon: Icons.local_fire_department,
          color: Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(UserProfile profile) {
    final Map<String, dynamic> earned = profile.achievements;
    
    final allBadges = [
      {'id': 'first_punch', 'name': 'First Punch', 'icon': Icons.sports_mma},
      {'id': '10_workouts', 'name': '10 Fights', 'icon': Icons.emoji_events},
      {'id': '7_day_streak', 'name': '7 Day Streak', 'icon': Icons.local_fire_department},
      {'id': 'master_jab', 'name': 'Jab Master', 'icon': Icons.back_hand}, 
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Achievements",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: allBadges.map((badge) {
            final isUnlocked = earned.containsKey(badge['id']) && earned[badge['id']] == true;
            return AchievementBadge(
              id: badge['id'] as String,
              name: badge['name'] as String,
              icon: badge['icon'] as IconData,
              isUnlocked: isUnlocked,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F38),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Display Name',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
               if (nameController.text.isNotEmpty) {
                 ProfileService().updateProfile(displayName: nameController.text.trim());
               }
               Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
