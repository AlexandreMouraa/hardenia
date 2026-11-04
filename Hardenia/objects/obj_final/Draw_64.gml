var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);
draw_set_alpha(0.92 * surgir);
draw_set_color(c_black);
draw_rectangle(0, 0, _w, _h, false);
var _duracao = instance_exists(obj_autotest) ? 40 : por_carta;
var _alfa = min(1, min(tempo, _duracao - tempo) / 25) * surgir;
draw_set_alpha(_alfa);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
if (carta < array_length(cartas)) {
    texto(_w / 2, _h * 0.46, cartas[carta], _esc * 1.5, _esc * 1.5, 0);
} else {
    titulo(_w / 2, _h * 0.36, "Hardenia", _esc * 3.4);
    texto(_w / 2, _h * 0.36 + 52 * _esc, "O último guerreiro", _esc * 1.1, _esc * 1.1, 0);
    draw_set_color(c_ltgray);
    texto(_w / 2, _h * 0.62, global.creditos_equipe, _esc, _esc, 0);
    texto(_w / 2, _h * 0.62 + 24 * _esc, "Arte, sons e músicas de terceiros: lista completa no site do jogo.", _esc * 0.8, _esc * 0.8, 0);
}
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
