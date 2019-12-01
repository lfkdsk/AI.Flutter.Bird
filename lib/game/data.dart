class Network {
  // The id of each input node and output node
  static const int NODE_BIAS = 1;
  static const int NODE_PIPE_DIS = 2;
  static const int NODE_PIPE_UPPER = 3;
  static const int NODE_PIPE2_UPPER = 4;
  static const int NODE_OUTPUT = 0;
  static const int INPUT_SIZE = 4;

  // The largest increment/decrement when changing the weight of an edge
  static const double STEP_SIZE = 0.1;
  static const double ADD_NODE_CHANCE = 0.5;
}

class Activation {
  static const SIGMOID = "sigmoid";
  static const ARCTAN = "arctan";
  static const CUSTOM_TANGENT = "custom";
  static const HYPERBOLIC_TANGENT = "hyperbolic";
  static const RELU = "RELU";
}

class Generation {
  static const BIRD_NUM = 15;
  static const SURVIVOR_NUM = 5;
  static const MUTATE_CHANCE = 0.5;
}

class Animation {
//  static const SCREEN_WIDTH = 336;
//  static const SCREEN_HEIGHT = 512;
  static const LAND_NUM = 2;
  static const SCORE_Y = 20;
  static const SCORE_WIDTH = 24;
  static const SCORE_SPACE = 2;
}

class Game {
  static const PIPE_NUM = 3;
  static const PIPE_WIDTH = 52;
  static const PIPE_HEIGHT = 500;
  static const PIPE_MIN_Y = 100;
  static const PIPE_MAX_Y = 305;
  static const SPACE_HEIGHT = 100;
  static const LAND_Y = 0;
  static const BIRD_INIT_X = 80;
  static const BIRD_INIT_Y = 250;
  static const BIRD_RADIUS = 12;
  static const GRAVITY = 0.4;
  static const FLY_SPEED = 5.5; // The y-coordinate speed after the bird flap its wings
  static const MOVE_SPEED = 2; // The x-coordinate speed of the birds
}
