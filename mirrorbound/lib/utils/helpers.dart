import 'dart:math';
import 'package:vector_math/vector_math.dart';

Vector2 rotateVector(Vector2 vector, double angle) {
  final rotationMatrix = Matrix2.rotation(angle);
  return rotationMatrix.transform(vector);
}

double distance(Vector2 a, Vector2 b) {
  return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
}

bool circlesOverlap(Vector2 center1, double radius1, Vector2 center2, double radius2) {
  final distance = (center1 - center2).length;
  return distance < radius1 + radius2;
}