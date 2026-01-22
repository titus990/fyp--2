class DefenseOption {
  final String id;
  final String name;
  final String description;
  final bool isCorrect;

  DefenseOption({
    required this.id,
    required this.name,
    required this.description,
    required this.isCorrect,
  });
}

class AttackScenario {
  final String id;
  final String name;
  final String description;
  final String attackType;
  final List<DefenseOption> defenseOptions;
  final String correctDefenseId;
  final String imagePath;
  final int timeLimit; // seconds
  final String difficulty; // beginner, intermediate, advanced
  final String correctTechnique; // Explanation of correct defense

  AttackScenario({
    required this.id,
    required this.name,
    required this.description,
    required this.attackType,
    required this.defenseOptions,
    required this.correctDefenseId,
    required this.imagePath,
    this.timeLimit = 8,
    required this.difficulty,
    required this.correctTechnique,
  });

  DefenseOption get correctDefense {
    return defenseOptions.firstWhere((option) => option.id == correctDefenseId);
  }
}

class ScenarioSession {
  final List<AttackScenario> scenarios;
  final String difficulty;
  int currentScenarioIndex;
  int totalScore;
  int correctAnswers;
  int totalAttempts;
  List<int> responseTimes; // in seconds
  DateTime startTime;

  ScenarioSession({
    required this.scenarios,
    required this.difficulty,
    this.currentScenarioIndex = 0,
    this.totalScore = 0,
    this.correctAnswers = 0,
    this.totalAttempts = 0,
    List<int>? responseTimes,
    DateTime? startTime,
  })  : responseTimes = responseTimes ?? [],
        startTime = startTime ?? DateTime.now();

  AttackScenario get currentScenario => scenarios[currentScenarioIndex];

  bool get hasMoreScenarios => currentScenarioIndex < scenarios.length - 1;

  void nextScenario() {
    if (hasMoreScenarios) {
      currentScenarioIndex++;
    }
  }

  void addScore(int points) {
    totalScore += points;
  }

  void recordCorrectAnswer() {
    correctAnswers++;
  }

  void recordAttempt() {
    totalAttempts++;
  }

  void recordResponseTime(int seconds) {
    responseTimes.add(seconds);
  }

  double get accuracyPercentage {
    if (totalAttempts == 0) return 0.0;
    return (correctAnswers / totalAttempts) * 100;
  }

  double get averageResponseTime {
    if (responseTimes.isEmpty) return 0.0;
    return responseTimes.reduce((a, b) => a + b) / responseTimes.length;
  }

  Duration get sessionDuration {
    return DateTime.now().difference(startTime);
  }
}
