extends Node
## Estado da run atual.
##
## PRINCIPIO CENTRAL DO PITCH: nada aqui sobrevive a morte, exceto o contador
## de tentativas (que e so informativo). Se algum dia alguem quiser guardar
## "upgrade permanente" ou "moeda entre runs" nesta classe, PARE e releia o
## slide 4 - progressao permanente e exatamente o que Hardenia nao faz.

signal run_iniciada
signal run_terminada(vitoria: bool)

## Quantas vezes o jogador ja tentou. NAO da nenhum bonus. So conta a historia.
var tentativa: int = 1

## Tempo da run atual, em segundos.
var tempo_run: float = 0.0

## A run esta rolando agora?
var em_run: bool = false


func _process(delta: float) -> void:
	if em_run:
		tempo_run += delta


func iniciar_run() -> void:
	tempo_run = 0.0
	em_run = true
	run_iniciada.emit()


func terminar_run(vitoria: bool) -> void:
	if not em_run:
		return
	em_run = false
	if not vitoria:
		tentativa += 1
	run_terminada.emit(vitoria)


func reiniciar() -> void:
	terminar_run(false)
	get_tree().reload_current_scene()


func tempo_formatado() -> String:
	var minutos := int(tempo_run) / 60
	var segundos := int(tempo_run) % 60
	return "%02d:%02d" % [minutos, segundos]
