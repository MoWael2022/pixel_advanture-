import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_advanture/component/player_hitbox.dart';
import 'package:pixel_advanture/component/utils.dart';
import 'package:pixel_advanture/pixel_game.dart';

import 'collesion_class.dart';

enum PlayerState {
  idle,
  running,
  falling,
  jumping,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;

  Player({position, this.character = 'Musk Dude'}) : super(position: position);
  late SpriteAnimation idleAnimation;
  late SpriteAnimation runAnimation;
  late SpriteAnimation fallingAnimation;
  late SpriteAnimation jumpingAnimation;
  final double stepTime = .05;

  //PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100; // Adjusted move speed
  Vector2 velocity = Vector2.zero();
  bool isRight = true;
  double horizontalMovement = 0;
  List<CollisionBlock> collisionBlock = [];
  final double _gravity = 9.8;
  final double _terminalVelocity = 300;
  final double _jumpForce = 300;
  bool isOnGround = false;
  bool isJump = false;

  PlayerHitBox playerHitBox = PlayerHitBox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isKeyLeftPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
            keysPressed.contains(LogicalKeyboardKey.keyA);
    final isKeyRightPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
            keysPressed.contains(LogicalKeyboardKey.keyD);

    isJump = keysPressed.contains(LogicalKeyboardKey.keyZ);

    horizontalMovement += isKeyLeftPressed ? -1 : 0;
    horizontalMovement += isKeyRightPressed ? 1 : 0;

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  FutureOr<void> onLoad() {
    _loadPlayerAnimation();
    debugMode = true;
    add(RectangleHitbox(
      position: Vector2(playerHitBox.offsetX, playerHitBox.offsetY),
      size: Vector2(playerHitBox.width, playerHitBox.height),
    ));
    return super.onLoad();
  }

  void _loadPlayerAnimation() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runAnimation = _spriteAnimation('Run', 12);
    fallingAnimation = _spriteAnimation('Fall', 1);
    jumpingAnimation = _spriteAnimation('Jump', 1);

    //all animation
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation
    };

    //current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache("Main Characters/$character/$state (32x32).png"),
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
        ));
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerAnimation(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  void _updatePlayerAnimation(double dt) {
    // double directionX = 0.0;
    // switch (playerDirection) {
    //   case PlayerDirection.right:
    //     if (!isRight) {
    //       flipHorizontallyAroundCenter();
    //       isRight = true;
    //     }
    //     current = PlayerState.running;
    //     directionX += 1; // Set to 1 for normalized movement
    //     break;
    //   case PlayerDirection.left:
    //     if (isRight) {
    //       flipHorizontallyAroundCenter();
    //       isRight = false;
    //     }
    //     current = PlayerState.running;
    //     directionX -= 1; // Set to -1 for normalized movement
    //     break;
    //   case PlayerDirection.none:
    //     current = PlayerState.idle;
    //     break;
    //   default:
    // }
    if (isJump && isOnGround) _jump(dt);

    //if(velocity.y > _gravity) isOnGround =false;

    velocity.x = horizontalMovement * moveSpeed; // Scale velocity by dt

    position.x += velocity.x * dt;
  }

  void _jump(dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    isJump = false;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }
    if (velocity.y > 0) {
      playerState = PlayerState.falling;
    }
    if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlock) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - playerHitBox.offsetX - playerHitBox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width +playerHitBox.offsetX +playerHitBox.width;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlock) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - playerHitBox.offsetY - playerHitBox.height;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - playerHitBox.offsetY - playerHitBox.height;;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - playerHitBox.offsetY   ;
          }
        }
      }
    }
  }
}
