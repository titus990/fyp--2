import 'dart:async';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int workoutSeconds = 180;
  int restSeconds = 30;
  int rounds = 3;

  int currentRound = 1;
  int secondsLeft = 180;
  bool isRunning = false;
  bool isWorkoutPhase = true;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    if (isRunning) return;

    setState(() => isRunning = true);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      setState(() {
        if (secondsLeft > 0) {
          secondsLeft--;
        } else {
          t.cancel();
          isRunning = false;
          if (isWorkoutPhase) {
            showRestDialog();
          } else {
            startNextRound();
          }
        }
      });
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      secondsLeft = workoutSeconds;
      currentRound = 1;
      isWorkoutPhase = true;
    });
  }

  void showRestDialog() {
    isWorkoutPhase = false;
    secondsLeft = restSeconds;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Rest Interval',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            Timer.periodic(const Duration(seconds: 1), (restTimer) {
              if (!mounted) {
                restTimer.cancel();
                return;
              }
              setStateDialog(() {
                if (secondsLeft > 0) {
                  secondsLeft--;
                } else {
                  restTimer.cancel();
                  Navigator.pop(context);
                  startTimer();
                }
              });
            });
            return Text(
              'Rest: $secondsLeft s',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startNextRound();
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                'Skip Rest',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startNextRound() {
    if (currentRound < rounds) {
      setState(() {
        currentRound++;
        secondsLeft = workoutSeconds;
        isWorkoutPhase = true;
        isRunning = false;
      });
      startTimer();
    } else {
      showCompletionDialog();
    }
  }

  void showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Workout Complete!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '🏆 Goal Achieved! Great job champ!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetTimer();
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                'Restart',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void showSettingsDialog() {
    final workoutController = TextEditingController(
      text: workoutSeconds.toString(),
    );
    final restController = TextEditingController(text: restSeconds.toString());
    final roundsController = TextEditingController(text: rounds.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Customize Timer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildNumberInput('Workout Duration (s)', workoutController),
              const SizedBox(height: 10),
              _buildNumberInput('Rest Interval (s)', restController),
              const SizedBox(height: 10),
              _buildNumberInput('Rounds', roundsController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                workoutSeconds = int.tryParse(workoutController.text) ?? 180;
                restSeconds = int.tryParse(restController.text) ?? 30;
                rounds = int.tryParse(roundsController.text) ?? 3;
                secondsLeft = workoutSeconds;
                currentRound = 1;
                isWorkoutPhase = true;
                isRunning = false;
              });
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Defense Timer'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: showSettingsDialog,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Round $currentRound / $rounds',
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              formatTime(secondsLeft),
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text('Start'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
