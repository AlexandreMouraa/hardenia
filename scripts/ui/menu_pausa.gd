extends CanvasLayer
## Menu de pausa. Esc abre e fecha.
##
## Este no roda com process_mode = ALWAYS: precisa continuar ouvindo o teclado
## justamente enquanto o resto da arvore esta congelado.
##
## Pausar NAO e trapaca: o tempo da run tambem para, entao ninguem ganha
## vantagem parando para pensar. O cronometro so conta jogo de verdade.

func _ready() -> void:
	%Raiz.hide()
	%Continuar.pressed.connect(retomar)
	%Opcoes.pressed.connect(%PainelOpcoes.abrir)
	%Menu.pressed.connect(_voltar_ao_menu)
	%PainelOpcoes.fechado.connect(func() -> void: %Continuar.grab_focus())


func _unhandled_input(evento: InputEvent) -> void:
	if not evento.is_action_pressed("pausar"):
		return
	if %PainelOpcoes.visible:
		return  ## o proprio painel trata o Esc
	get_viewport().set_input_as_handled()
	if %Raiz.visible:
		retomar()
	elif Jogo.em_run:
		pausar()


func pausar() -> void:
	get_tree().paused = true
	%Raiz.show()
	%Continuar.grab_focus()


func retomar() -> void:
	%Raiz.hide()
	get_tree().paused = false


func _voltar_ao_menu() -> void:
	get_tree().paused = false
	Jogo.terminar_run(false)
	get_tree().change_scene_to_file("res://scenes/ui/menu_principal.tscn")
