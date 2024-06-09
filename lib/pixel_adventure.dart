import 'dart:async';
import 'dart:io';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/levels/level.dart';

const _worldPriority = 1000;

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  PixelAdventure();

  late final CameraComponent cam;
  late JoystickComponent joystick;

  final player = Player();
  final bool showJoystick = Platform.isAndroid || Platform.isIOS;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final world = Level(levelName: 'level-01', player: player);

    cam = CameraComponent(
      viewport: FixedResolutionViewport(resolution: Vector2(640, 360)),
      world: world,
    );
    cam.priority = _worldPriority;
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);

    if (showJoystick) addJoyStick();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) _updateJoystick();
    super.update(dt);
  }

  void addJoyStick() {
    joystick = JoystickComponent(
      margin: EdgeInsets.only(left: 100, bottom: 100),
      knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      knobRadius: 64,
      background:
          SpriteComponent(sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
    );
    joystick.priority = _worldPriority + 1; // make sure it's always on top
    add(joystick);
  }

  void _updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.right ||
            JoystickDirection.upRight ||
            JoystickDirection.downRight:
        player.playerDirection = PlayerDirection.right;
      case JoystickDirection.left ||
            JoystickDirection.upLeft ||
            JoystickDirection.downLeft:
        player.playerDirection = PlayerDirection.left;
      case JoystickDirection.idle:
        player.playerDirection = PlayerDirection.none;
      default:
    }
  }
}
