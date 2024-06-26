import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, jump, doubleJump, wallJump, run, fall, hit, appearing }

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  Player({position, this.character = 'Ninja Frog'}) : super(position: position);

  String character;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;

  final double stepTime = 0.05;
  final double _gravity = 9.8;
  final double _jumpForce = 620;
  final double _terminalVelocity = 300;
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;

  double horizontalMovement = 0.0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 4,
    offsetY: 6,
    width: 24,
    height: 26,
  );

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    startingPosition = position.clone();
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit) {
      _updatePlayerState();
      _updatePlayerMovement(dt);
      _checkHorizontalCollision();
      _applyGravity(dt);
      _checkVerticalCollision();
    }

    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Saw) _respawn();
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // if (other is Saw) _respawn();

    super.onCollision(intersectionPoints, other);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
            keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
            keysPressed.contains(LogicalKeyboardKey.keyD);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    if (isOnGround) {
      velocity.y = -_jumpForce;
      position.y += velocity.y * dt;
      isOnGround = false;
      hasJumped = false;
    }
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.isGoingLeft() && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.isGoingRight() && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x != 0) playerState = PlayerState.run;

    if (velocity.y < 0) {
      playerState = PlayerState.jump;
    } else if (velocity.y > 0) {
      if (velocity.y > 0) playerState = PlayerState.fall;
    }

    current = playerState;
  }

  void _checkHorizontalCollision() {
    for (final block in collisionBlocks) {
      if (checkCollision(this, block, hitbox)) {
        if (block.isPlatform) {
          // Check if player is on top of the platform
        } else {
          if (velocity.isGoingRight()) {
            position.x = block.x - hitbox.offsetX - hitbox.width;
          } else if (velocity.isGoingLeft()) {
            position.x = block.x + block.width + hitbox.offsetX + hitbox.width;
          }
        }
      }
    }
  }

  void _checkVerticalCollision() {
    for (final block in collisionBlocks) {
      if (checkCollision(this, block, hitbox)) {
        if (block.isPlatform) {
          if (velocity.y > 0) {
            if (position.y + hitbox.height < block.y + block.height) {
              position.y = block.y - height;
              velocity.y = 0;
              isOnGround = true;
              break;
            }
          }
        } else {
          if (velocity.y > 0) {
            position.y = block.y - height;
            velocity.y = 0;
            isOnGround = true;
            break;
          } else if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity * _terminalVelocity * dt;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runAnimation = _spriteAnimation('Run', 12);
    jumpAnimation = _spriteAnimation('Jump', 1);
    fallAnimation = _spriteAnimation('Fall', 1);
    hitAnimation = _spriteAnimation('Hit', 7, loop: false);
    appearingAnimation = _specialAnimation('Appearing', 7, loop: false);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _specialAnimation(String state, int amount,
      {bool loop = true}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: loop,
      ),
    );
  }

  SpriteAnimation _spriteAnimation(String state, int amount,
      {bool loop = true}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: loop,
      ),
    );
  }

  void _respawn() {
    gotHit = true;
    current = PlayerState.hit;

    final hitAnimation = animationTickers![PlayerState.hit]!;
    hitAnimation.completed.whenComplete(() {
      current = PlayerState.appearing;
      scale.x = 1;
      position = startingPosition - Vector2.all(32);
      hitAnimation.reset();

      final appearingAnimation = animationTickers![PlayerState.appearing]!;
      appearingAnimation.completed.whenComplete(() {
        velocity = Vector2.zero();
        position = startingPosition;
        current = PlayerState.idle;
        appearingAnimation.reset();
        gotHit = false;
      });
    });
  }
}
