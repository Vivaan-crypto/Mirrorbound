import 'dart:math' as math;
import 'mirror_physics.dart';

class Platform {
  final double x, y, width, height;
  final PlatformType type;

  Platform(this.x, this.y, this.width, this.height, {this.type = PlatformType.solid});
}

enum PlatformType { solid, breakable, moving, mirror, lightActivated }

class GameLevel {
  final int id;
  final String name;
  final double width, height;
  final Position startPosition;
  final Position goal;
  final List<Platform> platforms;
  final List<MirrorPortal> portals;
  final List<LightSwitch> lightSwitches;
  final int parMoves;
  final String hint;

  GameLevel({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.startPosition,
    required this.goal,
    required this.platforms,
    this.portals = const [],
    this.lightSwitches = const [],
    this.parMoves = 10,
    this.hint = '',
  });
}

class LightSwitch {
  final Position position;
  final Color requiredColor;
  final String targetId;
  bool isActivated;

  LightSwitch(this.position, this.requiredColor, this.targetId, {this.isActivated = false});
}

class LevelManager {
  final List<GameLevel> _levels = [];
  int _currentLevelIndex = 0;
  final Map<int, LevelProgress> _progress = {};

  LevelManager() {
    _initializeLevels();
  }

  void _initializeLevels() {
    // Tutorial Levels (1-3)
    _levels.add(_createTutorialLevel1());
    _levels.add(_createTutorialLevel2());
    _levels.add(_createTutorialLevel3());

    // Main Campaign Levels (4-30)
    for (int i = 4; i <= 30; i++) {
      _levels.add(_createMainLevel(i));
    }

    // Secret Levels
    for (int i = 31; i <= 40; i++) {
      _levels.add(_createSecretLevel(i));
    }
  }

  GameLevel _createTutorialLevel1() {
    return GameLevel(
      id: 1,
      name: "First Reflection",
      width: 8,
      height: 6,
      startPosition: Position(1, 4),
      goal: Position(6, 4),
      platforms: [
        Platform(0, 5, 8, 1), // Floor
        Platform(3, 3, 2, 1), // Middle platform
      ],
      parMoves: 3,
      hint: "Use the mirror to reach the goal!",
    );
  }

  GameLevel _createTutorialLevel2() {
    return GameLevel(
      id: 2,
      name: "Gravity Shift",
      width: 8,
      height: 6,
      startPosition: Position(1, 4),
      goal: Position(6, 1),
      platforms: [
        Platform(0, 5, 8, 1), // Floor
        Platform(0, 0, 8, 1), // Ceiling
        Platform(3, 2, 2, 1), // Middle platform
        Platform(5, 3, 2, 1), // Step platform
      ],
      parMoves: 5,
      hint: "Invert gravity in the mirror world!",
    );
  }

  GameLevel _createTutorialLevel3() {
    return GameLevel(
      id: 3,
      name: "Mirror Maze",
      width: 10,
      height: 8,
      startPosition: Position(1, 6),
      goal: Position(8, 1),
      platforms: [
        Platform(0, 7, 10, 1), // Floor
        Platform(0, 0, 10, 1), // Ceiling
        Platform(2, 5, 2, 1), // Platform 1
        Platform(6, 4, 2, 1), // Platform 2
        Platform(3, 2, 2, 1), // Platform 3
        Platform(7, 6, 2, 1), // Platform 4
      ],
      parMoves: 8,
      hint: "Combine mirror and gravity mechanics!",
    );
  }

  GameLevel _createMainLevel(int levelId) {
    final random = math.Random(levelId); // Seeded for consistent generation

    return GameLevel(
      id: levelId,
      name: "Level $levelId",
      width: 8 + (levelId % 4) * 2,
      height: 6 + (levelId % 3) * 2,
      startPosition: Position(1, 5 + (levelId % 3)),
      goal: Position(6 + (levelId % 4), 1 + (levelId % 2)),
      platforms: _generatePlatforms(levelId, random),
      portals: _generatePortals(levelId, random),
      lightSwitches: _generateLightSwitches(levelId, random),
      parMoves: 5 + (levelId % 6),
      hint: _generateHint(levelId),
    );
  }

  GameLevel _createSecretLevel(int levelId) {
    final random = math.Random(levelId * 2);

    return GameLevel(
      id: levelId,
      name: "Secret ${levelId - 30}",
      width: 12,
      height: 10,
      startPosition: Position(1, 8),
      goal: Position(10, 1),
      platforms: _generateComplexPlatforms(levelId, random),
      portals: _generateAdvancedPortals(levelId, random),
      lightSwitches: _generateAdvancedLightSwitches(levelId, random),
      parMoves: 15 + (levelId % 8),
      hint: "Master all mechanics to solve this puzzle!",
    );
  }

  List<Platform> _generatePlatforms(int levelId, math.Random random) {
    List<Platform> platforms = [];

    final width = 8 + (levelId % 4) * 2;
    final height = 6 + (levelId % 3) * 2;

    // Always add floor and ceiling
    platforms.add(Platform(0, height - 1, width.toDouble(), 1));
    platforms.add(Platform(0, 0, width.toDouble(), 1));

    // Add random platforms based on level complexity
    final numPlatforms = 2 + (levelId % 5);

    for (int i = 0; i < numPlatforms; i++) {
      final x = random.nextDouble() * (width - 3);
      final y = 1 + random.nextDouble() * (height - 3);
      final w = 1 + random.nextDouble() * 2;
      final h = 1.0;

      platforms.add(Platform(x, y, w, h));
    }

    return platforms;
  }

  List<Platform> _generateComplexPlatforms(int levelId, math.Random random) {
    List<Platform> platforms = [];

    // Create more complex level layouts for secret levels
    platforms.add(Platform(0, 9, 12, 1)); // Floor
    platforms.add(Platform(0, 0, 12, 1)); // Ceiling

    // Add maze-like structures
    final numPlatforms = 8 + (levelId % 4);

    for (int i = 0; i < numPlatforms; i++) {
      final x = random.nextDouble() * 9;
      final y = 1 + random.nextDouble() * 7;
      final w = 1 + random.nextDouble() * 3;
      final h = 1.0;

      PlatformType type = PlatformType.solid;
      if (levelId > 35 && random.nextDouble() < 0.3) {
        type = PlatformType.breakable;
      } else if (levelId > 37 && random.nextDouble() < 0.2) {
        type = PlatformType.moving;
      }

      platforms.add(Platform(x, y, w, h, type: type));
    }

    return platforms;
  }

  List<MirrorPortal> _generatePortals(int levelId, math.Random random) {
    if (levelId < 10) return [];

    List<MirrorPortal> portals = [];

    if (levelId >= 15 && random.nextDouble() < 0.4) {
      portals.add(MirrorPortal(
        Position(2 + random.nextDouble() * 4, 2 + random.nextDouble() * 2),
        Position(4 + random.nextDouble() * 4, 3 + random.nextDouble() * 2),
      ));
    }

    return portals;
  }

  List<MirrorPortal> _generateAdvancedPortals(int levelId, math.Random random) {
    List<MirrorPortal> portals = [];

    final numPortals = 1 + (levelId % 3);

    for (int i = 0; i < numPortals; i++) {
      portals.add(MirrorPortal(
        Position(1 + random.nextDouble() * 8, 1 + random.nextDouble() * 6),
        Position(3 + random.nextDouble() * 8, 2 + random.nextDouble() * 6),
      ));
    }

    return portals;
  }

  List<LightSwitch> _generateLightSwitches(int levelId, math.Random random) {
    if (levelId < 20) return [];

    List<LightSwitch> switches = [];

    if (levelId >= 25 && random.nextDouble() < 0.3) {
      switches.add(LightSwitch(
        Position(2 + random.nextDouble() * 4, 3 + random.nextDouble() * 2),
        Color.values[random.nextInt(Color.values.length)],
        "switch_${levelId}_1",
      ));
    }

    return switches;
  }

  List<LightSwitch> _generateAdvancedLightSwitches(int levelId, math.Random random) {
    List<LightSwitch> switches = [];

    final numSwitches = 1 + (levelId % 2);

    for (int i = 0; i < numSwitches; i++) {
      switches.add(LightSwitch(
        Position(1 + random.nextDouble() * 8, 1 + random.nextDouble() * 6),
        Color.values[random.nextInt(Color.values.length)],
        "switch_${levelId}_$i",
      ));
    }

    return switches;
  }

  String _generateHint(int levelId) {
    final hints = [
      "Try using both worlds to your advantage!",
      "Remember: gravity can be different in each world.",
      "Look for the optimal path through mirrors.",
      "Sometimes you need to think backwards.",
      "The mirror world might have the solution.",
      "Use portals to teleport between distant locations.",
      "Light beams can create bridges in the mirror world.",
      "Perfect timing is key to success.",
      "Don't forget about gravity inversion!",
      "The shortest path isn't always the best path.",
    ];

    return hints[levelId % hints.length];
  }

  // Level Management Methods
  GameLevel getLevel(int index) {
    if (index < 0 || index >= _levels.length) {
      return _levels[0]; // Default to first level
    }
    return _levels[index];
  }

  GameLevel get currentLevel => _levels[_currentLevelIndex];

  int get totalLevels => _levels.length;

  int get currentLevelIndex => _currentLevelIndex;

  void setCurrentLevel(int index) {
    if (index >= 0 && index < _levels.length) {
      _currentLevelIndex = index;
    }
  }

  void nextLevel() {
    if (_currentLevelIndex < _levels.length - 1) {
      _currentLevelIndex++;
    }
  }

  void previousLevel() {
    if (_currentLevelIndex > 0) {
      _currentLevelIndex--;
    }
  }

  // Progress Tracking
  void completLevel(int levelId, int moves, double time) {
    _progress[levelId] = LevelProgress(
      levelId: levelId,
      completed: true,
      bestMoves: moves,
      bestTime: time,
      stars: _calculateStars(levelId, moves),
    );
  }

  int _calculateStars(int levelId, int moves) {
    final level = _levels.firstWhere((l) => l.id == levelId);
    if (moves <= level.parMoves) return 3;
    if (moves <= level.parMoves + 2) return 2;
    return 1;
  }

  LevelProgress? getProgress(int levelId) {
    return _progress[levelId];
  }

  bool isLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    if (levelId <= 30) return _progress[levelId - 1]?.completed ?? false;
    // Secret levels require perfect completion
    return _progress[levelId - 10]?.stars == 3;
  }

  int get totalStars {
    return _progress.values.fold(0, (sum, progress) => sum + progress.stars);
  }

  double get completionPercentage {
    final completed = _progress.values.where((p) => p.completed).length;
    return completed / _levels.length;
  }

  // Daily Challenge Generation
  GameLevel generateDailyChallenge(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = math.Random(seed);

    return GameLevel(
      id: -1, // Special ID for daily challenges
      name: "Daily Challenge",
      width: 8 + random.nextInt(4),
      height: 6 + random.nextInt(3),
      startPosition: Position(1, 4 + random.nextInt(2)),
      goal: Position(6 + random.nextInt(2), 1 + random.nextInt(2)),
      platforms: _generateRandomPlatforms(random),
      portals: _generateRandomPortals(random),
      lightSwitches: _generateRandomLightSwitches(random),
      parMoves: 8 + random.nextInt(6),
      hint: "Complete this daily challenge for bonus rewards!",
    );
  }

  List<Platform> _generateRandomPlatforms(math.Random random) {
    List<Platform> platforms = [];

    final width = 8 + random.nextInt(4);
    final height = 6 + random.nextInt(3);

    // Floor and ceiling
    platforms.add(Platform(0, height - 1, width.toDouble(), 1));
    platforms.add(Platform(0, 0, width.toDouble(), 1));

    // Random platforms
    final numPlatforms = 3 + random.nextInt(5);

    for (int i = 0; i < numPlatforms; i++) {
      platforms.add(Platform(
        random.nextDouble() * (width - 2),
        1 + random.nextDouble() * (height - 3),
        1 + random.nextDouble() * 2,
        1.0,
      ));
    }

    return platforms;
  }

  List<MirrorPortal> _generateRandomPortals(math.Random random) {
    List<MirrorPortal> portals = [];

    if (random.nextDouble() < 0.5) {
      portals.add(MirrorPortal(
        Position(2 + random.nextDouble() * 4, 2 + random.nextDouble() * 2),
        Position(4 + random.nextDouble() * 4, 3 + random.nextDouble() * 2),
      ));
    }

    return portals;
  }

  List<LightSwitch> _generateRandomLightSwitches(math.Random random) {
    List<LightSwitch> switches = [];

    if (random.nextDouble() < 0.3) {
      switches.add(LightSwitch(
        Position(2 + random.nextDouble() * 4, 3 + random.nextDouble() * 2),
        Color.values[random.nextInt(Color.values.length)],
        "daily_switch_1",
      ));
    }

    return switches;
  }
}

class LevelProgress {
  final int levelId;
  final bool completed;
  final int bestMoves;
  final double bestTime;
  final int stars;

  LevelProgress({
    required this.levelId,
    required this.completed,
    required this.bestMoves,
    required this.bestTime,
    required this.stars,
  });
}