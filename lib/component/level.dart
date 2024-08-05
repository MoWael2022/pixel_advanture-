import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_advanture/component/backgroundTile.dart';
import 'package:pixel_advanture/component/player.dart';

import '../pixel_game.dart';
import 'collesion_class.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  late TiledComponent level;

  String levelName;

  Player player;

  Level({required this.levelName, required this.player});

  List<CollisionBlock> collisionBlock = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    _backgroundObject();
    _spawnObject();
    _collisionObject();


    return super.onLoad();
  }

  void _spawnObject() {
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    for (final spawnPoint in spawnPointLayer!.objects) {
      switch (spawnPoint.class_) {
        case "Player":
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
          break;
        default:
      }
    }
  }

  void _collisionObject() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('collision');

    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        switch (collision.class_) {
          case "platform":
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlock.add(platform);
            add(platform);
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlock.add(block);
            add(block);
        }
        player.collisionBlock = collisionBlock;
      }
    }
  }

  void _backgroundObject() {
    final backGroundLayer = level.tileMap.getLayer("background");

    const tileSize = 64;
    final numOfTileY = (game.size.y / tileSize).floor();
    final numOfTileX = (game.size.x / tileSize).floor();

    if (backGroundLayer != null) {
      final backGroundColor =
          backGroundLayer.properties.getValue("BackGroundColor");
      for (double y = 0; y < numOfTileY; y++) {
        for (double x = 0; x < numOfTileX; x++) {
          final backGroundTile = BackGroundTile(
            position: Vector2(x * tileSize - tileSize, y * tileSize - tileSize),
            color: backGroundColor ?? "Gray",
          );
          add(backGroundTile);
        }
      }
    }
  }
}
