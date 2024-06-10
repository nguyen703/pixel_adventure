import 'package:flame/components.dart';

bool checkCollision(PositionComponent a, PositionComponent b) {
  final aRect = a.toRect();
  final bRect = b.toRect();

  return aRect.overlaps(bRect);
}
