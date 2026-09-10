extends Control
## Painel de opcoes, reaproveitado pelo menu principal e pelo menu de pausa.
##
## So tem ajuste de conforto: som, video e HUD. Nada aqui muda a dificuldade -
## em Hardenia nao existe "modo facil", existe treino.

signal fechado


func _ready() -> void:
	hide()
	%Volume.min_value = 0.0
	%Volume.max_value = 1.0
	%Volume.step = 0.05
	%Volume.value_changed.connect(_ao_mudar_volume)
	%TelaCheia.toggled.connect(_ao_alternar_tela_cheia)
	%Vsync.toggled.connect(_ao_alternar_vsync)
	%Tempo.toggled.connect(_ao_alternar_tempo)
	%Padroes.pressed.connect(_ao_restaurar)
	%Voltar.pressed.connect(fechar)


func abrir() -> void:
	_ler_config()
	show()
	%Volume.grab_focus()


func fechar() -> void:
	hide()
	fechado.emit()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("pausar"):
		get_viewport().set_input_as_handled()
		fechar()


## Espelha o estado atual do Config nos controles, sem disparar os sinais de
## volta - senao abrir o painel ja gravaria o arquivo de configuracao.
func _ler_config() -> void:
	%Volume.set_value_no_signal(Config.volume_geral)
	%TelaCheia.set_pressed_no_signal(Config.tela_cheia)
	%Vsync.set_pressed_no_signal(Config.vsync)
	%Tempo.set_pressed_no_signal(Config.mostrar_tempo)
	_atualizar_rotulos()


func _atualizar_rotulos() -> void:
	%VolumeValor.text = "%d%%" % roundi(Config.volume_geral * 100.0)
	%TelaCheia.text = "ligado" if Config.tela_cheia else "desligado"
	%Vsync.text = "ligado" if Config.vsync else "desligado"
	%Tempo.text = "ligado" if Config.mostrar_tempo else "desligado"


func _ao_mudar_volume(valor: float) -> void:
	Config.volume_geral = valor
	_atualizar_rotulos()


func _ao_alternar_tela_cheia(ligado: bool) -> void:
	Config.tela_cheia = ligado
	_atualizar_rotulos()


func _ao_alternar_vsync(ligado: bool) -> void:
	Config.vsync = ligado
	_atualizar_rotulos()


func _ao_alternar_tempo(ligado: bool) -> void:
	Config.mostrar_tempo = ligado
	_atualizar_rotulos()


func _ao_restaurar() -> void:
	Config.restaurar_padroes()
	_ler_config()
