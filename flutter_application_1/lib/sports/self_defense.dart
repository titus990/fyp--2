import 'package:flutter/material.dart';
import '../widgets/hover_card.dart';
import '../widgets/workout_detail.dart';
import '../widgets/timer_page.dart';

class SelfDefensePage extends StatelessWidget {
  const SelfDefensePage({super.key});

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
                      colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Popular Self-Defense Drills Section
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
                          image:
                              'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca',
                          onTap: () =>
                              openWorkout('Escape from wrist grab', false),
                        ),
                        _buildWorkoutCard(
                          title: 'Defend against choke hold',
                          subtitle: 'Intermediate counter',
                          rating: '4.9 / 5',
                          tag: 'PREMIUM',
                          time: '25 MIN',
                          isPremium: true,
                          image:
                              'https://images.unsplash.com/photo-1605296867304-46d5465a13f1',
                          onTap: () =>
                              openWorkout('Defend against choke hold', true),
                        ),
                        _buildWorkoutCard(
                          title: 'Ground defense fundamentals',
                          subtitle: 'Stay safe when pinned',
                          rating: '4.7 / 5',
                          tag: 'FREE',
                          time: '20 MIN',
                          isPremium: false,
                          image:
                              'https://images.unsplash.com/photo-1590080875831-bc93c6c66f93',
                          onTap: () =>
                              openWorkout('Ground defense fundamentals', false),
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
                      _buildSmallCard(
                        title: 'Scenario Drills',
                        subtitle: 'Simulate real-life attacks',
                        tag: 'PREMIUM',
                        image:
                            'https://images.unsplash.com/photo-1598970434795-0c54fe7c0642',
                        onTap: () => openWorkout('Scenario Drills', true),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      _buildSmallCard(
                        title: 'Partner Practice',
                        subtitle: 'Team up for resistance drills',
                        tag: 'PREMIUM',
                        image:
                            'https://images.unsplash.com/photo-1573497491208-6b1acb260507',
                        onTap: () => openWorkout('Partner Practice', true),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Learn & Awareness Section
                  _buildSectionTitle('Learn & Awareness'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSmallCard(
                        title: 'Basic Defense Guide',
                        subtitle: 'Learn key body mechanics',
                        tag: 'FREE',
                        image:
                            'https://images.unsplash.com/photo-1576678927484-cc907957088c',
                        onTap: () => openWorkout('Basic Defense Guide', false),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      _buildSmallCard(
                        title: 'Street Awareness',
                        subtitle: 'Recognize threats early',
                        tag: 'FREE',
                        image:
                            'https://images.unsplash.com/photo-1573496529574-be85d6a60704',
                        onTap: () => openWorkout('Street Awareness', false),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Freestyle Section
                  _buildSectionTitle('Freestyle'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSmallCard(
                        title: 'Custom Routine',
                        subtitle: 'Create your own flow',
                        tag: 'PREMIUM',
                        image:
                            'https://images.unsplash.com/photo-1581291518835-42c67c5a99d9',
                        onTap: () => openWorkout('Custom Routine', true),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
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
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
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

  Widget _buildTimerCard(context) {
    return HoverCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TimerPage()),
        );
      },
      child: Container(
        width: 170,
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1F38), Color(0xFF0A0E21)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2193B0).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2193B0).withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.timer, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 12),
            const Text(
              'Round Timer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              'For freestyle defense',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
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
