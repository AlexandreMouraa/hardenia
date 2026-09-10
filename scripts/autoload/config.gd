extends Node
## Preferencias do jogador, salvas em user://config.cfg.
##
## Sobrevivem entre partidas de proposito - sao ajustes de conforto, nao
## progressao de jogo. Nada aqui torna Hardenia mais facil.
##
## No Windows o arquivo fica em:
##   %APPDATA%\Godot\app_userdata\Hardenia\config.cfg

signal alterado

const CAMINHO := "user://config.cfg"

var volume_geral: float = 0.8:
	set(v):
		volume_geral = clampf(v, 0.0, 1.0)
		_aplicar_volume()
		_talvez_salvar()

var tela_cheia: bool = false:
	set(v):
		tela_cheia = v
		_aplicar_tela_cheia()
		_talvez_salvar()

var vsync: bool = true:
	set(v):
		vsync = v
		_aplicar_vsync()
		_talvez_salvar()

var mostrar_tempo: bool = true:
	set(v):
		mostrar_tempo = v
		_talvez_salvar()

var _carregando := false


func _ready() -> void:
	carregar()


func carregar() -> void:
	_carregando = true
	var cfg := ConfigFile.new()
	if cfg.load(CAMINHO) == OK:
		volume_geral = cfg.get_value("audio", "volume_geral", volume_geral)
		tela_cheia = cfg.get_value("video", "tela_cheia", tela_cheia)
		vsync = cfg.get_value("video", "vsync", vsync)
		mostrar_tempo = cfg.get_value("hud", "mostrar_tempo", mostrar_tempo)
	else:
		_aplicar_volume()
		_aplicar_tela_cheia()
		_aplicar_vsync()
	_carregando = false
	alterado.emit()


func salvar() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "volume_geral", volume_geral)
	cfg.set_value("video", "tela_cheia", tela_cheia)
	cfg.set_value("video", "vsync", vsync)
	cfg.set_value("hud", "mostrar_tempo", mostrar_tempo)
	cfg.save(CAMINHO)


func restaurar_padroes() -> void:
	_carregando = true
	volume_geral = 0.8
	tela_cheia = false
	vsync = true
	mostrar_tempo = true
	_carregando = false
	salvar()
	alterado.emit()


func _talvez_salvar() -> void:
	if _carregando:
		return
	salvar()
	alterado.emit()


func _aplicar_volume() -> void:
	var barramento := AudioServer.get_bus_index("Master")
	if barramento < 0:
		return
	AudioServer.set_bus_mute(barramento, volume_geral <= 0.001)
	AudioServer.set_bus_volume_db(barramento, linear_to_db(maxf(volume_geral, 0.0001)))


func _aplicar_tela_cheia() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var modo := (
		DisplayServer.WINDOW_MODE_FULLSCREEN if tela_cheia
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
	DisplayServer.window_set_mode(modo)


func _aplicar_vsync() -> void:
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	)
