import 'package:flutter/material.dart';
import 'dart:async';
import 'widgets/workout_detail.dart';
import 'widgets/hover_card.dart';

class KickBoxingPage extends StatefulWidget {
  const KickBoxingPage({super.key});

  @override
  State<KickBoxingPage> createState() => _KickBoxingPageState();
}

class _KickBoxingPageState extends State<KickBoxingPage> {
  // Timer state
  bool isRunning = false;
  int seconds = 180; // 3-minute round
  Timer? timer;
  int restInterval = 30; // 30 seconds rest
  int repeatCount = 3;

  void startTimer() {
    if (isRunning) return;
    setState(() => isRunning = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          t.cancel();
          isRunning = false;
          showRestDialog();
        }
      });
    });
  }

  void showRestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Rest Interval',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Take a ${restInterval}s rest before the next round.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startNextRound();
            },
            child: const Text(
              'Start Next Round',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void startNextRound() {
    if (repeatCount > 1) {
      setState(() {
        repeatCount--;
        seconds = 180;
      });
      startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout complete! Great job 👊")),
      );
    }
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      seconds = 180;
      repeatCount = 3;
    });
  }

  String formatTime(int totalSeconds) {
    final min = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  void openWorkout(String title, bool isPremium) {
    if (isPremium) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Premium Workout',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'You are now starting "$title". Enjoy your premium workout!',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WorkoutDetailPage(title: title, isPremium: isPremium),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kickboxing', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popular Workouts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  workoutCard(
                    title: 'High-Intensity Kickboxing Combos',
                    duration: '45 MIN',
                    rating: '4.8 / 5',
                    type: 'Kickboxing',
                    image:
                        'https://img.freepik.com/free-photo/young-fighter-training-gym_23-2148847673.jpg',
                    onTap: () =>
                        openWorkout('High-Intensity Kickboxing Combos', false),
                  ),
                  workoutCard(
                    title: 'Cardio Power Kick Drills',
                    duration: '40 MIN',
                    rating: '4.6 / 5',
                    type: 'Kickboxing',
                    image:
                        'https://img.freepik.com/free-photo/strong-woman-doing-kickboxing-gym_23-2148942094.jpg',
                    onTap: () => openWorkout('Cardio Power Kick Drills', true),
                    isPremium: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Combine Your Training',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                combineCard(
                  title: 'Train Now!',
                  subtitle: 'Create your own session',
                  image:
                      'https://img.freepik.com/free-photo/boxing-fitness-training_23-2148888431.jpg',
                  onTap: () => openWorkout('Custom Training Session', false),
                ),
                combineCard(
                  title: 'Calendar',
                  subtitle: 'Schedule workouts',
                  image:
                      'https://img.freepik.com/free-vector/calendar-icon_23-2147511062.jpg',
                  onTap: () => openWorkout('Workout Calendar', false),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Learn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            learnCard(
              title: 'New to Kickboxing?',
              subtitle: 'Start with this guided tutorial!',
              image:
                  'https://img.freepik.com/free-photo/woman-training-gym_23-2148942106.jpg',
              onTap: () => openWorkout('Kickboxing Beginner Tutorial', false),
            ),
            const SizedBox(height: 20),
            const Text(
              'Freestyle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            freestyleTimerCard(),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTS BELOW ---

  Widget workoutCard({
    required String title,
    required String duration,
    required String rating,
    required String type,
    required String image,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPremium ? Colors.amber : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPremium ? 'PREMIUM' : 'FREE',
                      style: TextStyle(
                        color: isPremium ? Colors.black : Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                type,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '⭐ $rating',
                style: const TextStyle(color: Colors.amber, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget combineCard({
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.7),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.fitness_center, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget learnCard({
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.5),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget freestyleTimerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Freestyle Round Timer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatTime(seconds),
            style: const TextStyle(
              color: Colors.red,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isRunning ? null : startTimer,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Start'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: resetTimer,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rest Interval: $restInterval sec | Rounds Left: $repeatCount',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
