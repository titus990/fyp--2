import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/admin_service.dart';
import 'package:flutter_application_1/admin/user_management.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1F38),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Exit Admin Panel',
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: const Color(0xFF1D1F33),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            selectedLabelTextStyle: const TextStyle(
              color: Color(0xFFFF6B6B),
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard, color: Colors.white70),
                selectedIcon: Icon(Icons.dashboard, color: Color(0xFFFF6B6B)),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people, color: Colors.white70),
                selectedIcon: Icon(Icons.people, color: Color(0xFFFF6B6B)),
                label: Text('Users'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Colors.white12),
          Expanded(
            child: _selectedIndex == 0
                ? _buildOverview()
                : const UserManagementPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return StreamBuilder<QuerySnapshot>(
      stream: _adminService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                const Text(
                  'Access Denied',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You do not have permission to view stats.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        int totalUsers = 0;
        int admins = 0;
        int activeUsers = 0;

        if (snapshot.hasData) {
          totalUsers = snapshot.data!.docs.length;
          final docs = snapshot.data!.docs;
          admins = docs
              .where(
                (doc) =>
                    (doc.data() as Map<String, dynamic>)['role'] == 'admin',
              )
              .length;

          final yesterday = DateTime.now().subtract(const Duration(hours: 24));
          activeUsers = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['lastActive'] == null) return false;
            final lastActive = (data['lastActive'] as Timestamp).toDate();
            return lastActive.isAfter(yesterday);
          }).length;
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'System Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Users',
                    totalUsers.toString(),
                    Icons.group,
                  ),
                  _buildStatCard(
                    'Active (24h)',
                    activeUsers.toString(),
                    Icons.access_time_filled,
                    color: Colors.blueAccent,
                  ),
                  _buildStatCard(
                    'Admins',
                    admins.toString(),
                    Icons.admin_panel_settings,
                  ),
                  _buildStatCard(
                    'System Status',
                    'Active',
                    Icons.check_circle,
                    color: Colors.greenAccent,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon, {
    Color color = const Color(0xFFFF6B6B),
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 30),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
