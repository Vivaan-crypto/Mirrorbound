import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:mirrorbound/utils/constants.dart';

class Player extends SpriteComponent with HasGameRef {
  Vector2 velocity = Vector2.zero();
  bool inMirrorDimension = false;
  bool isJumping = false;
  String currentSkin = 'default';

  Player() : super(size: Vector2(32, 64));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('player.png');
    anchor = Anchor.center;
  }

  void move(double dx) {
    velocity.x = dx * Constants.playerSpeed;
  }

  void jump() {
    if (!isJumping) {
      velocity.y = Constants.jumpForce;
      isJumping = true;
      add(ScaleEffect.to(
        Vector2(1.2, 0.8),
        EffectController(duration: 0.1),
      )..onComplete = () {
        add(ScaleEffect.to(
          Vector2(1, 1),
          EffectController(duration: 0.1),
        ));
      });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }
}