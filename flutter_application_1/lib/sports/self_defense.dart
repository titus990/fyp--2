import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/hover_card.dart';
import '../widgets/workout_detail.dart';
import '../profile/profile_page.dart';
import '../services/premium_service.dart';
import '../widgets/paywall_dialog.dart';
import '../widgets/feedback_page.dart';
import '../widgets/customize_routine_page.dart';
import '../widgets/reflex_timer_page.dart';
import '../widgets/video_player_page.dart';
import '../widgets/difficulty_selection_page.dart';
import '../services/payment_page.dart';

class SelfDefensePage extends StatelessWidget {
  const SelfDefensePage({super.key});

  @override
  Widget build(BuildContext context) {
    void openWorkout(String title, bool isPremium) async {
      // Check premium status if this is a premium workout
      if (isPremium) {
        final userIsPremium = await PremiumService.instance.isPremiumUser();

        if (!userIsPremium) {
          // Show paywall dialog
          final shouldUpgrade = await PaywallDialog.show(
            context,
            featureName: title,
            showCoachOption: false,
          );

          if (shouldUpgrade == true) {
            // Navigate to payment page
            if (context.mounted) {
              final paymentSuccess = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentPage()),
              );

              if (paymentSuccess == true && context.mounted) {
                // Payment successful! Retry opening the workout
                openWorkout(title, isPremium);
              }
            }
          }
          return; // Block access
        }
      }

      // Handle special routes
      if (title == 'Defend against choke hold') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VideoPlayerPage(
              videoPath: 'assets/chokehold.mp4',
              title: 'Defend against choke hold',
            ),
          ),
        );
        return;
      }
      if (title == 'Ground defense fundamentals') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VideoPlayerPage(
              videoPath: 'assets/Ground_defense.mp4',
              title: 'Ground Defense fundamentals',
            ),
          ),
        );
        return;
      }

      if (title == 'Escape from wrist grab') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VideoPlayerPage(
              videoPath: 'assets/wrist_grab.mp4',
              title: 'Escape from wrist grab',
            ),
          ),
        );
        return;
      }

      if (title == 'Custom Routine') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CustomizeRoutinePage(moduleType: 'self_defense'),
          ),
        );
        return;
      }
      if (title == 'Reflex Trainer') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReflexTimerPage()),
        );
        return;
      }
      if (title == 'Scenario Drills') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DifficultySelectionPage(),
          ),
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
                'Self Defense',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.security,
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
            actions: [
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rate_review, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackPage(
                        moduleType: 'self_defense',
                        moduleName: 'Self Defense Module',
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
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
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
                  _buildSectionTitle('Popular Self-Defense Drills'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildWorkoutCard(
                          title: 'Escape from wrist grab',
                          subtitle: 'Beginner level defense',
                          rating: '4.8 / 5',
                          tag: 'FREE',
                          time: '15 MIN',
                          isPremium: false,
                          image: 'assets/boxing.png',
                          onTap: () =>
                              openWorkout('Escape from wrist grab', false),
                        ),
                        _buildWorkoutCard(
                          title: 'Defend against choke hold',
                          subtitle: 'Intermediate counter',
                          rating: '4.9 / 5',
                          tag: 'FREE',
                          time: '25 MIN',
                          isPremium: false,
                          image: 'assets/choke_hold.png',
                          onTap: () =>
                              openWorkout('Defend against choke hold', false),
                        ),
                        _buildWorkoutCard(
                          title: 'Ground defense fundamentals',
                          subtitle: 'Stay safe when pinned',
                          rating: '4.7 / 5',
                          tag: 'PREMIUM',
                          time: '20 MIN',
                          isPremium: true,
                          image: 'assets/ground_defense.png',
                          onTap: () =>
                              openWorkout('Ground defense fundamentals', true),
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
                        child: _buildSmallCard(
                          title: 'Scenario Drills',
                          subtitle: 'Simulate real-life attacks',
                          tag: 'PREMIUM',
                          image: 'assets/scenario_drill.png',
                          onTap: () => openWorkout('Scenario Drills', true),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSmallCard(
                          title: 'Partner Practice',
                          subtitle: 'Team up for resistance drills',
                          tag: 'PREMIUM',
                          image: 'assets/partner_practice.png',
                          onTap: () => openWorkout('Partner Practice', true),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Learn & Awareness'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildSmallCard(
                          title: 'Basic Defense Guide',
                          subtitle: 'Learn key body mechanics',
                          tag: 'FREE',
                          image: 'assets/self_defense.png',
                          onTap: () =>
                              openWorkout('Basic Defense Guide', false),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSmallCard(
                          title: 'Street Awareness',
                          subtitle: 'Recognize threats early',
                          tag: 'FREE',
                          image: 'assets/street_awareness.png',
                          onTap: () => openWorkout('Street Awareness', false),
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

                  _buildSectionTitle('Training Lab'),
                  const SizedBox(height: 16),
                  _buildSmallCard(
                    title: 'Reflex Trainer',
                    subtitle: 'Random command training for speed',
                    tag: 'NEW',
                    image: 'assets/self_defense.png',
                    onTap: () => openWorkout('Reflex Trainer', false),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF12005E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Freestyle'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildSmallCard(
                          title: 'Custom Routine',
                          subtitle: 'Create your own flow',
                          tag: 'FREE',
                          image: 'assets/custom_routine.png',
                          onTap: () => openWorkout('Custom Routine', false),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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
        colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
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
    required String subtitle,
    required String rating,
    required String tag,
    required String time,
    required bool isPremium,
    required String image,
    required VoidCallback onTap,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
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
                  _buildTag(
                    tag,
                    isPremium,
                    isPremium
                        ? const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                          ),
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    time,
                    false,
                    const LinearGradient(
                      colors: [Colors.white70, Colors.white54],
                    ),
                    textColor: Colors.black,
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
              Text(
                subtitle,
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

  Widget _buildSmallCard({
    required String title,
    required String subtitle,
    required String tag,
    required String image,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return HoverCard(
      onTap: onTap,
      child: Container(
        // width: 170, // Removed for responsiveness
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
                  _buildTag(
                    tag,
                    tag == 'PREMIUM',
                    tag == 'PREMIUM'
                        ? const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
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

  Widget _buildTag(
    String text,
    bool isPremium,
    Gradient gradient, {
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
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
