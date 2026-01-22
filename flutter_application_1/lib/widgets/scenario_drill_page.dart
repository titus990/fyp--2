import 'dart:async';
import 'package:flutter/material.dart';
import '../models/attack_scenario.dart';
import '../services/scenario_service.dart';
import 'session_summary_page.dart';

class ScenarioDrillPage extends StatefulWidget {
  final String difficulty;

  const ScenarioDrillPage({
    super.key,
    required this.difficulty,
  });

  @override
  State<ScenarioDrillPage> createState() => _ScenarioDrillPageState();
}

class _ScenarioDrillPageState extends State<ScenarioDrillPage> {
  late ScenarioSession session;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _hasAnswered = false;
  String? _selectedDefenseId;
  bool? _isCorrect;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    final scenarios = ScenarioService.instance.getRandomScenarios(
      difficulty: widget.difficulty,
      count: 5,
    );

    session = ScenarioSession(
      scenarios: scenarios,
      difficulty: widget.difficulty,
    );

    _startScenario();
  }

  void _startScenario() {
    setState(() {
      _secondsRemaining = session.currentScenario.timeLimit;
      _hasAnswered = false;
      _selectedDefenseId = null;
      _isCorrect = null;
      _attempts = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _handleTimeout();
        }
      });
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    if (!_hasAnswered) {
      setState(() {
        _hasAnswered = true;
        _isCorrect = false;
      });
      session.recordAttempt();
      session.recordResponseTime(session.currentScenario.timeLimit);
    }
  }

  void _selectDefense(DefenseOption option) {
    if (_hasAnswered) return;

    final timeElapsed = session.currentScenario.timeLimit - _secondsRemaining;
    _attempts++;

    setState(() {
      _selectedDefenseId = option.id;
      _isCorrect = option.isCorrect;
      _hasAnswered = true;
    });

    _timer?.cancel();

    session.recordAttempt();
    session.recordResponseTime(timeElapsed);

    if (option.isCorrect) {
      session.recordCorrectAnswer();
      
      // Calculate score based on attempts and time
      int points = 0;
      if (_attempts == 1) {
        points = 10;
        if (timeElapsed <= 3) {
          points += 5; // Time bonus
        } else if (timeElapsed <= 5) {
          points += 3;
        }
      } else if (_attempts == 2) {
        points = 5;
      } else if (_attempts == 3) {
        points = 2;
      }

      session.addScore(points);
    }
  }

  void _nextScenario() {
    if (session.hasMoreScenarios) {
      session.nextScenario();
      _startScenario();
    } else {
      _showSessionSummary();
    }
  }

  void _showSessionSummary() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SessionSummaryPage(session: session),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenario = session.currentScenario;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F38),
        title: Text(
          'Scenario ${session.currentScenarioIndex + 1}/${session.scenarios.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Score: ${session.totalScore}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer
            _buildTimer(),
            const SizedBox(height: 24),

            // Scenario Card
            _buildScenarioCard(scenario),
            const SizedBox(height: 24),

            // Defense Options
            _buildDefenseOptions(scenario),
            const SizedBox(height: 24),

            // Feedback and Next Button
            if (_hasAnswered) ...[
              _buildFeedback(),
              const SizedBox(height: 16),
              _buildNextButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final progress = _secondsRemaining / session.currentScenario.timeLimit;
    final isWarning = _secondsRemaining <= 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWarning
              ? [const Color(0xFFFF416C), const Color(0xFFFF4B2B)]
              : [const Color(0xFF2193B0), const Color(0xFF6DD5ED)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isWarning ? Colors.red : Colors.blue).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Time Remaining',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$_secondsRemaining s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioCard(AttackScenario scenario) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F38), Color(0xFF0A0E21)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2193B0).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: Image.asset(
              scenario.imagePath,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: const Color(0xFF1A1F38),
                  child: const Icon(
                    Icons.security,
                    size: 80,
                    color: Colors.white54,
                  ),
                );
              },
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        scenario.attackType.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        scenario.difficulty.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  scenario.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  scenario.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'What should you do?',
                  style: TextStyle(
                    color: Color(0xFF2193B0),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefenseOptions(AttackScenario scenario) {
    return Column(
      children: scenario.defenseOptions.map((option) {
        final isSelected = _selectedDefenseId == option.id;
        final showResult = _hasAnswered && isSelected;

        Color borderColor = const Color(0xFF2193B0);
        Color backgroundColor = const Color(0xFF1A1F38);

        if (showResult) {
          if (_isCorrect == true) {
            borderColor = const Color(0xFF4CAF50);
            backgroundColor = const Color(0xFF4CAF50).withOpacity(0.2);
          } else {
            borderColor = const Color(0xFFFF416C);
            backgroundColor = const Color(0xFFFF416C).withOpacity(0.2);
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _selectDefense(option),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  if (showResult)
                    Icon(
                      _isCorrect == true ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect == true
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF416C),
                      size: 28,
                    ),
                  if (showResult) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback() {
    final scenario = session.currentScenario;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isCorrect == true
              ? [const Color(0xFF4CAF50), const Color(0xFF45A049)]
              : [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isCorrect == true ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                _isCorrect == true ? 'Correct!' : 'Incorrect',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Correct Technique:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scenario.correctTechnique,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: _nextScenario,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            session.hasMoreScenarios ? 'Next Scenario' : 'View Results',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
