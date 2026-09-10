extends CanvasLayer
## "VOCE MORREU / mas essa nao e o fim."
##
## Texto tirado direto da biblia visual da equipe. E o pitch inteiro em duas
## linhas: a morte nao e punicao, e a mecanica de aprendizado.

@onready var _titulo: Label = $Centro/Coluna/Titulo
@onready var _subtitulo: Label = $Centro/Coluna/Subtitulo
@onready var _dica: Label = $Centro/Coluna/Dica


func _ready() -> void:
	hide()
	Jogo.run_terminada.connect(_ao_terminar_run)


func _ao_terminar_run(vitoria: bool) -> void:
	_titulo.text = "VOCE VENCEU" if vitoria else "VOCE MORREU"
	_subtitulo.text = "Hardenia respira de novo." if vitoria else "mas essa nao e o fim."
	_dica.text = "R para tentar novamente"
	await get_tree().create_timer(0.6).timeout
	show()


func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("reiniciar"):
		get_viewport().set_input_as_handled()
		Jogo.reiniciar()
