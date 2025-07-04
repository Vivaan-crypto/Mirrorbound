import 'package:vector_math/vector_math.dart';

class Constants {
  static const double playerSpeed = 200;
  static const double jumpForce = -650;
  static Vector2 baseGravity = Vector2(0, 1800);

  // Color palettes
  static const realWorldColors = [0xFF6A8EAE, 0xFF9B5DE5, 0xFF00BBF9];
  static const mirrorWorldColors = [0xFFFF6B6B, 0xFFFF9E6B, 0xFFFFD166];

  // Level constants
  static const levelCount = 30;
  static const dailyTrialCount = 10;
}