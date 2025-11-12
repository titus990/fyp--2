import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/workout_detail.dart';
import '../widgets/hover_card.dart';

class KickBoxingPage extends StatefulWidget {
  const KickBoxingPage({super.key});

  @override
  State<KickBoxingPage> createState() => _KickBoxingPageState();
}

class _KickBoxingPageState extends State<KickBoxingPage> {
  bool isRunning = false;
  int seconds = 180;
  Timer? timer;
  int restInterval = 30;
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
        backgroundColor: const Color(0xFF1A1F38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Rest Interval',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                'Start Next Round',
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
    if (repeatCount > 1) {
      setState(() {
        repeatCount--;
        seconds = 180;
      });
      startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Workout complete! Great job 👊"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
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
          backgroundColor: const Color(0xFF1A1F38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Premium Workout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'You are now starting "$title". Enjoy your premium workout!',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: const Text(
                  'Close',
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
      backgroundColor: const Color(0xFF0A0E21),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF1A1F38),
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Kickboxing',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.sports_kabaddi,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Popular Workouts'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildWorkoutCard(
                          title: 'High-Intensity Kickboxing Combos',
                          duration: '45 MIN',
                          rating: '4.8 / 5',
                          type: 'Kickboxing',
                          image:
                              'https://img.freepik.com/free-photo/young-fighter-training-gym_23-2148847673.jpg',
                          onTap: () => openWorkout(
                            'High-Intensity Kickboxing Combos',
                            false,
                          ),
                        ),
                        _buildWorkoutCard(
                          title: 'Cardio Power Kick Drills',
                          duration: '40 MIN',
                          rating: '4.6 / 5',
                          type: 'Kickboxing',
                          image:
                              'https://img.freepik.com/free-photo/strong-woman-doing-kickboxing-gym_23-2148942094.jpg',
                          onTap: () =>
                              openWorkout('Cardio Power Kick Drills', true),
                          isPremium: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Combine Your Training Section
                  _buildSectionTitle('Combine Your Training'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCombineCard(
                        title: 'Train Now!',
                        subtitle: 'Create your own session',
                        image:
                            'https://img.freepik.com/free-photo/boxing-fitness-training_23-2148888431.jpg',
                        onTap: () =>
                            openWorkout('Custom Training Session', false),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      _buildCombineCard(
                        title: 'Calendar',
                        subtitle: 'Schedule workouts',
                        image:
                            'https://img.freepik.com/free-vector/calendar-icon_23-2147511062.jpg',
                        onTap: () => openWorkout('Workout Calendar', false),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Learn'),
                  const SizedBox(height: 16),
                  _buildLearnCard(
                    title: 'New to Kickboxing?',
                    subtitle: 'Start with this guided tutorial!',
                    image:
                        'https://img.freepik.com/free-photo/woman-training-gym_23-2148942106.jpg',
                    onTap: () =>
                        openWorkout('Kickboxing Beginner Tutorial', false),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Freestyle'),
                  const SizedBox(height: 16),
                  _buildTimerCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWorkoutCard({
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
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: isPremium
                          ? const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                            ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPremium ? 'PREMIUM' : 'FREE',
                      style: TextStyle(
                        color: isPremium ? Colors.black : Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombineCard({
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLearnCard({
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFF1A1F38).withValues(alpha: 0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(20),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F38), Color(0xFF0A0E21)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Freestyle Round Timer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              formatTime(seconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                fontFamily: 'Monospace',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimerButton(
                onPressed: isRunning ? null : startTimer,
                text: 'Start',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                ),
              ),
              const SizedBox(width: 16),
              _buildTimerButton(
                onPressed: resetTimer,
                text: 'Reset',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Rest Interval: $restInterval sec | Rounds Left: $repeatCount',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton({
    required VoidCallback? onPressed,
    required String text,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? const LinearGradient(colors: [Colors.grey, Colors.grey])
            : gradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
