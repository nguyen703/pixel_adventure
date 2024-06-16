import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/rendering.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';

class Level extends World with HasGameReference {
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

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    final backgroundColor =
        backgroundLayer?.properties.getValue('BackgroundColor');
    if (backgroundColor == null) return;

    final background = ParallaxComponent(
      priority: -1,
      parallax: Parallax([
        ParallaxLayer(
          ParallaxImage(
            game.images.fromCache('Background/$backgroundColor.png'),
            repeat: ImageRepeat.repeat,
            fill: LayerFill.none,
          ),
        ),
      ], baseVelocity: Vector2(0, -50)),
    );

    add(background);
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: spawnPoint.position,
              size: spawnPoint.size,
            );

            add(fruit);
        }
      }
    }
  }

  void _addCollisions() {
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
  }
}
