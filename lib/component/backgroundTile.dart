import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_advanture/pixel_game.dart';

class BackGroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;

  BackGroundTile({
    position,
    this.color = 'Gray',
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() async {
    priority=-1;
    size = Vector2.all(64.3);
    sprite = Sprite(game.images.fromCache("Background/$color.png"));
    return super.onLoad();
  }
}
