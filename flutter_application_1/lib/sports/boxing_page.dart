import 'package:flutter/material.dart';
import '../widgets/hover_card.dart';
import '../widgets/workout_detail.dart';
import '../widgets/timer_page.dart';
import '../widgets/video_player_page.dart';
import '../coaches/coach_list_page.dart';
import '../profile/profile_page.dart';
import '../widgets/weekly_planner_page.dart';
import '../widgets/customize_routine_page.dart';
import '../widgets/feedback_page.dart';
import '../services/premium_service.dart';
import '../widgets/paywall_dialog.dart';
import 'punch_analysis_page.dart';
import '../services/payment_page.dart';

class BoxingPage extends StatefulWidget {
  const BoxingPage({super.key});

  @override
  State<BoxingPage> createState() => _BoxingPageState();
}

class _BoxingPageState extends State<BoxingPage> {
  void openWorkout(String title, bool isPremium) async {
    // Check premium status if this is a premium workout
    if (isPremium) {
      final userIsPremium = await PremiumService.instance.isPremiumUser();
      
      if (!userIsPremium) {
        // Show paywall dialog
        final showCoachOption = title.contains('Speed & Endurance');
        final shouldUpgrade = await PaywallDialog.show(
          context,
          featureName: title,
          showCoachOption: showCoachOption,
        );
        
        if (shouldUpgrade == true) {
          // Navigate to payment page
          if (mounted) {
            final paymentSuccess = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaymentPage()),
            );
            
            if (paymentSuccess == true && mounted) {
              // Payment successful! Retry opening the workout
              openWorkout(title, isPremium);
            }
          }
        }
        return; // Block access
      }
    }
   
    // Handle special routes
    if (title == 'Workout Planner') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WeeklyPlannerPage()),
      );
      return;
    }
    if (title == 'Custom Boxing Session') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CustomizeRoutinePage()),
      );
      return;
    }

    if (title == 'Heavy Bag Combinations') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VideoPlayerPage(
            videoPath: 'assets/heavy_bag.mp4',
            title: 'Heavy Bag Combinations',
          ),
        ),
      );
      return;
    }

    if (title.contains('Speed & Endurance') && isPremium) {
       // Navigate to coach list for premium users
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CoachListPage()),
      );
      return;
    }

    // For other workouts, navigate to workout detail
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WorkoutDetailPage(title: title, isPremium: isPremium),
      ),
    );
  }

  void openTimerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TimerPage()),
    );
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
                'Boxing',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.sports_martial_arts,
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
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rate_review,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackPage(
                        moduleType: 'boxing',
                        moduleName: 'Boxing Module',
                      ),
                    ),
                  );
                },
                tooltip: 'Module Feedback',
              ),
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
              ),
              const SizedBox(width: 16),
            ],
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
                          title: 'Heavy Bag Combinations',
                          duration: '45 MIN',
                          rating: '4.9 / 5',
                          type: 'Boxing',
                          image: 'assets/boxing.png',
                          onTap: () =>
                              openWorkout('Heavy Bag Combinations', false),
                        ),
                        _buildWorkoutCard(
                          title: 'learn from professionals',
                          duration: '30',
                          rating: '4.7 / 5',
                          type: 'Boxing',
                          image: 'assets/boxing.png',
                          onTap: () =>
                              openWorkout('Speed & Endurance Rounds', true),
                          isPremium: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Combine Your Training'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildCombineCard(
                          title: 'Train Now!',
                          subtitle: 'Customize your routine',
                          image:
                              'assets/boxing.png',
                          onTap: () =>
                              openWorkout('Custom Boxing Session', false),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCombineCard(
                          title: 'Calendar',
                          subtitle: 'Plan your next fight',
                          image:
                              'assets/strikeforce.png',
                          onTap: () => openWorkout('Workout Planner', false),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('AI Performance Lab'),
                  const SizedBox(height: 16),
                  _buildCombineCard(
                    title: 'Analyze Your Punch',
                    subtitle: 'AI-Powered Technique Feedback',
                    image: 'assets/boxing.png', 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PunchAnalysisPage()),
                      );
                    },
                     gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),

                  const SizedBox(height: 30),
                  _buildSectionTitle('Learn'),
                  const SizedBox(height: 16),
                  _buildLearnCard(
                    title: 'Master the Jab!',
                    subtitle: 'Learn proper punching techniques.',
                    image:
                        'assets/boxing.png',
                    onTap: () => openWorkout('Learn the Jab Tutorial', false),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Freestyle Timer'),
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
        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
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
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
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
                      color: Colors.white.withOpacity(0.2),
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
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
                      color: Colors.white.withOpacity(0.2),
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
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFF1A1F38).withOpacity(0.9),
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
    return HoverCard(
      onTap: openTimerPage,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1F38), Color(0xFF0A0E21)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Advanced Round Timer',
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
                  colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.timer, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'Freestyle',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text(
                'Open Timer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
