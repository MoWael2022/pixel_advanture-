import 'dart:async';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_advanture/component/player.dart';
import 'package:pixel_advanture/component/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() {
    return const Color(0xFF211F30);
  }

  late JoystickComponent joystick;
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  List<String> levelName = ["level01", "level01"];
  int currentLevelIndex = 0;
  bool playSound =true ;
  double soundVolume = 1.0;

  void addJoyStick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png')),
      ),
      knobRadius: 32,
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 25, bottom: 32),
    );
  }

  @override
  FutureOr<void> onLoad() async {

    // Load images to cache
    await images.loadAllImages();

    // Create the world and add it

    _loadLevel();
    addJoyStick();
    add(joystick);
    // Initialize and add joystick

    return super.onLoad();
  }

  @override
  void update(double dt) {
    //d_updateJoyStickMovement();
    super.update(dt);
  }

  void _updateJoyStickMovement() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelName.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      // game over;
      currentLevelIndex =0;
      _loadLevel();

    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level world = Level(
        player: player,
        levelName: levelName[currentLevelIndex],
      );

      cam = CameraComponent.withFixedResolution(
          width: 640, height: 360, world: world);
      cam.viewfinder.anchor = Anchor.topLeft;
      add(cam);

      world.add(player);
      add(world);
    });
  }
}
