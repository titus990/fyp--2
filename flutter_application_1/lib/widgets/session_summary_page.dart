import 'package:flutter/material.dart';
import '../models/attack_scenario.dart';

class SessionSummaryPage extends StatelessWidget {
  final ScenarioSession session;

  const SessionSummaryPage({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F38),
        title: const Text(
          'Session Complete',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trophy Icon
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // Score Card
            _buildScoreCard(),
            const SizedBox(height: 24),

            // Stats Grid
            _buildStatsGrid(),
            const SizedBox(height: 24),

            // Performance Message
            _buildPerformanceMessage(),
            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F38), Color(0xFF0A0E21)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Total Score',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            ).createShader(bounds),
            child: Text(
              '${session.totalScore}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.bold,
                fontFamily: 'Monospace',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${session.difficulty.toUpperCase()} LEVEL',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                label: 'Accuracy',
                value: '${session.accuracyPercentage.toStringAsFixed(0)}%',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.speed,
                label: 'Avg Time',
                value: '${session.averageResponseTime.toStringAsFixed(1)}s',
                gradient: const LinearGradient(
                  colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.fitness_center,
                label: 'Scenarios',
                value: '${session.scenarios.length}',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.timer,
                label: 'Duration',
                value: _formatDuration(session.sessionDuration),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMessage() {
    String message;
    IconData icon;
    List<Color> gradientColors;

    final accuracy = session.accuracyPercentage;

    if (accuracy >= 80) {
      message = 'Excellent work! You\'re ready for real-world scenarios.';
      icon = Icons.star;
      gradientColors = [const Color(0xFFFFD700), const Color(0xFFFF8C00)];
    } else if (accuracy >= 60) {
      message = 'Good job! Keep practicing to improve your response time.';
      icon = Icons.thumb_up;
      gradientColors = [const Color(0xFF4CAF50), const Color(0xFF45A049)];
    } else if (accuracy >= 40) {
      message = 'Not bad! Review the correct techniques and try again.';
      icon = Icons.school;
      gradientColors = [const Color(0xFF2193B0), const Color(0xFF6DD5ED)];
    } else {
      message = 'Keep training! Practice makes perfect in self-defense.';
      icon = Icons.fitness_center;
      gradientColors = [const Color(0xFFFF8C00), const Color(0xFFFFD700)];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Restart with same difficulty
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SessionSummaryPage(session: session),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Train Again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to Self Defense',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
