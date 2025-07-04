import 'dart:ui';

import 'package:flame/components.dart';
import 'package:mirrorbound/game/color_engine.dart';

class LightBeam extends PositionComponent {
  final Color color;
  final ColorEngine colorEngine;

  LightBeam({
    required this.color,
    required this.colorEngine,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    colorEngine.addBeam(this);
  }

  @override
  void onRemove() {
    colorEngine.removeBeam(this);
    super.onRemove();
  }
}