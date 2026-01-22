import 'package:flutter/material.dart';
import 'scenario_drill_page.dart';

class DifficultySelectionPage extends StatelessWidget {
  const DifficultySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F38),
        title: const Text(
          'Select Difficulty',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Choose Your Challenge',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Test your self-defense knowledge with realistic attack scenarios',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Beginner
            _buildDifficultyCard(
              context,
              difficulty: 'beginner',
              title: 'Beginner',
              description: 'Basic attacks and simple defenses',
              scenarios: '4 scenarios',
              timeLimit: '8 seconds per scenario',
              icon: Icons.school,
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
              ),
            ),
            const SizedBox(height: 16),

            // Intermediate
            _buildDifficultyCard(
              context,
              difficulty: 'intermediate',
              title: 'Intermediate',
              description: 'Complex grabs and chokes',
              scenarios: '4 scenarios',
              timeLimit: '6-7 seconds per scenario',
              icon: Icons.fitness_center,
              gradient: const LinearGradient(
                colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
              ),
            ),
            const SizedBox(height: 16),

            // Advanced
            _buildDifficultyCard(
              context,
              difficulty: 'advanced',
              title: 'Advanced',
              description: 'Ground attacks, weapons, multiple threats',
              scenarios: '4 scenarios',
              timeLimit: '5-6 seconds per scenario',
              icon: Icons.whatshot,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context, {
    required String difficulty,
    required String title,
    required String description,
    required String scenarios,
    required String timeLimit,
    required IconData icon,
    required Gradient gradient,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScenarioDrillPage(difficulty: difficulty),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        scenarios,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.timer,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          timeLimit,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
