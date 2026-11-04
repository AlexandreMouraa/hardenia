var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);
var _surgir = min(1, tempo / 10);

draw_set_alpha(0.72 * _surgir);
draw_set_color(c_black);
draw_rectangle(0, 0, _w, _h, false);
draw_set_alpha(_surgir);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(c_white);
titulo(_w / 2, _h / 2 - 158 * _esc, "O que os Caídos deixaram", _esc * 1.7);
draw_set_color(c_ltgray);
texto(_w / 2, _h / 2 - 122 * _esc, "Vale até a próxima morte. Fique com uma.", _esc * 0.85, _esc * 0.85, 0);

for (var _i = 0; _i < array_length(oferta); _i++) {
    var _r = carta(_i);
    var _def = oferta[_i];
    var _cor = variable_struct_get(global.caidos, _def.caido).cor;
    var _caido = variable_struct_get(global.caidos, _def.caido).nome;
    var _dupla = variable_struct_exists(_def, "caido2");
    var _cor2 = _dupla ? variable_struct_get(global.caidos, _def.caido2).cor : _cor;
    var _foco = (escolhido >= 0) ? (_i == escolhido) : (_i == cursor);
    var _sobe = _foco ? 6 * _esc : 0;
    var _cx = (_r[0] + _r[2]) / 2;
    var _top = _r[1] - _sobe;
    var _fim = _r[3] - _sobe;
    var _alfa = _surgir * ((escolhido >= 0 && _i != escolhido) ? 0.25 : 1);
    draw_set_alpha(_alfa);
    draw_set_color(make_colour_rgb(24, 18, 20));
    draw_rectangle(_r[0], _top, _r[2], _fim, false);
    draw_set_color(_cor);
    draw_rectangle(_r[0], _top, _r[2], _top + 6 * _esc, false);
    draw_rectangle(_r[0], _top, _r[2], _fim, true);
    if (_dupla) {
        // combinacao: as duas cores, e os dois nomes
        draw_set_color(_cor2);
        draw_rectangle(_cx, _top, _r[2], _top + 6 * _esc, false);
        _caido = "COMBINAÇÃO";
        draw_set_color(c_white);
    }
    if (_foco) {
        draw_rectangle(_r[0] - 1, _top - 1, _r[2] + 1, _fim + 1, true);
        draw_rectangle(_r[0] - 2, _top - 2, _r[2] + 2, _fim + 2, true);
    }
    texto(_cx, _top + 16 * _esc, _caido, _esc * 0.75, _esc * 0.75, 0);
    draw_set_color(c_white);
    texto_ext(_cx, _top + 40 * _esc, _def.nome, 18, (_r[2] - _r[0] - 16 * _esc) / (_esc * 1.05), _esc * 1.05, _esc * 1.05, 0);
    draw_set_color(c_ltgray);
    texto_ext(_cx, _top + 84 * _esc, _def.texto, 19, (_r[2] - _r[0] - 20 * _esc) / (_esc * 0.75), _esc * 0.75, _esc * 0.75, 0);
    if (!global.toque_ativo) {
        draw_set_color(c_gray);
        texto(_cx, _fim - 18 * _esc, string(_i + 1), _esc * 0.8, _esc * 0.8, 0);
    }
}
draw_set_alpha(_surgir);
draw_set_color(c_ltgray);
texto(_w / 2, _h / 2 + 122 * _esc, global.toque_ativo ? "Toque na técnica" : "A / D ou 1 2 3 para escolher    ENTER confirma    Também dá para clicar", _esc * 0.75, _esc * 0.75, 0);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
