import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Platform extends PositionComponent with CollisionCallbacks {
  Platform({
    required super.position,
    required super.size,
  });

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }
}