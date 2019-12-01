class _Network {
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

class _Activation {
  static const SIGMOID = "sigmoid";
  static const ARCTAN = "arctan";
  static const CUSTOM_TANGENT = "custom";
  static const HYPERBOLIC_TANGENT = "hyperbolic";
  static const RELU = "RELU";
}
class Data {
  static _Network network = _Network();
  static _Activation activation = _Activation();
}
