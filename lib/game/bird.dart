import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_bird/game/config.dart';
import 'package:flutter_bird/game/network.dart';
import 'package:flutter_bird/game/data.dart' as Data;
import 'package:flutter_bird/main.dart';

enum BirdStatus { waiting, flying }
enum BirdFlyingStatus { up, down, none }

class Bird extends PositionComponent with ComposedComponent {
  int _counter = 0;
  int _movingUpSteps = 15;
  double _heightDiff = 0.0;
  double _stepDiff = 0.0;

  BirdGround ground;
  BirdStatus status = BirdStatus.waiting;
  BirdFlyingStatus flyingStatus = BirdFlyingStatus.none;

  // network needed
  NetWork netWork = new NetWork();
  int fitness = 0;
  double speed = 0;
  int score = 0;
  bool alive = true;

  static List<Sprite> lazyLoadSprites;
  static Size screenSize;

  Bird(Image spriteImage, Size screenSize) {
    screenSize = screenSize;
    if (lazyLoadSprites == null) {
      lazyLoadSprites = [
        Sprite.fromImage(
          spriteImage,
          width: SpriteDimensions.birdWidth,
          height: SpriteDimensions.birdHeight,
          y: SpritesPostions.birdSprite1Y,
          x: SpritesPostions.birdSprite1X,
        ),
        Sprite.fromImage(
          spriteImage,
          width: SpriteDimensions.birdWidth,
          height: SpriteDimensions.birdHeight,
          y: SpritesPostions.birdSprite2Y,
          x: SpritesPostions.birdSprite2X,
        ),
        Sprite.fromImage(
          spriteImage,
          width: SpriteDimensions.birdWidth,
          height: SpriteDimensions.birdHeight,
          y: SpritesPostions.birdSprite3Y,
          x: SpritesPostions.birdSprite3X,
        )
      ];
    }

    var animatedBird =
        new Animation.spriteList(lazyLoadSprites, stepTime: 0.15);
    this.ground = BirdGround(animatedBird);
    this.init();
    this.add(ground);
  }

  factory Bird.clone(Bird bird) {
    Bird other = new Bird(null, screenSize);
    return other;
  }

  void init() {
    this.fitness = 0;
    this.score = 0;
    this.setPosition(ComponentPositions.birdX, ComponentPositions.birdY);
    this.speed = 0;
    this.alive = true;
  }

  void setPosition(double x, double y) {
    this.ground.x = x;
    this.ground.y = y;
  }

  void update(double t) {
    if (alive) {
      _counter++;
      fitness++;

//      if (_counter <= _movingUpSteps) {
//        flyingStatus = BirdFlyingStatus.up;
//        this.ground.showAnimation = true;
//        this.ground.angle -= 0.01;
//        this.ground.y -= t * 100 * getSpeedRatio(flyingStatus, _counter);
//      } else {
//        flyingStatus = BirdFlyingStatus.down;
//        this.ground.showAnimation = false;
//
//        if (_heightDiff == 0)
//          _heightDiff = (_screenSize.height - this.ground.y);
//        if (_stepDiff == 0)
//          _stepDiff = this.ground.angle.abs() / (_heightDiff / 10);
//
//        this.ground.angle += _stepDiff;
//        this.ground.y += t * 100 * getSpeedRatio(flyingStatus, _counter);
//      }
      this.ground.showAnimation = this.speed > 0 ? true : false;
    }

    this.ground.y += this.speed;
    this.ground.update(t);
  }

  double getSpeedRatio(BirdFlyingStatus flyingStatus, int counter) {
    if (flyingStatus == BirdFlyingStatus.up) {
      var backwardCounter = _movingUpSteps - counter;
      return backwardCounter / 10.0;
    }
    if (flyingStatus == BirdFlyingStatus.down) {
      var diffCounter = counter - _movingUpSteps;
      return diffCounter / 10.0;
    }
    return 0.0;
  }

  void jump() {
    Flame.audio.play('wing.wav');
    status = BirdStatus.flying;
    _counter = 0;
    this.ground.angle = 0;
  }

  void jumpWithNetwork(pipeDis, pipeUpper, pip2Upper) {
    if (netWork.getOutput(
      pipeDis / Singleton.instance.screenSize.width,
      (this.ground.y - SpriteDimensions.birdHeight - pipeUpper) / Singleton.instance.screenSize.height,
      0,
    )) {
      this.speed = -Data.Game.FLY_SPEED;
    }

    this.speed += Data.Game.GRAVITY;
  }
}

class BirdGround extends AnimationComponent {
  bool showAnimation = true;

  BirdGround(Animation animation)
      : super(
          ComponentDimensions.birdWidth,
          ComponentDimensions.birdHeight,
          animation,
        );

  @override
  void update(double t) {
    if (showAnimation) {
      super.update(t);
    }
  }
}
