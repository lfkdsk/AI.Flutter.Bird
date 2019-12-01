import 'package:flutter_bird/game/data.dart' as Data;
import 'dart:math';
import 'dart:core';

class NetWork {
  int nodeSize = Data.Network.INPUT_SIZE;
  Random random = new Random.secure();
  Map<int, dynamic> edges = {};
  Map<int, dynamic> _nodes = {};
  Function _activation;

  void mutate() {
    var sn = (random.nextDouble() * this.nodeSize).ceil();
    var fn =
        (random.nextDouble() * (this.nodeSize + 1 - Data.Network.INPUT_SIZE))
                .ceil() +
            Data.Network.INPUT_SIZE;

    if (fn > this.nodeSize) {
      fn = Data.Network.NODE_OUTPUT;
    }

    if (sn > fn && fn != Data.Network.NODE_OUTPUT) {
      var t = sn;
      sn = fn;
      fn = t;
    }

    // Check whether the two nodes are linked or not
    if (this.edges[sn] != null && this.edges[sn][fn] != null) {
      if (random.nextDouble() < Data.Network.ADD_NODE_CHANCE) {
        this.addNode(sn, fn);
      } else {
        this.changeEdgeWeight(sn, fn);
      }
    } else {
      this.addEdge(sn, fn);
    }
  }

  void addEdge(sn, fn) {
    if (this.edges[sn] == null) {
      this.edges[sn] = {};
    } else {
      this.edges[sn] = this.edges[sn];
    }

    this.edges[sn][fn] = random.nextDouble() * 2 - 1;
  }

  // Insert a new node in the middle of an existing edge
  void addNode(sn, fn) {
    this.edges[sn][++this.nodeSize] = 1;
    if (this.edges[this.nodeSize] == null) {
      this.edges[this.nodeSize] = {};
    } else {
      this.edges[this.nodeSize] = this.edges[this.nodeSize];
    }

    this.edges[this.nodeSize][fn] = this.edges[sn][fn];
    this.edges[sn][fn] = 0;
  }

  bool getOutput(pipeDis, pipeUpper, pipe2Upper) {
    // Initialize the value of nodes
    this._nodes[Data.Network.NODE_BIAS] = 1;
    this._nodes[Data.Network.NODE_PIPE_DIS] = pipeDis;
    this._nodes[Data.Network.NODE_PIPE_UPPER] = pipeUpper;
    this._nodes[Data.Network.NODE_PIPE2_UPPER] = pipe2Upper;
    this._nodes[Data.Network.NODE_OUTPUT] = 0;

    for (var i = Data.Network.INPUT_SIZE + 1; i <= this.nodeSize; i++) {
      this._nodes[i] = 0;
    }

    for (var i = 1; i <= this.nodeSize; i++) {
      if (i > Data.Network.INPUT_SIZE) {
        this._nodes[i] = this._activation(this._nodes[i]);
      }

      if (this.edges[i] == null) {
        this.edges[i] = {};
      }

      this.edges[i].forEach(
            (k, v) => this._nodes[k] += this._nodes[i] * this.edges[i][k],
          );
    }
    return this._nodes[Data.Network.NODE_OUTPUT] > 0;
  }

  void changeEdgeWeight(sn, fn) {
    this.edges[sn][fn] += random.nextDouble() * Data.Network.STEP_SIZE * 2 -
        Data.Network.STEP_SIZE;
  }

  double getActivation(x) => 2 / (1 + exp(-4.9 * x)) - 1;

  set activation(Function value) => this._activation = value;
}

Function Activation(String funcName) {
  switch (funcName) {
    case Data.Activation.SIGMOID:
      return (x) {
        return 1 / (1 + exp(-x));
      };
    case Data.Activation.ARCTAN:
      return (x) {
        return 1 / (pow(x, 2) + 1);
      };
    case Data.Activation.CUSTOM_TANGENT:
      return (x) {
        return 2 / (1 + exp(-4.9 * x)) - 1;
      };
    case Data.Activation.HYPERBOLIC_TANGENT:
      return (x) {
        return 1 / (1 + exp(-2 * x));
      };
    case Data.Activation.RELU:
      return (x) {
        return max<double>(0, x);
      };
    default:
      return (x) {
        return x;
      };
  }
}
