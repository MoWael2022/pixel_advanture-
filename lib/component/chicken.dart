import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_advanture/component/player.dart';
import 'package:pixel_advanture/pixel_game.dart';

enum ChickenState {
  idle,
  run,
  hit,
}

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  int offPos;
  int offNeg;

  Chicken({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  late SpriteAnimation _idleAnimation;
  late SpriteAnimation _runAnimation;
  late SpriteAnimation _hitAnimation;
  late final Player player;

  double stepTime = 0.04;
  Vector2 textureSize = Vector2(32, 34);
  Vector2 velocity = Vector2.zero();

  static const double tileSize = 16;
  static const double runSpeed = 80;
  static const double _bounceHeight = 260.0;
  double negRange = 0;
  double posRange = 0;
  double moveDirection = 1;

  double targetDirection = -1;
  bool gotStomped = false;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    add(RectangleHitbox(
      position: Vector2(4, 6),
      size: Vector2(24, 26),
    ));

    player = game.player;
    _loadAllAnimation();
    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      _updateState();
      _movement(dt);
    }
    super.update(dt);
  }

  void _loadAllAnimation() {
    _idleAnimation = _loadSpriteAnimation("Idle", 13);
    _runAnimation = _loadSpriteAnimation("Run", 14);
    _hitAnimation = _loadSpriteAnimation("Hit", 5)..loop=false;

    animations = {
      ChickenState.idle: _idleAnimation,
      ChickenState.run: _runAnimation,
      ChickenState.hit: _hitAnimation,
    };
    current = ChickenState.idle;
  }

  SpriteAnimation _loadSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Chicken/$state (32x34).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void _calculateRange() {
    negRange = position.x - offNeg * tileSize;
    posRange = position.x + offPos * tileSize;
  }

  void _movement(dt) {
    // set velocity to 0;
    velocity.x = 0;

    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double chickenOffset = (scale.x > 0) ? 0 : -width;

    if (_playerInRange()) {
      // player in range
      targetDirection =
          (player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * runSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt;
  }

  bool _playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= negRange &&
        player.x + playerOffset <= posRange &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void _updateState() {
    current = (velocity.x != 0) ? ChickenState.run : ChickenState.idle;

    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if(game.playSound){
        FlameAudio.play("bounce.wav",volume: game.soundVolume);
      }
      gotStomped = true;
      current =ChickenState.hit ;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    }else {
      player.collidedWithEnemy();
    }
  }
}
