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
	_testar_ataque_no_mouse()
	_testar_pausa_no_esc()
	_testar_paleta()
	_testar_cena_jogador()
	_testar_fisica_do_pulo()
	_testar_cena_inimigo()
	_testar_cena_principal()
	_testar_config()
	_testar_menus()
	_testar_pausa()
	_relatar()


func _checar(condicao: bool, descricao: String) -> void:
	if condicao:
		_passou += 1
	else:
		_falhas.append(descricao)


func _testar_input_map() -> void:
	for acao in ["mover_esquerda", "mover_direita", "pular", "atacar", "dash", "reiniciar", "pausar"]:
		_checar(InputMap.has_action(acao), "acao de input ausente: %s" % acao)
		if InputMap.has_action(acao):
			_checar(
				InputMap.action_get_events(acao).size() > 0,
				"acao '%s' existe mas nao tem nenhuma tecla" % acao
			)


## O ataque tem que estar no botao esquerdo do mouse, nao so na tecla J.
func _testar_ataque_no_mouse() -> void:
	var tem_mouse := false
	for e in InputMap.action_get_events("atacar"):
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			tem_mouse = true
	_checar(tem_mouse, "atacar nao esta no botao esquerdo do mouse")


func _testar_pausa_no_esc() -> void:
	var tem_esc := false
	for e in InputMap.action_get_events("pausar"):
		if e is InputEventKey and e.physical_keycode == KEY_ESCAPE:
			tem_esc = true
	_checar(tem_esc, "pausar nao esta no Esc")


func _testar_config() -> void:
	_checar(Config != null, "autoload Config ausente")
	_checar(Config.volume_geral >= 0.0 and Config.volume_geral <= 1.0, "volume fora de 0..1")
	_checar(Config.has_method("salvar"), "Config nao sabe salvar")
	_checar(Config.has_method("restaurar_padroes"), "Config nao sabe restaurar padroes")


func _testar_menus() -> void:
	var tema := load("res://assets/tema.tres")
	_checar(tema is Theme, "tema.tres nao carregou como Theme")

	for caminho in [
		"res://scenes/ui/menu_principal.tscn",
		"res://scenes/ui/painel_opcoes.tscn",
		"res://scenes/ui/menu_pausa.tscn",
	]:
		_checar(ResourceLoader.exists(caminho), "cena de UI ausente: " + caminho)

	var menu := (load("res://scenes/ui/menu_principal.tscn") as PackedScene).instantiate()
	add_child(menu)
	_checar(menu.has_node("%Jogar"), "menu principal sem botao Jogar")
	_checar(menu.has_node("%Opcoes"), "menu principal sem botao Opcoes")
	_checar(menu.has_node("%PainelOpcoes"), "menu principal sem painel de opcoes")
	menu.queue_free()

	var painel := (load("res://scenes/ui/painel_opcoes.tscn") as PackedScene).instantiate()
	add_child(painel)
	for nome in ["%Volume", "%TelaCheia", "%Vsync", "%Tempo", "%Padroes", "%Voltar"]:
		_checar(painel.has_node(nome), "painel de opcoes sem o controle " + nome)
	_checar(not painel.visible, "painel de opcoes nasce visivel")
	painel.queue_free()


## Pausar tem que congelar a arvore E o cronometro da run.
func _testar_pausa() -> void:
	var pausa := (load("res://scenes/ui/menu_pausa.tscn") as PackedScene).instantiate()
	add_child(pausa)
	_checar(
		pausa.process_mode == Node.PROCESS_MODE_ALWAYS,
		"menu de pausa nao roda durante a pausa - o Esc nao vai despausar"
	)
	_checar(not get_tree().paused, "a arvore ja comeca pausada")
	pausa.pausar()
	_checar(get_tree().paused, "pausar() nao pausou a arvore")
	pausa.retomar()
	_checar(not get_tree().paused, "retomar() nao despausou a arvore")
	pausa.queue_free()


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
