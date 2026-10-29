var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);

var _alpha = 0.5 + 0.5 * sin(current_time / 200);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_set_alpha(_alpha);
draw_text_transformed(_w / 2, _h - 60 * _esc, "PRESSIONE ENTER PARA INICIAR", _esc, _esc, 0);
draw_set_alpha(1);

draw_set_color(c_ltgray);
draw_text_transformed(_w / 2, _h - 30 * _esc, "WASD / SETAS: mover    J: atacar    ESPACO: dash    ESC: pausar", _esc * 0.8, _esc * 0.8, 0);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
