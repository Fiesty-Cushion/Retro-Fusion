extends Node

const WEB_SOCKET_PORT := 9642  # MAKE CONFIGURABLE?
var isGameStarted := false
var batShouldReset := false
var current_user := "Anonymous"

var REFERENCE_QUATER = Quaternion(0, 0, sqrt(2) / 2, sqrt(2) / 2)

signal striked_ball
signal score_changed(amount: int)
signal user_connected(username: String)
