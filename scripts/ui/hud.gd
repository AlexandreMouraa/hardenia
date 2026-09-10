extends CanvasLayer
## HUD da run: vida, tentativa e tempo.
##
## "Tentativas" e so um numero na tela. Nao desbloqueia nada, nao facilita nada.
## Esta ali para o jogador ver a propria persistencia acumulando.

@onready var _coracoes: HBoxContainer = $Margem/Linha/Coracoes
@onready var _tentativa: Label = $Margem/Linha/Tentativa
@onready var _tempo: Label = $Margem/Linha/Tempo

var _jogador: Jogador


func _ready() -> void:
	_tentativa.text = "TENTATIVA %d" % Jogo.tentativa


func conectar(jogador: Jogador) -> void:
	_jogador = jogador
	jogador.vida_alterada.connect(_desenhar_vida)
	_desenhar_vida(jogador.vida, jogador.vida_maxima)


func _process(_delta: float) -> void:
	_tempo.text = Jogo.tempo_formatado()


func _desenhar_vida(atual: int, maxima: int) -> void:
	for filho in _coracoes.get_children():
		filho.queue_free()
	for i in maxima:
		var c := ColorRect.new()
		c.custom_minimum_size = Vector2(10, 10)
		c.color = Paleta.SANGUE if i < atual else Paleta.ARDOSIA
		_coracoes.add_child(c)
