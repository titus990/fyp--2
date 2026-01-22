import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementBadge extends StatelessWidget {
  final String id;
  final String name;
  final IconData icon;
  final bool isUnlocked;

  const AchievementBadge({
    super.key,
    required this.id,
    required this.name,
    required this.icon,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUnlocked ? const Color(0xFFFFD700) : Colors.grey;
    final bgColor = isUnlocked ? const Color(0xFFFFD700).withOpacity(0.1) : const Color(0xFF1D1F33);

    return Tooltip(
      message: isUnlocked ? 'Unlocked!' : 'Locked',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUnlocked ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityGraph extends StatelessWidget {
  final List<int> weeklyActivity; 

  const ActivityGraph({super.key, required this.weeklyActivity});

  @override
  Widget build(BuildContext context) {
 
    final maxMinutes = weeklyActivity.reduce((curr, next) => curr > next ? curr : next);
    final safeMax = maxMinutes == 0 ? 60 : maxMinutes;

    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Activity (Minutes)',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final heightFactor = weeklyActivity[index] / safeMax;
                return _buildBar(index, heightFactor, weeklyActivity[index]);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(int index, double heightFactor, int value) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S']; 
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (value > 0)
          Text(
            '$value',
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        const SizedBox(height: 4),
        Flexible(
            child: FractionallySizedBox(
              heightFactor: heightFactor > 0 ? heightFactor : 0.05, 
              child: Container(
                width: 12,
                decoration: BoxDecoration(
                  color: heightFactor > 0 ? const Color(0xFFFF416C) : Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                  gradient: heightFactor > 0 ? const LinearGradient(
                    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ) : null,
                ),
              ),
            ),
        ),
        const SizedBox(height: 8),
        Text(
          days[index],
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
