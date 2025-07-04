import 'package:flame/collisions.dart';
import 'package:mirrorbound/components/player.dart';
import 'package:mirrorbound/utils/constants.dart';
import 'package:vector_math/vector_math.dart';

class MirrorPhysics {
  Vector2 realWorldGravity = Constants.baseGravity;
  Vector2 mirrorWorldGravity = Constants.baseGravity;
  bool mirrorGravityInverted = false;

  void invertMirrorGravity() {
    mirrorWorldGravity = Vector2(
        mirrorWorldGravity.x,
        -mirrorWorldGravity.y
    );
    mirrorGravityInverted = !mirrorGravityInverted;
  }

  void updatePlayerPosition(Player player, double dt) {
    if (player.inMirrorDimension) {
      player.velocity.y += mirrorWorldGravity.y * dt;
    } else {
      player.velocity.y += realWorldGravity.y * dt;
    }

    // Apply friction
    player.velocity.x *= 0.9;

    // Reset jumping state when on ground
    if (player.velocity.y > 0 && player.isJumping) {
      player.isJumping = false;
    }
  }
}