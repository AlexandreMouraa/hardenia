var _alpha = 0.5 + 0.5 * sin(current_time / 200);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_set_alpha(_alpha);
draw_text(display_get_gui_width() / 2, display_get_gui_height() - 60, "PRESSIONE ENTER PARA INICIAR");
draw_set_alpha(1);
