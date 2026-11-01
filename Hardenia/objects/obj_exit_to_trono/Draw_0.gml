// aberto e levando adiante: luz quente pulsando no arco (voltar nao e destacado)
if (instance_number(obj_enemy) == 0 && room_next(room) == Room_Trono) {
    var _pulso = 0.5 + 0.5 * sin(current_time / 250);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.25 + 0.35 * _pulso);
    draw_rectangle_colour(bbox_left, bbox_top, bbox_right, bbox_bottom, c_yellow, c_yellow, c_orange, c_orange, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}
