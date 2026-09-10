extends CharacterBody2D
class_name Jogador
## O ultimo guerreiro.
##
## Ele nao fica mais forte. Nenhum numero deste script deve mudar durante a
## partida nem entre partidas - quem melhora e quem esta segurando o teclado.
## Se aparecer um "upgrade" que mexe nestes valores em runtime, leia o slide 4
## de novo antes de commitar.
##
## Os valores abaixo estao no Inspetor, agrupados. Mexa a vontade: e assim que
## o game feel e encontrado. Ache o numero bom no editor e depois cole aqui.

signal vida_alterada(atual: int, maxima: int)
signal levou_dano
signal morreu
signal atacou

enum Estado { NORMAL, DASH, MORTO }

@export_group("Movimento")
## Velocidade maxima de corrida, em pixels por segundo.
@export var velocidade := 150.0
## Quao rapido chega na velocidade maxima. Alto = responsivo, baixo = pesado.
@export var aceleracao := 1400.0
## Freio no chao quando solta a tecla.
@export var atrito_chao := 1600.0
## Freio no ar. Menor que o do chao para o pulo ter compromisso.
@export var atrito_ar := 500.0

@export_group("Pulo")
## Altura do pulo em pixels. Pensado em altura, nao em forca - e mais facil de ajustar.
@export var altura_pulo := 48.0
## Tempo para chegar no topo do pulo.
@export var tempo_subida := 0.32
## Tempo para cair a mesma altura. Menor que a subida = queda "gostosa".
@export var tempo_queda := 0.26
## Janela para pular depois de ja ter saido da plataforma. Perdoa o jogador.
@export var coyote_time := 0.10
## Janela para o pulo apertado um pouco antes de encostar no chao valer.
@export var buffer_pulo := 0.12
## Soltar o botao cedo corta o pulo. Multiplicador da velocidade vertical.
@export_range(0.0, 1.0) var corte_pulo := 0.45

@export_group("Dash")
@export var dash_velocidade := 340.0
@export var dash_duracao := 0.16
@export var dash_recarga := 0.55
## Tempo invencivel durante o dash. E o que transforma dash em ferramenta de defesa.
@export var dash_invencivel := 0.16

@export_group("Ataque")
@export var ataque_duracao := 0.22
## Fracao do ataque em que o golpe machuca. Antes disso e antecipacao.
@export_range(0.0, 1.0) var ataque_inicio_dano := 0.25
@export_range(0.0, 1.0) var ataque_fim_dano := 0.7
@export var ataque_recarga := 0.30
@export var ataque_dano := 1

@export_group("Vida")
@export var vida_maxima := 3
## Piscando e intocavel depois de levar dano.
@export var invencivel_apos_dano := 0.9
@export var empurrao_dano := 160.0

var estado: Estado = Estado.NORMAL
var vida: int
var direcao_olhar := 1  ## 1 = direita, -1 = esquerda

var _grav_subida: float
var _grav_queda: float
var _vel_pulo: float

var _coyote := 0.0
var _buffer := 0.0
var _dash_restante := 0.0
var _dash_recarga_restante := 0.0
var _ataque_restante := 0.0
var _ataque_recarga_restante := 0.0
var _invencivel_restante := 0.0
var _ja_acertou: Array[Node] = []

@onready var sprite: Sprite2D = $Sprite
@onready var golpe: Area2D = $Golpe
@onready var golpe_forma: CollisionShape2D = $Golpe/Forma


func _ready() -> void:
	_recalcular_fisica_do_pulo()
	vida = vida_maxima
	golpe.monitoring = false
	golpe_forma.disabled = true
	vida_alterada.emit(vida, vida_maxima)


## Converte altura/tempo (facil de imaginar) em gravidade/impulso (o que a fisica usa).
func _recalcular_fisica_do_pulo() -> void:
	_grav_subida = 2.0 * altura_pulo / pow(tempo_subida, 2.0)
	_grav_queda = 2.0 * altura_pulo / pow(tempo_queda, 2.0)
	_vel_pulo = -2.0 * altura_pulo / tempo_subida


func _physics_process(delta: float) -> void:
	_atualizar_contadores(delta)

	match estado:
		Estado.MORTO:
			velocity.x = move_toward(velocity.x, 0.0, atrito_chao * delta)
			velocity.y += _grav_queda * delta
		Estado.DASH:
			_processar_dash(delta)
		Estado.NORMAL:
			_processar_normal(delta)

	move_and_slide()
	_atualizar_visual()


func _atualizar_contadores(delta: float) -> void:
	_coyote = maxf(0.0, _coyote - delta)
	_buffer = maxf(0.0, _buffer - delta)
	_dash_recarga_restante = maxf(0.0, _dash_recarga_restante - delta)
	_ataque_recarga_restante = maxf(0.0, _ataque_recarga_restante - delta)
	_invencivel_restante = maxf(0.0, _invencivel_restante - delta)

	if is_on_floor():
		_coyote = coyote_time
		_dash_recarga_restante = minf(_dash_recarga_restante, 0.05)

	if _ataque_restante > 0.0:
		_ataque_restante = maxf(0.0, _ataque_restante - delta)
		_atualizar_janela_de_dano()


func _processar_normal(delta: float) -> void:
	var eixo := Input.get_axis("mover_esquerda", "mover_direita")

	if eixo != 0.0:
		velocity.x = move_toward(velocity.x, eixo * velocidade, aceleracao * delta)
		if _ataque_restante <= 0.0:
			direcao_olhar = signi(int(eixo))
	else:
		var freio := atrito_chao if is_on_floor() else atrito_ar
		velocity.x = move_toward(velocity.x, 0.0, freio * delta)

	velocity.y += (_grav_subida if velocity.y < 0.0 else _grav_queda) * delta

	if Input.is_action_just_pressed("pular"):
		_buffer = buffer_pulo
	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = _vel_pulo
		_buffer = 0.0
		_coyote = 0.0
	if Input.is_action_just_released("pular") and velocity.y < 0.0:
		velocity.y *= corte_pulo

	if Input.is_action_just_pressed("dash") and _dash_recarga_restante <= 0.0:
		_iniciar_dash()
	elif Input.is_action_just_pressed("atacar") and _ataque_recarga_restante <= 0.0:
		_iniciar_ataque()


func _processar_dash(delta: float) -> void:
	_dash_restante -= delta
	velocity.x = direcao_olhar * dash_velocidade
	velocity.y = 0.0  ## dash horizontal puro: previsivel de ler, previsivel de usar
	if _dash_restante <= 0.0:
		estado = Estado.NORMAL
		velocity.x = direcao_olhar * velocidade


func _iniciar_dash() -> void:
	estado = Estado.DASH
	_dash_restante = dash_duracao
	_dash_recarga_restante = dash_recarga
	_invencivel_restante = maxf(_invencivel_restante, dash_invencivel)
	_cancelar_ataque()


func _iniciar_ataque() -> void:
	_ataque_restante = ataque_duracao
	_ataque_recarga_restante = ataque_recarga
	_ja_acertou.clear()
	atacou.emit()


func _cancelar_ataque() -> void:
	_ataque_restante = 0.0
	golpe.monitoring = false
	golpe_forma.disabled = true


## O golpe so machuca no meio da animacao, nunca no primeiro frame.
## E o que da ao inimigo a chance de ler o ataque - a base do "aprender o padrao".
func _atualizar_janela_de_dano() -> void:
	var progresso := 1.0 - (_ataque_restante / ataque_duracao)
	var ativo := progresso >= ataque_inicio_dano and progresso <= ataque_fim_dano
	golpe.monitoring = ativo
	golpe_forma.disabled = not ativo
	golpe.position.x = absf(golpe.position.x) * direcao_olhar
	if ativo:
		for corpo in golpe.get_overlapping_bodies():
			_tentar_acertar(corpo)


func _tentar_acertar(alvo: Node) -> void:
	if alvo in _ja_acertou or not alvo.has_method("levar_dano"):
		return
	_ja_acertou.append(alvo)
	alvo.levar_dano(ataque_dano, global_position)


func levar_dano(quantidade: int, origem: Vector2 = Vector2.ZERO) -> void:
	if estado == Estado.MORTO or _invencivel_restante > 0.0:
		return

	vida = maxi(0, vida - quantidade)
	_invencivel_restante = invencivel_apos_dano
	_cancelar_ataque()
	vida_alterada.emit(vida, vida_maxima)
	levou_dano.emit()

	if origem != Vector2.ZERO:
		var lado := signf(global_position.x - origem.x)
		if lado == 0.0:
			lado = -direcao_olhar
		velocity.x = lado * empurrao_dano
		velocity.y = _vel_pulo * 0.35

	if vida <= 0:
		_morrer()


func _morrer() -> void:
	estado = Estado.MORTO
	_cancelar_ataque()
	morreu.emit()
	Jogo.terminar_run(false)


func _atualizar_visual() -> void:
	sprite.flip_h = direcao_olhar < 0
	if _invencivel_restante > 0.0 and estado != Estado.MORTO:
		## Pisca em 10 Hz. Sinal claro de "voce esta intocavel agora".
		sprite.visible = fmod(_invencivel_restante, 0.1) > 0.05
	else:
		sprite.visible = true
	sprite.modulate = Paleta.SANGUE if estado == Estado.DASH else Color.WHITE
