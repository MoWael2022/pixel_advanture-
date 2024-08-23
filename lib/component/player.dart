import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_advanture/component/checkPoint.dart';
import 'package:pixel_advanture/component/chicken.dart';
import 'package:pixel_advanture/component/player_hitbox.dart';
import 'package:pixel_advanture/component/saw.dart';
import 'package:pixel_advanture/component/utils.dart';
import 'package:pixel_advanture/pixel_game.dart';

import 'collesion_class.dart';
import 'fruit.dart';

enum PlayerState {
  idle,
  running,
  falling,
  jumping,
  hit,
  appearing,
  disappearing,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;

  Player({position, this.character = 'Musk Dude'}) : super(position: position);
  late SpriteAnimation idleAnimation;
  late SpriteAnimation runAnimation;
  late SpriteAnimation fallingAnimation;
  late SpriteAnimation jumpingAnimation;
  late SpriteAnimation hitAnimation;
  late SpriteAnimation appearingAnimation;
  late SpriteAnimation disappearingAnimation;
  final double stepTime = .05;

  //PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100; // Adjusted move speed
  Vector2 velocity = Vector2.zero();
  bool isRight = true;
  double horizontalMovement = 0;
  bool goHit = false;
  Vector2 playerStartPosition = Vector2.zero();
  bool playerReachCheckPoint = false;
  List<CollisionBlock> collisionBlock = [];
  final double _gravity = 9.8;
  final double _terminalVelocity = 300;
  final double _jumpForce = 300;
  bool isOnGround = false;
  bool isJump = false;
  double fixedDeltaTime = 1 / 60;
  double accumulateTime = 0;

  CustomHitBox playerHitBox = CustomHitBox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  @override
  bool onKeyEvent(event, Set<LogicalKeyboardKey> keysPressed) {
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

  // @override
  // void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   if (!playerReachCheckPoint) {
  //     if (other is Fruit) {
  //       other.collidedFruit();
  //     }
  //     if (other is Saw) _reSpawn();
  //
  //     if (other is CheckPoint) _playerReachCheckPoint();
  //   }
  //   super.onCollision(intersectionPoints, other);
  // }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!playerReachCheckPoint) {
      if (other is Fruit) {
        other.collidedFruit();
      }
      if (other is Saw) _reSpawn();
      if (other is Chicken) other.collidedWithPlayer();

      if (other is CheckPoint) _playerReachCheckPoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  FutureOr<void> onLoad() {
    _loadPlayerAnimation();
    //debugMode = true;
    playerStartPosition = Vector2(position.x, position.y);

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
    hitAnimation = _spriteAnimation('Hit', 7)..loop = false;
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);

    //all animation
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
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

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache("Main Characters/$state (96x96).png"),
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(96),
          loop: false,
        ));
  }

  @override
  void update(double dt) {
    accumulateTime+= dt;
    while(accumulateTime >= fixedDeltaTime){
      if (!goHit && !playerReachCheckPoint) {
        _updatePlayerState();
        _updatePlayerAnimation(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulateTime -= fixedDeltaTime;
    }

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
    if(game.playSound) FlameAudio.play('jump.wav',volume: game.soundVolume);
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
            position.x = block.x +
                block.width +
                playerHitBox.offsetX +
                playerHitBox.width;
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
            position.y = block.y - playerHitBox.offsetY - playerHitBox.height;
            ;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - playerHitBox.offsetY;
          }
        }
      }
    }
  }

  void _reSpawn() async {
    if(game.playSound) FlameAudio.play('hit.wav',volume: game.soundVolume);
    const hitDuration = Duration(milliseconds: 350);
    const appearingDuration = Duration(milliseconds: 350);
    goHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();
    scale.x = 1;
    position = playerStartPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();
    velocity = Vector2.zero();
    position = playerStartPosition;
    _updatePlayerState();
    goHit = false;



    //position =playerStartPosition;
  }

  void _playerReachCheckPoint() {
    if(game.playSound) FlameAudio.play('disappear.wav',volume: game.soundVolume);
    playerReachCheckPoint = true;
    if (scale.x > 0) {
      position -= Vector2.all(32);
    } else if (scale.x < 0) {
      position += Vector2(32, -32);
    }
    current = PlayerState.disappearing;

    const reachedCheckPointDuration = Duration(milliseconds: 350);
    Future.delayed(reachedCheckPointDuration, () {
      playerReachCheckPoint = false;
      position = Vector2.all(-1000);
    });
    const waitToChangeToNextLevel = Duration(seconds: 3);
    Future.delayed(waitToChangeToNextLevel, () => game.loadNextLevel());
  }
  collidedWithEnemy() => _reSpawn();
}
