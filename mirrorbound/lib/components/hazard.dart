import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:mirrorbound/components/player.dart';
import 'package:mirrorbound/utils/haptics.dart';

class Hazard extends PositionComponent with CollisionCallbacks {
  Hazard({
    required super.position,
    required super.size,
  });

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      // Handle player death
      triggerErrorHaptic();
    }
  }
}