import 'dart:async';

import 'package:flame/collisions.dart';

import 'package:flame/components.dart';
import 'package:pixel_advanture/component/player.dart';
import 'package:pixel_advanture/pixel_game.dart';

class CheckPoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  CheckPoint({position, size}) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
      position: Vector2(18, 56),
      size: Vector2(12, 8),
    ));
    animation = SpriteAnimation.fromFrameData(
      game.images
          .fromCache("Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png"),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  // @override
  // void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   if(other is Player && !reachCheckedPoint) _reachedPoint();
  //   super.onCollision(intersectionPoints, other);
  // }
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Player ) _reachedPoint();
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedPoint() async{

    animation =SpriteAnimation.fromFrameData(
      game.images
          .fromCache("Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png"),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );
    await animationTicker?.completed;
    animation =SpriteAnimation.fromFrameData(
      game.images
          .fromCache("Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png"),
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
      ),
    );


  }
}
