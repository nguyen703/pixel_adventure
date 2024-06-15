import 'dart:ui';

import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';

bool checkCollision(
    PositionComponent player, PositionComponent b, PlayerHitbox hitbox) {
  final playerRect = player.toRect();
  final bRect = b.toRect();

  // Adjust the hitbox to the player's position and size
  final aHitbox = Rect.fromLTWH(
    playerRect.left + hitbox.offsetX,
    playerRect.top + hitbox.offsetY,
    hitbox.width,
    hitbox.height,
  );

  return aHitbox.overlaps(bRect);
}

extension Velocity on Vector2 {
  bool isGoingLeft() => x < 0;
  bool isGoingRight() => x > 0;
}
