import 'package:hive/hive.dart';

part 'game_state.g.dart';

@HiveType(typeId: 0)
class GameState {
  @HiveField(0)
  final int currentLevel;

  @HiveField(1)
  final Map<int, int> levelScores; // levelId: moveCount

  @HiveField(2)
  final Set<String> unlockedCosmetics;

  @HiveField(3)
  final int reflectionFeathers;

  GameState({
    required this.currentLevel,
    required this.levelScores,
    required this.unlockedCosmetics,
    required this.reflectionFeathers,
  });
}