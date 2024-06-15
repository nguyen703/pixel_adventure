import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscapeLeftOnly();

  final PixelAdventure game = PixelAdventure();
  runApp(Focus(
      onKeyEvent: (_, __) =>
          KeyEventResult.handled, // Avoid beep sound on MacOS
      child: GameWidget(game: game)));
}
