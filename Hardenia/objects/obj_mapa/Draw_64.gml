var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);

// escurece a sala, mostra o mapa e escurece de vez no fim (a sala nova clareia
// sozinha, ver fade do obj_player)
var _entrada = min(1, tempo / 15);
var _fim = clamp((tempo - (duracao - 15)) / 15, 0, 1);
// saindo do menu escurece mais: a arte do titulo e clara
draw_set_alpha((de < 0 ? 0.96 : 0.88) * _entrada);
draw_set_colour(c_black);
draw_rectangle(0, 0, _w, _h, false);

// o guerreiro anda de uma fase para a outra entre 0,3 s e 1,3 s, com
// arrancada e freada suaves
var _ini = (de < 0) ? -0.6 : de;
var _t = clamp((tempo - 18) / 60, 0, 1);
_t = _t * _t * (3 - 2 * _t);
var _pos = lerp(_ini, para, _t);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_colour(c_ltgray);
draw_set_alpha(_entrada);
draw_text_transformed(_w / 2, _h * 0.3, "FASE " + string(para + 1) + " DE " + string(array_length(global.mapa_fases)), _esc, _esc, 0);
draw_set_colour(c_white);
draw_text_transformed(_w / 2, _h * 0.3 + 34 * _esc, global.mapa_fases[para].nome, _esc * 1.8, _esc * 1.8, 0);
draw_set_alpha(1);

mapa_desenhar(_h * 0.56, _esc, _pos, _entrada);

if (tempo > pode_pular) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(c_gray);
    draw_set_alpha(0.4 + 0.6 * (0.5 + 0.5 * sin(current_time / 200)));
    draw_text_transformed(_w / 2, _h - 40 * _esc, "ENTER ou CLIQUE: continuar", _esc * 0.8, _esc * 0.8, 0);
}

if (_fim > 0) {
    draw_set_alpha(_fim);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _w, _h, false);
}
draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
