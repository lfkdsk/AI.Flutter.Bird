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

//  nextGeneration: function() {
//    this.birds.sort(function(a, b) {
//    return b.fitness - a.fitness
//    });
//    Data.generation.SURVIVOR_NUM = dashboard.getSurvivorNum();
//    for (var i = Data.generation.SURVIVOR_NUM; i < Data.generation.BIRD_NUM; i++) {
//      this.birds[i] = null;
//      delete this.birds[i];
//    }
//
//    Data.generation.BIRD_NUM = dashboard.getBirdNum();
//    Data.generation.MUTATE_CHANCE = dashboard.getMutateChance();
//    for (var i = Data.generation.SURVIVOR_NUM - 1; i >= Data.generation.BIRD_NUM; i--) {
//      this.birds[i] = null;
//      delete this.birds[i];
//    }
//
//    Data.generation.SURVIVOR_NUM = Math.min(Data.generation.SURVIVOR_NUM, Data.generation.BIRD_NUM);
//    for (var i = Data.generation.SURVIVOR_NUM; i < Data.generation.BIRD_NUM; i++) {
//      this.birds[i] = this._breed(Math.floor(Math.random() * Data.generation.SURVIVOR_NUM), Math.floor(Math.random() * Data.generation.SURVIVOR_NUM));
//    }
//    for (var i = 0; i < Data.generation.SURVIVOR_NUM; i++) {
//      this.birds[i].init();
//    }
//    this.generationNum++;
//  },

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

//  _breed: function(birdA, birdB) {
//    var baby = new Bird();
//    baby.network.setActivation(Activation.get(dashboard.getActivationFunction()));
//
//    if (this.birds[birdA].fitness < this.birds[birdB].fitness) {
//      var t = birdA;
//      birdA = birdB;
//      birdB = t;
//    }
//
//    baby.network.nodeSize = this.birds[birdA].network.nodeSize;
//    for (var i = 1; i <= baby.network.nodeSize; i++) {
//      baby.network.edges[i] = [];
//      for (var j in this.birds[birdA].network.edges[i]) {
//        // Check if the parent with less fitness has the same edge
//        if (this.birds[birdB].network.edges.hasOwnProperty(i) && this.birds[birdB].network.edges[i].hasOwnProperty(j)) {
//          baby.network.edges[i][j] = Math.random() < 0.5 ? this.birds[birdA].network.edges[i][j] : this.birds[birdB].network.edges[i][j];
//        } else {
//          baby.network.edges[i][j] = this.birds[birdA].network.edges[i][j];
//        }
//      }
//    }
//
//    if (Math.random() <= Data.generation.MUTATE_CHANCE) {
//      baby.network.mutate();
//    }
//    return baby;
//  }

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
