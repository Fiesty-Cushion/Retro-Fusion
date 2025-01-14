extends Node

const WEB_SOCKET_PORT := 9642  # MAKE CONFIGURABLE?
var batShouldReset := false

var REFERENCE_QUATER = Quaternion(0, 0, sqrt(2) / 2, sqrt(2) / 2)

signal striked_ball
signal runs_scored(amount: int)
signal ball_spawned(ball: Node3D)
signal ball_despawned(ball: Node3D)
signal ball_scored(runs: int)
