import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flame/input.dart'; // Added for TapCallbacks
import 'package:mirrorbound/game/color_engine.dart';
import 'package:mirrorbound/utils/constants.dart';
import 'package:mirrorbound/utils/haptics.dart';

class MirrorPortal extends SpriteComponent with TapCallbacks { // Changed to TapCallbacks
  final ColorEngine colorEngine;
  bool isActive = false;
  bool isRealWorld = true;

  MirrorPortal({
    required this.colorEngine,
    required this.isRealWorld,
    required Vector2 position,
  }) : super(position: position, size: Vector2(64, 64));

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('mirror_portal.png'); // Changed to game
    _addParticles();
  }

  void _addParticles() {
    final particleColor = isRealWorld
        ? Constants.realWorldColors.first
        : Constants.mirrorWorldColors.first;

    add(ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        lifespan: 1.5,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 50),
          speed: Vector2(0, -100),
          position: size / 2,
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = Color(particleColor),
          ),
        ),
      ),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) { // Updated method signature
    isActive = !isActive;
    colorEngine.activateMirror(this);
    triggerHapticFeedback();
  }
}