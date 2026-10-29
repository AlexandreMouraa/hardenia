var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);
var _inimigos = instance_number(obj_enemy);
var _piscar = 0.5 + 0.5 * sin(current_time / 200);

// HUD: tentativa e cargas de dash
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text_transformed(16 * _esc, 12 * _esc, "TENTATIVA " + string(global.tentativas), _esc, _esc, 0);

for (var _i = 0; _i < dash_charges_max; _i++) {
    var _px = 16 * _esc + _i * 16 * _esc;
    var _py = 36 * _esc;
    draw_set_color(_i < dash_charges ? c_white : c_dkgray);
    draw_rectangle(_px, _py, _px + 12 * _esc, _py + 6 * _esc, false);
}

// HUD: inimigos restantes ou portao aberto
draw_set_halign(fa_right);
if (_inimigos > 0) {
    draw_set_color(c_white);
    draw_text_transformed(_w - 16 * _esc, 12 * _esc, "INIMIGOS: " + string(_inimigos), _esc, _esc, 0);
} else if (room != room_last) {
    draw_set_color(c_yellow);
    draw_set_alpha(_piscar);
    draw_text_transformed(_w - 16 * _esc, 12 * _esc, "PORTAO ABERTO", _esc, _esc, 0);
    draw_set_alpha(1);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (is_dead) {
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    draw_set_color(c_red);
    draw_text_transformed(_w / 2, _h / 2 - 20 * _esc, "VOCE MORREU", _esc * 3, _esc * 3, 0);
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h / 2 + 24 * _esc, "Cada morte ensina.", _esc, _esc, 0);
} else if (venceu) {
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    draw_set_color(c_red);
    draw_text_transformed(_w / 2, _h / 2 - 40 * _esc, "VITORIA", _esc * 3, _esc * 3, 0);
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h / 2 + 8 * _esc, "O ultimo guerreiro venceu em " + string(global.tentativas) + " tentativa(s).", _esc, _esc, 0);
    draw_set_alpha(_piscar);
    draw_text_transformed(_w / 2, _h / 2 + 40 * _esc, "PRESSIONE ENTER PARA VOLTAR AO MENU", _esc, _esc, 0);
    draw_set_alpha(1);
}

if (global.game_paused) {
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(_piscar);
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h / 2 - 40 * _esc, "PAUSADO", _esc * 2, _esc * 2, 0);
    draw_set_alpha(1);
    draw_text_transformed(_w / 2, _h / 2, "WASD / SETAS: mover    J: atacar    ESPACO: dash", _esc, _esc, 0);
    draw_text_transformed(_w / 2, _h / 2 + 32 * _esc, "PRESSIONE ESC PARA CONTINUAR", _esc, _esc, 0);
}

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
