extends CharacterBody2D
class_name InimigoBase
## Base de todo inimigo de Hardenia.
##
## Cada inimigo novo herda daqui e sobrescreve _pensar(). O contrato e curto de
## proposito: quem esta fazendo os inimigos precisa escrever pouco codigo.
##
## REGRA DE DESIGN: todo inimigo tem que ter um padrao legivel e uma janela de
## antecipacao antes de machucar. Inimigo que acerta sem aviso nao ensina nada -
## so gera a "frustracao artificial" que o slide 5 diz que Hardenia nao quer.

signal morreu(inimigo: InimigoBase)

@export_group("Vida")
@export var vida_maxima := 3

@export_group("Movimento")
@export var velocidade := 40.0
@export var gravidade := 1200.0
## Vira ao chegar na beirada da plataforma em vez de cair.
@export var evitar_queda := true

@export_group("Dano por contato")
@export var dano_contato := 1
@export var contato_ativo := true

var vida: int
var direcao := -1

@onready var sprite: Sprite2D = $Sprite
@onready var _contato: Area2D = $Contato
@onready var _detector_chao: RayCast2D = $DetectorChao
@onready var _detector_parede: RayCast2D = $DetectorParede


func _ready() -> void:
	vida = vida_maxima
	add_to_group("inimigos")


func _physics_process(delta: float) -> void:
	velocity.y += gravidade * delta
	_pensar(delta)
	move_and_slide()
	sprite.flip_h = direcao > 0
	if contato_ativo:
		_checar_contato()


## Sobrescreva isto no inimigo especifico. O padrao e uma patrulha simples.
func _pensar(_delta: float) -> void:
	velocity.x = direcao * velocidade
	if not is_on_floor():
		return
	var virou_na_parede := _detector_parede.is_colliding()
	var virou_na_beirada := evitar_queda and not _detector_chao.is_colliding()
	if virou_na_parede or virou_na_beirada:
		virar()


func virar() -> void:
	direcao *= -1
	_detector_chao.position.x = absf(_detector_chao.position.x) * direcao
	_detector_parede.target_position.x = absf(_detector_parede.target_position.x) * direcao


func _checar_contato() -> void:
	for alvo in _contato.get_overlapping_bodies():
		if alvo is Jogador:
			alvo.levar_dano(dano_contato, global_position)


func levar_dano(quantidade: int, origem: Vector2 = Vector2.ZERO) -> void:
	vida = maxi(0, vida - quantidade)
	_piscar()
	if origem != Vector2.ZERO:
		velocity.x = signf(global_position.x - origem.x) * 90.0
	if vida <= 0:
		_morrer()


func _piscar() -> void:
	sprite.modulate = Paleta.BRANCO
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color.WHITE, 0.12)


func _morrer() -> void:
	morreu.emit(self)
	queue_free()
