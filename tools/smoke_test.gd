extends Node
## Teste de fumaca de Hardenia.
##
## Nao testa se o jogo e divertido - testa se ele nao esta quebrado.
## Roda em segundos, sem abrir janela, e serve para saber que um merge nao
## destruiu nada antes de voce perceber jogando.
##
## Rodar:
##   godot --headless --path . res://tools/smoke_test.tscn
##
## Sai com codigo 0 se tudo passou, 1 se algo falhou.

var _falhas: Array[String] = []
var _passou := 0


func _ready() -> void:
	_testar_input_map()
	_testar_paleta()
	_testar_cena_jogador()
	_testar_fisica_do_pulo()
	_testar_cena_inimigo()
	_testar_cena_principal()
	_relatar()


func _checar(condicao: bool, descricao: String) -> void:
	if condicao:
		_passou += 1
	else:
		_falhas.append(descricao)


func _testar_input_map() -> void:
	for acao in ["mover_esquerda", "mover_direita", "pular", "atacar", "dash", "reiniciar"]:
		_checar(InputMap.has_action(acao), "acao de input ausente: %s" % acao)
		if InputMap.has_action(acao):
			_checar(
				InputMap.action_get_events(acao).size() > 0,
				"acao '%s' existe mas nao tem nenhuma tecla" % acao
			)


func _testar_paleta() -> void:
	_checar(Paleta.TODAS.size() == 7, "a paleta deve ter exatamente 7 cores")
	_checar(Paleta.SANGUE.to_html(false) == "901b1d", "cor de acento errada")
	_checar(Paleta.BRANCO.to_html(false) == "e8ded9", "cor de texto errada")


func _testar_cena_jogador() -> void:
	var cena := load("res://scenes/jogador/jogador.tscn") as PackedScene
	_checar(cena != null, "jogador.tscn nao carregou")
	if cena == null:
		return
	var j := cena.instantiate()
	add_child(j)
	_checar(j is Jogador, "raiz de jogador.tscn nao e um Jogador")
	_checar(j.has_node("Sprite"), "jogador sem no Sprite")
	_checar(j.has_node("Corpo"), "jogador sem no Corpo")
	_checar(j.has_node("Golpe/Forma"), "jogador sem hitbox de ataque")
	_checar(j.has_node("Camera"), "jogador sem Camera2D")
	_checar(j.vida == j.vida_maxima, "jogador nao comeca com a vida cheia")
	_checar(j.get_node("Golpe").monitoring == false, "hitbox de ataque nasce ligada")
	j.queue_free()


func _testar_fisica_do_pulo() -> void:
	## A altura do pulo e derivada de altura/tempo. Se a conta estiver errada,
	## o personagem pula errado e ninguem descobre o porque.
	var j := (load("res://scenes/jogador/jogador.tscn") as PackedScene).instantiate()
	add_child(j)
	var altura_real: float = pow(j._vel_pulo, 2.0) / (2.0 * j._grav_subida)
	_checar(
		absf(altura_real - j.altura_pulo) < 0.5,
		"pulo sobe %.1f px mas foi configurado para %.1f px" % [altura_real, j.altura_pulo]
	)
	_checar(j._grav_queda > j._grav_subida, "a queda deveria ser mais rapida que a subida")
	j.queue_free()


func _testar_cena_inimigo() -> void:
	var cena := load("res://scenes/inimigos/inimigo_patrulha.tscn") as PackedScene
	_checar(cena != null, "inimigo_patrulha.tscn nao carregou")
	if cena == null:
		return
	var i := cena.instantiate()
	add_child(i)
	_checar(i is InimigoBase, "raiz do inimigo nao e um InimigoBase")
	_checar(i.has_method("levar_dano"), "inimigo nao sabe levar dano")
	_checar(i.has_node("DetectorChao"), "inimigo sem detector de beirada")
	_checar(i.has_node("Contato"), "inimigo sem area de contato")
	i.queue_free()


func _testar_cena_principal() -> void:
	var caminho: String = ProjectSettings.get_setting("application/run/main_scene", "")
	_checar(caminho != "", "main_scene nao esta configurada")
	_checar(ResourceLoader.exists(caminho), "main_scene aponta para um arquivo inexistente")


func _relatar() -> void:
	print("")
	print("== SMOKE TEST HARDENIA ==")
	print("passou: %d" % _passou)
	if _falhas.is_empty():
		print("falhou: 0")
		print("TUDO OK")
		get_tree().quit(0)
		return
	print("falhou: %d" % _falhas.size())
	for f in _falhas:
		print("  X %s" % f)
	get_tree().quit(1)
