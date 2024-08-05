import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_advanture/pixel_game.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  PixelAdventure pixelAdventure = PixelAdventure();
  runApp(GameWidget(game:kDebugMode ? PixelAdventure(): pixelAdventure));
}
