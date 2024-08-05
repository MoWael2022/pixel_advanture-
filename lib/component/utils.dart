import 'package:pixel_advanture/component/collesion_class.dart';
import 'package:pixel_advanture/component/player.dart';

bool checkCollision(player,block) {
  final playerHitBox = player.playerHitBox;
  final playerX = player.position.x + playerHitBox.offsetX;
  final playerY = player.position.y + playerHitBox.offsetY;
  final playerWidth = playerHitBox.width;
  final playerHeight = playerHitBox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0
      ? playerX  - (playerHitBox.offsetX * 2) - playerWidth
      : playerX;
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX);
}
