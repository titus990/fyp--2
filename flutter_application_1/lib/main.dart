import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const StrikeForceApp());
}

class StrikeForceApp extends StatelessWidget {
  const StrikeForceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strike Force',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomePage(),
        '/boxing': (context) => const BoxingPage(),
        '/selfdefense': (context) => const SelfDefensePage(),
        '/kickboxing': (context) => const KickBoxingPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Navigate to Welcome Page after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Using Icon instead of Image.asset to avoid missing asset error
              Icon(Icons.sports_mma, size: 120, color: Colors.redAccent),
              const SizedBox(height: 24),
              const Text(
                'STRIKE FORCE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'WHERE FISTS MEET DISCIPLINE',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Strike Force',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Boxing Button
                CustomButton(
                  label: 'Boxing',
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, '/boxing');
                  },
                ),
                const SizedBox(height: 20),

                // Self Defense Button
                CustomButton(
                  label: 'Self Defense',
                  color: Colors.blueAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, '/selfdefense');
                  },
                ),
                const SizedBox(height: 20),

                // Kick Boxing Button
                CustomButton(
                  label: 'Kick Boxing',
                  color: Colors.orangeAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, '/kickboxing');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable custom button widget
class CustomButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class BoxingPage extends StatefulWidget {
  const BoxingPage({super.key});

  @override
  State<BoxingPage> createState() => _BoxingPageState();
}

class _BoxingPageState extends State<BoxingPage> {
  bool isRunning = false;
  int seconds = 180; // 3 minutes per round
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
        backgroundColor: Colors.black,
        title: const Text(
          'Rest Interval',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Take a ${restInterval}s break before your next round.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startNextRound();
            },
            child: const Text(
              'Next Round',
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
        const SnackBar(content: Text("Workout complete! 🥊 Great job champ!")),
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
        title: const Text('Boxing', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                    title: 'Heavy Bag Combinations',
                    duration: '45 MIN',
                    rating: '4.9 / 5',
                    type: 'Boxing',
                    image:
                        'https://img.freepik.com/free-photo/boxer-punching-bag_23-2148182371.jpg',
                    onTap: () => openWorkout('Heavy Bag Combinations', false),
                  ),
                  workoutCard(
                    title: 'Speed & Endurance Rounds',
                    duration: '30 MIN',
                    rating: '4.7 / 5',
                    type: 'Boxing',
                    image:
                        'https://img.freepik.com/free-photo/boxer-training-gym_23-2148178091.jpg',
                    onTap: () => openWorkout('Speed & Endurance Rounds', true),
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
                  subtitle: 'Customize your routine',
                  image:
                      'https://img.freepik.com/free-photo/boxing-fitness-training_23-2148888431.jpg',
                  onTap: () => openWorkout('Custom Boxing Session', false),
                ),
                combineCard(
                  title: 'Calendar',
                  subtitle: 'Plan your next fight',
                  image:
                      'https://img.freepik.com/free-vector/calendar-icon_23-2147511062.jpg',
                  onTap: () => openWorkout('Workout Planner', false),
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
              title: 'Master the Jab!',
              subtitle: 'Learn proper punching techniques.',
              image:
                  'https://img.freepik.com/free-photo/boxing-trainer_23-2148178820.jpg',
              onTap: () => openWorkout('Learn the Jab Tutorial', false),
            ),
            const SizedBox(height: 20),
            const Text(
              'Freestyle Timer',
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

  // Reusable card widgets with hover effects
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
        children: [
          const Text(
            'Round Timer',
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
          const SizedBox(height: 10),
          Text(
            'Rest: $restInterval sec | Rounds Left: $repeatCount',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Hover Card Widget with scale animation
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const HoverCard({super.key, required this.child, required this.onTap});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          child: widget.child,
        ),
      ),
    );
  }
}

// Workout Detail Page
class WorkoutDetailPage extends StatelessWidget {
  final String title;
  final bool isPremium;

  const WorkoutDetailPage({
    super.key,
    required this.title,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white10,
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://img.freepik.com/free-photo/boxer-punching-bag_23-2148182371.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (isPremium)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Workout Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This is a detailed view of your selected workout. Here you would find instructions, video tutorials, sets, reps, and other relevant information to help you complete your training session successfully.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Starting $title...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Workout',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

// --- Dummy Timer Page ---
class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int seconds = 0;
  bool isRunning = false;
  late final ticker = Stream.periodic(const Duration(seconds: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Defense Timer'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$seconds s',
              style: const TextStyle(color: Colors.white, fontSize: 40),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!isRunning) {
                  isRunning = true;
                  ticker.listen((_) {
                    if (!mounted) return;
                    setState(() => seconds++);
                  });
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Start Timer'),
            ),
          ],
        ),
      ),
    );
  }
}

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
