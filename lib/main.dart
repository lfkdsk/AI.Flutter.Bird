import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bird/game/game.dart';

void main() async {
  // initial settings
  Flame.audio.disableLog();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIOverlays([]);

  var sprite = await Flame.images.loadAll(["sprite.png"]);
  var screenSize = await Flame.util.initialDimensions();
  Singleton.instance.screenSize = screenSize;
  var flutterBirdGame = FlutterBirdGame(sprite[0], screenSize);
  runApp(MaterialApp(
    title: 'FlutterBirdGame',
    home: Scaffold(
      body: GameWrapper(flutterBirdGame),
    ),
  ));

  Flame.util.addGestureRecognizer(
    new TapGestureRecognizer()
      ..onTapDown = (TapDownDetails evt) => flutterBirdGame.onTap(),
  );
}

class GameWrapper extends StatelessWidget {
  final FlutterBirdGame flutterBirdGame;

  GameWrapper(this.flutterBirdGame);

  @override
  Widget build(BuildContext context) {
    return flutterBirdGame.widget;
  }
}

class Singleton {
  Size screenSize;

  Singleton._privateConstructor();

  static final Singleton instance = Singleton._privateConstructor();
}
