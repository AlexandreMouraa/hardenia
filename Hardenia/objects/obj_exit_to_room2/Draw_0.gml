// brilha so quando aberto e so se leva adiante (voltar nao e destacado)
if (instance_number(obj_enemy) == 0 && room_next(room) == Room2) {
    draw_set_alpha(0.2 + 0.2 * sin(current_time / 200));
    draw_set_color(c_white);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
    draw_set_alpha(1);
}
