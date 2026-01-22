import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomizeRoutinePage extends StatefulWidget {
  final String moduleType;

  const CustomizeRoutinePage({
    super.key,
    this.moduleType = 'boxing',
  });

  @override
  State<CustomizeRoutinePage> createState() => _CustomizeRoutinePageState();
}

class _CustomizeRoutinePageState extends State<CustomizeRoutinePage> {
  late final List<String> goals;

  final List<String> intensityLevels = [
    'Easy',
    'Moderate',
    'Advanced',
    'Fighter mode',
  ];

  late String selectedGoal;
  String selectedIntensity = 'Moderate';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeGoals();
    _loadSettings();
  }

  void _initializeGoals() {
    if (widget.moduleType == 'self_defense') {
      goals = [
        'Situational Awareness',
        'Escape & Evasion',
        'Strike Defense',
        'Ground Survival',
        'Grab Release Mastery',
        'Reflex Development',
      ];
      selectedGoal = 'Situational Awareness';
    } else {
      goals = [
        'Weight loss',
        'Muscle gain',
        'Beginner boxing',
        'Improve punch power',
        'Improve technique',
        'Self-defense mastery',
      ];
      selectedGoal = 'Beginner boxing';
    }
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data()?['goalSettings'] != null) {
          final settings = doc.data()!['goalSettings'];
          final savedGoal = settings['goal'];
          // Only load if the saved goal is valid for the current module
          if (savedGoal != null && goals.contains(savedGoal)) {
            setState(() {
              selectedGoal = savedGoal;
              selectedIntensity = settings['intensity'] ?? 'Moderate';
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'goalSettings': {
            'goal': selectedGoal,
            'intensity': selectedIntensity,
            'moduleType': widget.moduleType,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving settings: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text(
          widget.moduleType == 'self_defense' 
            ? 'Customize Defense Routine' 
            : 'Customize Boxing Routine'
        ),
        backgroundColor: const Color(0xFF1A1F38),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: const Text(
                      'Personalize Your Training',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select your goal and intensity level',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // Goals Section
                  Row(
                    children: [
                      const Text(
                        '🎯',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Goals',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...goals.map((goal) => _buildGoalOption(goal)),
                  const SizedBox(height: 32),

                  // Intensity Section
                  Row(
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Intensity Level',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...intensityLevels.map((level) => _buildIntensityOption(level)),
                  const SizedBox(height: 32),

                  // Recommended Parameters
                  _buildRecommendations(),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGoalOption(String goal) {
    final isSelected = selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => selectedGoal = goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : const Color(0xFF1D1F33),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.white54,
            ),
            const SizedBox(width: 12),
            Text(
              goal,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensityOption(String level) {
    final isSelected = selectedIntensity == level;
    return GestureDetector(
      onTap: () => setState(() => selectedIntensity = level),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : const Color(0xFF1D1F33),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.white54,
            ),
            const SizedBox(width: 12),
            Text(
              level,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = _getRecommendations();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F38), Color(0xFF0A0E21)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6B6B), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Parameters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecommendationRow('Duration:', recommendations['duration']!),
          _buildRecommendationRow('Frequency:', recommendations['frequency']!),
          _buildRecommendationRow('Focus:', recommendations['focus']!),
        ],
      ),
    );
  }

  Widget _buildRecommendationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getRecommendations() {
    // Simple logic based on intensity
    String duration = '';
    String frequency = '';
    
    switch (selectedIntensity) {
      case 'Easy':
        duration = '20-30 minutes';
        frequency = '2-3 times per week';
        break;
      case 'Moderate':
        duration = '30-45 minutes';
        frequency = '3-4 times per week';
        break;
      case 'Advanced':
        duration = '45-60 minutes';
        frequency = '4-5 times per week';
        break;
      case 'Fighter mode':
        duration = '60-90 minutes';
        frequency = '5-6 times per week';
        break;
    }

    // Focus based on goal
    String focus = '';
    if (widget.moduleType == 'self_defense') {
      switch (selectedGoal) {
        case 'Situational Awareness':
          focus = 'Scanning drills + threat recognition';
          break;
        case 'Escape & Evasion':
          focus = 'Break-aways + running drills';
          break;
        case 'Strike Defense':
          focus = 'Blocking + parrying + countering';
          break;
        case 'Ground Survival':
          focus = 'Bridge and roll + guard retention';
          break;
        case 'Grab Release Mastery':
          focus = 'Wrist releases + choke defenses';
          break;
        case 'Reflex Development':
          focus = 'Reaction ball + partner drills';
          break;
        default:
          focus = 'General self-defense skills';
      }
    } else {
      switch (selectedGoal) {
        case 'Weight loss':
          focus = 'High-intensity cardio combos';
          break;
        case 'Muscle gain':
          focus = 'Strength training + heavy bag';
          break;
        case 'Beginner boxing':
          focus = 'Basic techniques + form';
          break;
        case 'Improve punch power':
          focus = 'Power drills + heavy bag';
          break;
        case 'Improve technique':
          focus = 'Shadow boxing + precision drills';
          break;
        case 'Self-defense mastery':
          focus = 'Realistic scenarios + sparring';
          break;
        default:
          focus = 'General boxing skills';
      }
    }

    return {
      'duration': duration,
      'frequency': frequency,
      'focus': focus,
    };
  }
}
