import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LightSwitch extends SpriteComponent {
  final Color requiredColor;
  bool isActivated = false;

  LightSwitch({
    required this.requiredColor,
    required Vector2 position,
  }) : super(position: position, size: Vector2(32, 32));

  void checkActivation(Color currentColor) {
    isActivated = currentColor.value == requiredColor.value;
    // Update appearance based on activation state
  }
}