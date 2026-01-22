import 'dart:math';
import '../models/attack_scenario.dart';

class ScenarioService {
  static final ScenarioService instance = ScenarioService._();
  ScenarioService._();

  // All available scenarios
  static final List<AttackScenario> _allScenarios = [
    // BEGINNER SCENARIOS
    AttackScenario(
      id: 'beginner_1',
      name: 'Front Wrist Grab',
      description: 'An attacker grabs your wrist from the front with one hand',
      attackType: 'Grab',
      difficulty: 'beginner',
      imagePath: 'assets/self_defense.png',
      timeLimit: 8,
      correctTechnique: 'Rotate your wrist against the attacker\'s thumb (weakest point) and pull away sharply.',
      correctDefenseId: 'wrist_rotate',
      defenseOptions: [
        DefenseOption(
          id: 'wrist_rotate',
          name: 'Rotate wrist against thumb',
          description: 'Turn your wrist in a circular motion against their thumb',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'pull_back',
          name: 'Pull straight back',
          description: 'Use force to pull your arm backward',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'push_forward',
          name: 'Push forward',
          description: 'Push your arm toward the attacker',
          isCorrect: false,
        ),
      ],
    ),

    AttackScenario(
      id: 'beginner_2',
      name: 'Push from Front',
      description: 'Someone aggressively pushes you from the front',
      attackType: 'Push',
      difficulty: 'beginner',
      imagePath: 'assets/self_defense.png',
      timeLimit: 8,
      correctTechnique: 'Step back to absorb force, maintain balance, and create distance.',
      correctDefenseId: 'step_back',
      defenseOptions: [
        DefenseOption(
          id: 'step_back',
          name: 'Step back and create distance',
          description: 'Move backward to absorb the push and gain space',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'push_back',
          name: 'Push back immediately',
          description: 'Use equal force to push the attacker',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'stand_still',
          name: 'Stand your ground',
          description: 'Resist the push without moving',
          isCorrect: false,
        ),
      ],
    ),

    AttackScenario(
      id: 'beginner_3',
      name: 'Hair Pull from Behind',
      description: 'Attacker grabs your hair from behind',
      attackType: 'Grab',
      difficulty: 'beginner',
      imagePath: 'assets/self_defense.png',
      timeLimit: 8,
      correctTechnique: 'Place both hands over attacker\'s hand to trap it, turn toward them, and strike.',
      correctDefenseId: 'trap_turn',
      defenseOptions: [
        DefenseOption(
          id: 'trap_turn',
          name: 'Trap their hand and turn',
          description: 'Cover their hand with yours and rotate your body',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'pull_away',
          name: 'Pull your head away',
          description: 'Try to pull your head forward',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'grab_hair',
          name: 'Grab their hair back',
          description: 'Reach back and grab their hair',
          isCorrect: false,
        ),
      ],
    ),

    AttackScenario(
      id: 'beginner_4',
      name: 'Shoulder Grab',
      description: 'Someone grabs your shoulder from the side',
      attackType: 'Grab',
      difficulty: 'beginner',
      imagePath: 'assets/self_defense.png',
      timeLimit: 8,
      correctTechnique: 'Raise your arm sharply to break the grip and create distance.',
      correctDefenseId: 'arm_raise',
      defenseOptions: [
        DefenseOption(
          id: 'arm_raise',
          name: 'Raise arm sharply upward',
          description: 'Lift your arm quickly to break their grip',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'shrug_off',
          name: 'Shrug your shoulder',
          description: 'Try to shake off their hand',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'grab_hand',
          name: 'Grab their hand',
          description: 'Hold their hand in place',
          isCorrect: false,
        ),
      ],
    ),

    // INTERMEDIATE SCENARIOS
    AttackScenario(
      id: 'intermediate_1',
      name: 'Two-Hand Wrist Grab',
      description: 'Attacker grabs both of your wrists',
      attackType: 'Grab',
      difficulty: 'intermediate',
      imagePath: 'assets/self_defense.png',
      timeLimit: 7,
      correctTechnique: 'Rotate both wrists outward against thumbs simultaneously, then pull back.',
      correctDefenseId: 'double_rotate',
      defenseOptions: [
        DefenseOption(
          id: 'double_rotate',
          name: 'Rotate both wrists outward',
          description: 'Turn both wrists against their thumbs at once',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'pull_hard',
          name: 'Pull both arms back hard',
          description: 'Use brute force to pull away',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'kick_shin',
          name: 'Kick their shin',
          description: 'Strike their leg while grabbed',
          isCorrect: false,
        ),
      ],
    ),

    AttackScenario(
      id: 'intermediate_2',
      name: 'Front Choke',
      description: 'Attacker has both hands around your neck from the front',
      attackType: 'Choke',
      difficulty: 'intermediate',
      imagePath: 'assets/choke_hold.png',
      timeLimit: 6,
      correctTechnique: 'Tuck chin, raise arms between theirs, and strike upward to break grip.',
      correctDefenseId: 'arm_raise_strike',
      defenseOptions: [
        DefenseOption(
          id: 'arm_raise_strike',
          name: 'Raise arms between theirs',
          description: 'Thrust arms up between their arms to break grip',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'pull_hands',
          name: 'Pull their hands off',
          description: 'Try to pry their fingers away',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'punch_face',
          name: 'Punch their face',
          description: 'Strike while being choked',
          isCorrect: false,
        ),
      ],
    ),

    AttackScenario(
      id: 'intermediate_3',
      name: 'Bear Hug from Behind',
      description: 'Attacker wraps arms around you from behind, pinning your arms',
      attackType: 'Grab',
      difficulty: 'intermediate',
      imagePath: 'assets/self_defense.png',
      timeLimit: 7,
      correctTechnique: 'Drop your weight, stomp on their foot, then elbow strike to the ribs.',
      correctDefenseId: 'drop_stomp_elbow',
      defenseOptions: [
        DefenseOption(
          id: 'drop_stomp_elbow',
          name: 'Drop weight, stomp foot, elbow',
          description: 'Lower center of gravity, stomp, then strike with elbow',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'struggle_forward',
          name: 'Struggle to break free',
          description: 'Try to pull away forward',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'headbutt_back',
          name: 'Headbutt backward',
          description: 'Throw your head back',
          isCorrect: false,
        ),
      ],
    ),

    AttackScenario(
      id: 'intermediate_4',
      name: 'Side Headlock',
      description: 'Attacker has you in a headlock from the side',
      attackType: 'Grab',
      difficulty: 'intermediate',
      imagePath: 'assets/self_defense.png',
      timeLimit: 7,
      correctTechnique: 'Strike to groin or ribs, then push their head back to escape.',
      correctDefenseId: 'strike_push_head',
      defenseOptions: [
        DefenseOption(
          id: 'strike_push_head',
          name: 'Strike ribs, push head back',
          description: 'Hit their ribs then push their head backward',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'pull_arm',
          name: 'Pull their arm down',
          description: 'Try to lower their arm',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'bite_arm',
          name: 'Bite their arm',
          description: 'Use teeth to escape',
          isCorrect: false,
        ),
      ],
    ),

    // ADVANCED SCENARIOS
    AttackScenario(
      id: 'advanced_1',
      name: 'Rear Choke',
      description: 'Attacker is choking you from behind with their arm',
      attackType: 'Choke',
      difficulty: 'advanced',
      imagePath: 'assets/self_defense.png',
      timeLimit: 5,
      correctTechnique: 'Tuck chin, turn into them while striking, and escape to the side.',
      correctDefenseId: 'tuck_turn_strike',
      defenseOptions: [
        DefenseOption(
          id: 'tuck_turn_strike',
          name: 'Tuck chin, turn and strike',
          description: 'Protect airway, rotate toward them, and counter-strike',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'pull_arm',
          name: 'Pull their arm away',
          description: 'Try to pry the arm from your neck',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'elbow_back',
          name: 'Elbow straight back',
          description: 'Strike backward with elbow',
          isCorrect: false,
        ),
      ],
    ),

    AttackScenario(
      id: 'advanced_2',
      name: 'Ground Mount',
      description: 'Attacker is on top of you, pinning you to the ground',
      attackType: 'Ground',
      difficulty: 'advanced',
      imagePath: 'assets/ground_defense.png',
      timeLimit: 6,
      correctTechnique: 'Bridge hips, trap arm and leg on same side, then roll to escape.',
      correctDefenseId: 'bridge_trap_roll',
      defenseOptions: [
        DefenseOption(
          id: 'bridge_trap_roll',
          name: 'Bridge, trap, and roll',
          description: 'Lift hips, secure their arm/leg, then roll them over',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'push_chest',
          name: 'Push their chest',
          description: 'Try to push them off with your hands',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'punch_up',
          name: 'Punch upward',
          description: 'Strike from bottom position',
          isCorrect: false,
        ),
      ],
    ),

    AttackScenario(
      id: 'advanced_3',
      name: 'Multiple Attackers',
      description: 'Two attackers approaching from different angles',
      attackType: 'Multiple',
      difficulty: 'advanced',
      imagePath: 'assets/self_defense.png',
      timeLimit: 5,
      correctTechnique: 'Position one attacker between you and the other, strike quickly, then escape.',
      correctDefenseId: 'position_strike_escape',
      defenseOptions: [
        DefenseOption(
          id: 'position_strike_escape',
          name: 'Position, strike, escape',
          description: 'Use one as shield, strike fast, then run',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'fight_both',
          name: 'Fight both at once',
          description: 'Engage both attackers simultaneously',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'back_wall',
          name: 'Back against wall',
          description: 'Find a wall for protection',
          isCorrect: false,
        ),
      ],
    ),

    AttackScenario(
      id: 'advanced_4',
      name: 'Knife Threat',
      description: 'Attacker threatens you with a knife at close range',
      attackType: 'Weapon',
      difficulty: 'advanced',
      imagePath: 'assets/self_defense.png',
      timeLimit: 5,
      correctTechnique: 'If escape impossible: redirect weapon, control weapon arm, strike, and disarm.',
      correctDefenseId: 'redirect_control_disarm',
      defenseOptions: [
        DefenseOption(
          id: 'redirect_control_disarm',
          name: 'Redirect, control, disarm',
          description: 'Move weapon offline, secure their arm, counter-strike',
          isCorrect: true,
        ),
        DefenseOption(
          id: 'grab_knife',
          name: 'Grab the knife',
          description: 'Try to take the weapon directly',
          isCorrect: false,
        ),
        DefenseOption(
          id: 'kick_weapon',
          name: 'Kick the weapon',
          description: 'Use a kick to disarm',
          isCorrect: false,
        ),
      ],
    ),
  ];

  /// Get scenarios by difficulty level
  List<AttackScenario> getScenariosByDifficulty(String difficulty) {
    return _allScenarios
        .where((scenario) => scenario.difficulty == difficulty)
        .toList();
  }

  /// Get random scenarios for a session
  List<AttackScenario> getRandomScenarios({
    required String difficulty,
    int count = 5,
  }) {
    final scenarios = getScenariosByDifficulty(difficulty);
    final shuffled = List<AttackScenario>.from(scenarios)..shuffle(Random());
    return shuffled.take(count).toList();
  }

  /// Get all scenarios
  List<AttackScenario> getAllScenarios() {
    return List<AttackScenario>.from(_allScenarios);
  }

  /// Get scenario by ID
  AttackScenario? getScenarioById(String id) {
    try {
      return _allScenarios.firstWhere((scenario) => scenario.id == id);
    } catch (e) {
      return null;
    }
  }
}
