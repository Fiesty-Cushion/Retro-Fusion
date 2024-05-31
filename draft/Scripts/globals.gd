extends Node

const WEB_SOCKET_PORT := 9642; # MAKE CONFIGURABLE?
var isGameStarted := false;

signal socket_data_recieved(json:JSON)
signal user_connected(id:int, username:String)
signal user_disconnected(id:int)
