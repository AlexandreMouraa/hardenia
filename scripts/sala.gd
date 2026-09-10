@tool
extends Node2D
class_name Sala
## Uma sala de Hardenia. E a unidade de trabalho do level design.
##
## Ajuste "canto_inicio" e "canto_fim" no Inspetor: o retangulo vermelho que
## aparece no editor e exatamente a area que a camera pode enxergar.
## Em sala pequena a camera fica parada, em sala larga ela rola.
## Isso garante que o jogador sempre ve o que vai mata-lo - se ele morreu,
## a informacao estava na tela. E o contrato de honestidade de Hardenia.

## Canto superior-esquerdo da sala, em coordenadas locais.
@export var canto_inicio := Vector2.ZERO:
	set(v):
		canto_inicio = v
		queue_redraw()

## Canto inferior-direito da sala, em coordenadas locais.
@export var canto_fim := Vector2(640, 360):
	set(v):
		canto_fim = v
		queue_redraw()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	await get_tree().process_frame
	aplicar_limites_da_camera()


func aplicar_limites_da_camera() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		push_warning("Sala '%s': nenhuma Camera2D ativa encontrada." % name)
		return
	camera.limit_left = int(global_position.x + canto_inicio.x)
	camera.limit_top = int(global_position.y + canto_inicio.y)
	camera.limit_right = int(global_position.x + canto_fim.x)
	camera.limit_bottom = int(global_position.y + canto_fim.y)
	camera.reset_smoothing()


func _draw() -> void:
	## Contorno visivel so no editor, para o level designer enxergar a sala.
	if not Engine.is_editor_hint():
		return
	draw_rect(Rect2(canto_inicio, canto_fim - canto_inicio), Color("901b1d"), false, 2.0)
