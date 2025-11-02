import 'package:flutter/material.dart';
import 'widgets/hover_card.dart';
import 'widgets/workout_detail.dart';
import 'widgets/timer_page.dart';

class SelfDefensePage extends StatelessWidget {
  const SelfDefensePage({super.key});

  @override
  Widget build(BuildContext context) {
    const redAccent = Color(0xFFE50914);

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
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Self Defense',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Popular Self-Defense Drills'),
            const SizedBox(height: 10),
            SizedBox(
              height: 190,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _workoutCard(
                    context,
                    title: 'Escape from wrist grab',
                    subtitle: 'Beginner level defense',
                    rating: '4.8 / 5',
                    tag: 'FREE',
                    time: '15 MIN',
                    isPremium: false,
                    image:
                        'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca',
                    accent: redAccent,
                    onTap: () => openWorkout('Escape from wrist grab', false),
                  ),
                  _workoutCard(
                    context,
                    title: 'Defend against choke hold',
                    subtitle: 'Intermediate counter',
                    rating: '4.9 / 5',
                    tag: 'PREMIUM',
                    time: '25 MIN',
                    isPremium: true,
                    image:
                        'https://images.unsplash.com/photo-1605296867304-46d5465a13f1',
                    accent: redAccent,
                    onTap: () => openWorkout('Defend against choke hold', true),
                  ),
                  _workoutCard(
                    context,
                    title: 'Ground defense fundamentals',
                    subtitle: 'Stay safe when pinned',
                    rating: '4.7 / 5',
                    tag: 'FREE',
                    time: '20 MIN',
                    isPremium: false,
                    image:
                        'https://images.unsplash.com/photo-1590080875831-bc93c6c66f93',
                    accent: redAccent,
                    onTap: () =>
                        openWorkout('Ground defense fundamentals', false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _sectionTitle('Combine Your Training'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _smallCard(
                  context,
                  title: 'Scenario Drills',
                  subtitle: 'Simulate real-life attacks',
                  tag: 'PREMIUM',
                  isLocked: false,
                  image:
                      'https://images.unsplash.com/photo-1598970434795-0c54fe7c0642',
                  accent: redAccent,
                  onTap: () => openWorkout('Scenario Drills', true),
                ),
                _smallCard(
                  context,
                  title: 'Partner Practice',
                  subtitle: 'Team up for resistance drills',
                  tag: 'PREMIUM',
                  isLocked: false,
                  image:
                      'https://images.unsplash.com/photo-1573497491208-6b1acb260507',
                  accent: redAccent,
                  onTap: () => openWorkout('Partner Practice', true),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _sectionTitle('Learn & Awareness'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _smallCard(
                  context,
                  title: 'Basic Defense Guide',
                  subtitle: 'Learn key body mechanics',
                  tag: 'FREE',
                  isLocked: false,
                  image:
                      'https://images.unsplash.com/photo-1576678927484-cc907957088c',
                  accent: redAccent,
                  onTap: () => openWorkout('Basic Defense Guide', false),
                ),
                _smallCard(
                  context,
                  title: 'Street Awareness',
                  subtitle: 'Recognize threats early',
                  tag: 'FREE',
                  isLocked: false,
                  image:
                      'https://images.unsplash.com/photo-1573496529574-be85d6a60704',
                  accent: redAccent,
                  onTap: () => openWorkout('Street Awareness', false),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _sectionTitle('Freestyle'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timerCard(context, redAccent),
                _smallCard(
                  context,
                  title: 'Custom Routine',
                  subtitle: 'Create your own flow',
                  tag: 'PREMIUM',
                  isLocked: false,
                  image:
                      'https://images.unsplash.com/photo-1581291518835-42c67c5a99d9',
                  accent: redAccent,
                  onTap: () => openWorkout('Custom Routine', true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Section Header ---
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  // --- Workout Card with tap functionality ---
  Widget _workoutCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String rating,
    required String tag,
    required String time,
    required bool isPremium,
    required String image,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.85), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTag(tag, isPremium, accent),
                  const SizedBox(width: 8),
                  _buildTag(
                    time,
                    false,
                    Colors.white70,
                    textColor: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Small Card with functionality ---
  Widget _smallCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String tag,
    required bool isLocked,
    required String image,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.85), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTag(tag, tag == 'PREMIUM', accent),
              const SizedBox(height: 4),
              if (isLocked)
                const Icon(Icons.lock, color: Colors.white, size: 18),
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
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Timer Card ---
  Widget _timerCard(BuildContext context, Color accent) {
    return HoverCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TimerPage()),
        );
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent, width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: accent, size: 40),
              const SizedBox(height: 8),
              const Text(
                'Round Timer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Text(
                'For freestyle defense',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Tag Widget ---
  Widget _buildTag(String text, bool isPremium, Color bg, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPremium ? bg : Colors.green,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? (isPremium ? Colors.black : Colors.white),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
