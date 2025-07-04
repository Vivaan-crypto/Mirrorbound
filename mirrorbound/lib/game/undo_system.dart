import 'package:flame/components.dart';
import 'package:mirrorbound/components/player.dart';
import 'package:mirrorbound/game/physics_engine.dart';

class GameState {
  final Vector2 playerPosition;
  final Vector2 playerVelocity;
  final bool mirrorGravityInverted;
  final bool playerInMirror;

  GameState({
    required this.playerPosition,
    required this.playerVelocity,
    required this.mirrorGravityInverted,
    required this.playerInMirror,
  });
}

class UndoSystem {
  final List<GameState> _history = [];
  static const maxHistory = 10;

  void saveState({
    required Player player,
    required MirrorPhysics physics,
  }) {
    if (_history.length >= maxHistory) {
      _history.removeAt(0);
    }

    _history.add(GameState(
      playerPosition: player.position.clone(),
      playerVelocity: player.velocity.clone(),
      mirrorGravityInverted: physics.mirrorGravityInverted,
      playerInMirror: player.inMirrorDimension,
    ));
  }

  void undo({
    required Player player,
    required MirrorPhysics physics,
  }) {
    if (_history.isEmpty) return;

    final state = _history.removeLast();
    player.position = state.playerPosition;
    player.velocity = state.playerVelocity;
    player.inMirrorDimension = state.playerInMirror;

    if (physics.mirrorGravityInverted != state.mirrorGravityInverted) {
      physics.invertMirrorGravity();
    }
  }
}