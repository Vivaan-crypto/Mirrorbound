import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:mirrorbound/components/player.dart';
import 'package:mirrorbound/game/level_manager.dart';
import 'package:mirrorbound/game/physics_engine.dart';
import 'package:mirrorbound/game/undo_system.dart';

class MirrorBoundGame extends FlameGame with HasCollisionDetection, HasTapDetector, HasPanDetector {
  final int levelId;
  late Player player;
  late MirrorPhysics physics;
  late UndoSystem undoSystem;

  MirrorBoundGame(this.levelId);

  @override
  Future<void> onLoad() async {
    physics = MirrorPhysics();
    undoSystem = UndoSystem();

    final level = await LevelManager.loadLevel(levelId);

    player = Player()
      ..position = level.playerStart
      ..priority = 10;

    add(player);
    addAll(level.platforms);
    addAll(level.mirrors);
    addAll(level.hazards);

    camera.follow(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    physics.updatePlayerPosition(player, dt);
  }

  void mirrorSplit(Vector2 position) {
    // Mirror splitting logic
  }

  void invertGravity() {
    physics.invertMirrorGravity();
    undoSystem.saveState(
      player: player,
      physics: physics,
    );
  }

  @override
  void onTap() {
    player.jump();
    undoSystem.saveState(
      player: player,
      physics: physics,
    );
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    final delta = info.delta.global;
    player.move(delta.x > 0 ? 1 : -1);
  }
}