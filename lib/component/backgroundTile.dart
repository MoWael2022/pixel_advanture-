import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/src/parallax.dart';
import 'package:flutter/cupertino.dart';
import 'package:pixel_advanture/pixel_game.dart';

class BackGroundTile extends ParallaxComponent<PixelAdventure> {
  final String color;

  BackGroundTile({
    position,
    this.color = 'Gray',
  }) : super(position: position);

  final double scrollSpeed = 40;

  @override
  FutureOr<void> onLoad() async {
    priority = -10;
    size = Vector2.all(64);
    parallax = await game.loadParallax(
      [
        ParallaxImageData("Background/$color.png"),
      ],
      baseVelocity: Vector2(0, -scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    ) ;
    //sprite = Sprite(game.images.fromCache("Background/$color.png"));
    return super.onLoad();
  }

// @override
// void update(double dt) {
//   position.y += scrollSpeed;
//   double tileSize = 64;
//   int scrollHeight = (game.size.y / tileSize).floor();
//   if(position.y > scrollHeight * tileSize) position.y = -tileSize;
//   super.update(dt);
// }
}
