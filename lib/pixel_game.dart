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
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() {
    return const Color(0xFF211F30);
  }

  late JoystickComponent joystick;
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');

  @override
  FutureOr<void> onLoad() async {
    // Load images to cache
    await images.loadAllImages();


    // Create the world and add it
    final world = Level(
      player: player,
      levelName: "level01",

    );

    cam = CameraComponent.withFixedResolution(
        width: 640, height: 360, world: world);
    cam.viewfinder.anchor = Anchor.topLeft;
    add(cam);



    world.add(player);
    add(world);


    // Initialize and add joystick
    addJoyStick();
    add(joystick);
    return super.onLoad();
  }
  @override
  void update(double dt) {
    //d_updateJoyStickMovement();
    super.update(dt);
  }

  void addJoyStick() {
    joystick = JoystickComponent(
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

  void _updateJoyStickMovement() {
    switch(joystick.direction){
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
      default :
        player.horizontalMovement = 0;


    }
  }
}
