if (carta >= array_length(global.abertura)) {
    exit;
}
var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);
draw_set_color(c_black);
draw_rectangle(0, 0, _w, _h, false);

// fagulhas subindo no escuro. Sem random: o robo depende do RNG
gpu_set_blendmode(bm_add);
for (var _i = 0; _i < 40; _i++) {
    var _sobe = (current_time * (0.012 + 0.02 * frac(_i * 0.37)) + _i * 73) mod (_h + 40);
    var _fx = _w * frac(_i * 0.618034) + 14 * _esc * sin(current_time / 900 + _i);
    var _fy = _h + 20 - _sobe;
    var _r = (1 + 2 * frac(_i * 0.73)) * _esc * 0.5;
    draw_set_alpha(0.15 + 0.5 * frac(_i * 0.41));
    draw_set_color(make_colour_rgb(255, 130 + 60 * frac(_i * 0.29), 50));
    draw_rectangle(_fx - _r, _fy - _r, _fx + _r, _fy + _r, false);
}
gpu_set_blendmode(bm_normal);

// o guerreiro aparece quando a frase fala dele
if (carta >= 2) {
    var _quadro = (current_time div 200) mod 4;
    draw_sprite_ext(spr_player_idle, 3 * 4 + _quadro, _w / 2, _h * 0.76, 3 * _esc, 3 * _esc, 0, c_white, min(1, tempo / 30));
}

var _duracao = instance_exists(obj_autotest) ? 40 : por_carta;
var _alfa = min(1, min(tempo, _duracao - tempo) / 25);
draw_set_alpha(_alfa);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
texto(_w / 2, _h * 0.42, global.abertura[carta], _esc * 1.5, _esc * 1.5, 0);
draw_set_alpha(0.5);
draw_set_color(c_gray);
texto(_w / 2, _h - 24 * _esc, "ENTER ou CLIQUE: continuar", _esc * 0.8, _esc * 0.8, 0);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
