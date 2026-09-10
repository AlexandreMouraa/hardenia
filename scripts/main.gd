extends Node2D
## Cena raiz da partida. Amarra jogador, HUD e telas.
##
## Quando existirem varias salas, e aqui que o sorteio da run vai morar.

@onready var _jogador: Jogador = $Jogador
@onready var _hud: CanvasLayer = $HUD


func _ready() -> void:
	_hud.conectar(_jogador)
	Jogo.iniciar_run()
