import 'dart:math' as math;
import 'package:flame/components.dart';

Vector2 rotateVector(Vector2 vector, double angle) {
  final cos = math.cos(angle);
  final sin = math.sin(angle);
  return Vector2(
    vector.x * cos - vector.y * sin,
    vector.x * sin + vector.y * cos,
  );
}

double distance(Vector2 a, Vector2 b) {
  return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));
}

bool circlesOverlap(Vector2 center1, double radius1, Vector2 center2, double radius2) {
  final distance = (center1 - center2).length;
  return distance < radius1 + radius2;
}