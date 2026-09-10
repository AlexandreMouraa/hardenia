extends Control
## Primeira tela do jogo.

func _ready() -> void:
	%Jogar.pressed.connect(_jogar)
	%Opcoes.pressed.connect(%PainelOpcoes.abrir)
	%Sair.pressed.connect(_sair)
	%PainelOpcoes.fechado.connect(func() -> void: %Opcoes.grab_focus())
	## No navegador nao existe "sair do programa".
	%Sair.visible = OS.get_name() != "Web"
	%Jogar.grab_focus()


func _jogar() -> void:
	Jogo.nova_sessao()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _sair() -> void:
	get_tree().quit()
