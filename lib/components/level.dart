import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player.dart';

class Level extends World {
  Level({super.key, required this.player, required this.levelName});

  late TiledComponent level;
  final String levelName;
  final Player player;
  List<CollisionBlock> collisionsBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      '$levelName.tmx',
      Vector2.all(16.0),
    );

    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
        }
      }
    }

    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: collision.position,
              size: collision.size,
              isPlatform: true,
            );

            collisionsBlocks.add(platform);
            add(platform);
          default:
            final block = CollisionBlock(
              position: collision.position,
              size: collision.size,
            );

            collisionsBlocks.add(block);
            add(block);
        }
      }
    }

    player.collisionBlocks = collisionsBlocks;

    return super.onLoad();
  }
}
