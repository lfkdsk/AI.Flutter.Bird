import 'dart:math';

import 'package:flutter_bird/game/bird.dart';
import 'package:flutter_bird/game/data.dart' as Data;
import 'package:flutter_bird/game/game.dart';
import 'package:flutter_bird/game/network.dart';

class Generation {
  int generationNum = 1;
  List<Bird> birds = List(Data.Generation.BIRD_NUM);
  Random _random = new Random.secure();

  Generation(Bird bird) {
    for (int i = 0; i < Data.Generation.BIRD_NUM; i++) {
      this.birds[i] = Bird.clone(bird);
      this.birds[i].ground.y += _random.nextInt(100);
      this.birds[i].netWork.mutate();
    }
  }

  void nextGen() {
    this.birds.sort((a, b) => b.fitness - a.fitness);
//    Data.generation.SURVIVOR_NUM = dashboard.getSurvivorNum();
    for (int i = Data.Generation.SURVIVOR_NUM;
        i < Data.Generation.BIRD_NUM;
        i++) {
      this.birds[i].destroy();
      this.birds[i] = null;
    }

    for (int i = Data.Generation.SURVIVOR_NUM;
        i < Data.Generation.BIRD_NUM;
        i++) {
      this.birds[i] = breed(
        (_random.nextDouble() * Data.Generation.SURVIVOR_NUM).floor(),
        (_random.nextDouble() * Data.Generation.SURVIVOR_NUM).floor(),
      ); // breed;
    }

    for (int i = 0; i < Data.Generation.SURVIVOR_NUM; i++) {
      this.birds[i].init();
      this.birds[i].ground.y += _random.nextInt(100);
    }

    this.generationNum++;
  }

  Bird breed(int indexBirdA, int indexBirdB) {
    Bird birdA = this.birds[indexBirdA];
    Bird birdB = this.birds[indexBirdA];

    if (birdA.fitness < birdB.fitness) {
      var t = birdA;
      birdA = birdB;
      birdB = t;
    }

    Bird baby = Bird.clone(birdA);
    baby.init();

    baby.netWork.activation =
        Activation(Data.Activation.SIGMOID); // TODO set dashboard.

    baby.netWork.nodeSize = birdA.netWork.nodeSize;
    for (int i = 0; i < birdA.netWork.nodeSize; i++) {
      baby.netWork.edges[i] = {};

      if (birdA.netWork.edges[i] == null) {
        continue;
      }

      birdA.netWork.edges[i].forEach(
        (k, v) => _breedGen(birdA, birdB, baby, i, k),
      );
    }

    if (_random.nextDouble() <= Data.Generation.MUTATE_CHANCE) {
      baby.netWork.mutate();
    }

    return baby;
  }

  void _breedGen(Bird birdA, Bird birdB, Bird baby, int i, k) {
    baby.netWork.edges[i][k] = {};
    // Check if the parent with less fitness has the same edge
    if (birdB.netWork.edges[i] != null && birdB.netWork.edges[k] != null) {
      baby.netWork.edges[i][k] = _random.nextDouble() < 0.5
          ? birdA.netWork.edges[i][k]
          : birdB.netWork.edges[i][k];
    } else {
      baby.netWork.edges[i][k] = birdA.netWork.edges[i][k];
    }
  }

  void bindGeneration(FlutterBirdGame game) {
    for (var value in birds) {
      game.add(value);
    }
  }
}
