import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_bird/game/bird.dart';
import 'package:flutter_bird/game/bottom.dart';
import 'package:flutter_bird/game/config.dart';
import 'package:flutter_bird/game/gameover.dart';
import 'package:flutter_bird/game/generation.dart';
import 'package:flutter_bird/game/horizont.dart';
import 'package:flutter_bird/game/scorer.dart';
import 'package:flutter_bird/game/tube.dart';
import 'package:flutter_bird/main.dart';
import 'package:flutter_bird/game/data.dart' as Data;

enum GameStatus { playing, waiting, gameOver }

class FlutterBirdGame extends BaseGame {
  Size screenSize;
  Horizon horizon;
  Bird bird;
  Bottom bottom;
  GameOver gameOver;

  Tube firstTopTube;
  Tube firstBottomTube;
  Tube secondTopTube;
  Tube secondBottomTube;
  Tube thirdTopTube;
  Tube thirdBottomTube;

  Generation _generation;
  int nextPipe = Data.Game.PIPE_NUM;
  Image _spriteImage;
  List<Tube> pipeUpperTube = List(Data.Game.PIPE_NUM);
  List<Tube> pipeLowerTube = List(Data.Game.PIPE_NUM);
  List<Tube> pipeTubes = [];
  int score = 0;
  int aliveNum = 0;
  bool isGameOver = false;

  Scorer _scorer;
  GameStatus status = GameStatus.waiting;
  double xTubeOffset = 220;
  double xTubeStart = Singleton.instance.screenSize.width * 1.5;

  FlutterBirdGame(Image spriteImage, Size screenSize) {
    _spriteImage = spriteImage;
    horizon = Horizon(spriteImage, screenSize);
    bird = Bird(spriteImage, screenSize);
    bottom = Bottom(spriteImage, screenSize);
    gameOver = GameOver(spriteImage, screenSize);
    _scorer = Scorer(spriteImage, screenSize);

    firstBottomTube = Tube(TubeType.bottom, spriteImage);
    firstTopTube = Tube(TubeType.top, spriteImage, firstBottomTube);
    secondBottomTube = Tube(TubeType.bottom, spriteImage);
    secondTopTube = Tube(TubeType.top, spriteImage, secondBottomTube);
    thirdBottomTube = Tube(TubeType.bottom, spriteImage);
    thirdTopTube = Tube(TubeType.top, spriteImage, thirdBottomTube);

    _generation = new Generation(bird);
    pipeLowerTube = [firstBottomTube, secondBottomTube, thirdBottomTube];
    pipeUpperTube = [firstTopTube, secondTopTube, thirdTopTube];
    pipeTubes = [...pipeLowerTube, ...pipeUpperTube];
    aliveNum = _generation.birds.length;

    initGame();

    this
      ..add(horizon)
      ..add(firstTopTube)
      ..add(firstBottomTube)
      ..add(secondTopTube)
      ..add(secondBottomTube)
      ..add(thirdTopTube)
      ..add(thirdBottomTube)
      ..add(bottom)
      ..add(_scorer);

    _generation.bindGeneration(this);
  }

  void initGame() {
    this.score = 0;
    this.aliveNum = _generation.birds.length;
    this.nextPipe = Data.Game.PIPE_NUM;
    this.isGameOver = false;
    this._scorer.reset();
    this.initPositions();
  }

  void initPositions() {
    bottom.setPosition(
      0,
      Singleton.instance.screenSize.height - ComponentDimensions.bottomHeight,
    );

    for (int i = 0; i < pipeLowerTube.length; i++) {
      pipeLowerTube[i].setPosition(xTubeStart + xTubeOffset * (i), 400);
    }

    for (int i = 0; i < pipeUpperTube.length; i++) {
      pipeUpperTube[i].setPosition(xTubeStart + xTubeOffset * (i), -250);
    }
//    gameOver.ground.y = Singleton.instance.screenSize.height;
  }

  @override
  void update(double t) {
    if (status != GameStatus.playing) return;

    bottom.update(t * Speed.GameSpeed);

    if (!this.isGameOver) {
      this.movePipe(t);
      this.findNextPipe();
    }

    this.moveBird(t);
    this.checkGameOver();

    if (checkIfBirdCrossedTube(firstTopTube) ||
        checkIfBirdCrossedTube(secondTopTube) ||
        checkIfBirdCrossedTube(thirdTopTube)) {
      score = _scorer.increase();
    }
  }

  void moveBird(double t) {
    var next2Pipe = (this.nextPipe + 1) % Data.Game.PIPE_NUM;
    for (int i = 0; i < Data.Generation.BIRD_NUM; i++) {
      Bird bird = this._generation.birds[i];

      if (bird == null) {
        continue;
      }

      bird.jumpWithNetwork(
        this.pipeUpperTube[this.nextPipe].ground.x - Data.Game.BIRD_INIT_X,
        this.pipeUpperTube[this.nextPipe].ground.y,
        this.pipeUpperTube[next2Pipe].ground.y,
      );

      if (bird.alive) {
        bird.score = score;
        var birdRect = bird.ground.toRect();

        // Bird hit the land
        if (check2ItemsCollision(birdRect, bottom.rect)) {
          bird.alive = false;
        }

        if (bird.ground.y < 0 ||
            bird.ground.y > Singleton.instance.screenSize.height) {
          bird.alive = false;
        }

        for (var pipe in pipeTubes) {
          if (check2ItemsCollision(birdRect, pipe.ground.toRect())) {
            bird.alive = false;
          }
        }

        if (!bird.alive) {
          this.aliveNum--;
          bird.destroy();
        }
      } else if (!this.isGameOver) {
        bird.ground.x -= Data.Game.MOVE_SPEED;
      }

      // Prevent the bird from falling below the lower edge of the canvas
//      if (bird.y + Data.Game.BIRD_RADIUS >= Data.Game.LAND_Y) {
//        bird.ground.y = (Data.Game.LAND_Y - Data.Game.BIRD_RADIUS).toDouble();
//      }

      bird.update(t * Speed.GameSpeed);
    }
  }

  void gameOverAction() {
    if (status != GameStatus.gameOver) {
      Flame.audio.play('hit.wav');
      Flame.audio.play('die.wav');
      status = GameStatus.gameOver;
//      gameOver.ground.y =
//          (Singleton.instance.screenSize.height - gameOver.ground.height) / 2;
    }
  }

  bool checkIfBirdCrossedTube(Tube tube) {
    if (!tube.crossedBird) {
      var tubeRect = tube.ground.toRect();
      var xCenterOfTube = tubeRect.left + tubeRect.width / 2;
      var xCenterOfBird =
          ComponentPositions.birdX + ComponentDimensions.birdWidth / 2;
      if (xCenterOfTube < xCenterOfBird && status == GameStatus.playing) {
        tube.crossedBird = true;
        return true;
      }
    }
    return false;
  }

  void onTap() {
    switch (status) {
      case GameStatus.waiting:
        status = GameStatus.playing;
//        bird.jump();
        bottom.move();
        break;
      case GameStatus.gameOver:
        status = GameStatus.waiting;
        initPositions();
        _scorer.reset();
        break;
      case GameStatus.playing:
//        bird.jump();
        break;
      default:
    }
  }

  bool check2ItemsCollision(Rect item1, Rect item2) {
    var intersectedRect = item1.intersect(item2);
    return intersectedRect.width > 0 && intersectedRect.height > 0;
  }

  void movePipe(double t) {
    for (var pipe in pipeTubes) {
      pipe.update(t * Speed.GameSpeed);
    }
  }

  void findNextPipe() {
    this.nextPipe = Data.Game.PIPE_NUM;

    double minX = double.maxFinite;
    for (int i = 0; i < Data.Game.PIPE_NUM; i++) {
      var x = pipeUpperTube[i].ground.x;
      if (x >= Data.Game.BIRD_INIT_X - Data.Game.BIRD_RADIUS && x < minX) {
        minX = min(minX, x);
        this.nextPipe = i;
      }
    }

    if (nextPipe >= Data.Game.PIPE_NUM) {
      this.nextPipe = 0;
    }
  }

  void checkGameOver() {
    if (this.aliveNum == 0 && !this.isGameOver) {
      this.isGameOver = true;
      this._generation.nextGen();
      this.initGame();
    }
  }
}
