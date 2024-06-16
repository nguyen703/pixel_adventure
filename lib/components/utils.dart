import 'dart:ui';

import 'package:flame/components.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';

bool checkCollision(
  PositionComponent player,
  PositionComponent block,
  CustomHitbox hitbox,
) {
  final playerRect = player.toRect();
  final bRect = block.toRect();

  // Adjust the hitbox to the player's position and size
  final playerHitbox = Rect.fromLTWH(
    playerRect.left + hitbox.offsetX,
    playerRect.top + hitbox.offsetY,
    hitbox.width,
    hitbox.height,
  );

  return playerHitbox.overlaps(bRect);
}

extension Velocity on Vector2 {
  bool isGoingLeft() => x < 0;
  bool isGoingRight() => x > 0;
}
