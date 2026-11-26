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
titulo(_w / 2, _h / 2 - 158 * _esc, "Uma arma no chão", _esc * 1.7);
draw_set_color(c_ltgray);
texto(_w / 2, _h / 2 - 122 * _esc, "A que sair da mão fica no chão. Vale até a próxima morte.", _esc * 0.85, _esc * 0.85, 0);

for (var _i = 0; _i < 2; _i++) {
    var _r = carta(_i);
    var _chave = oferta[_i].chave;
    var _def = arma_def(_chave);
    var _cor = arma_cor(_chave);
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
    if (_foco) {
        draw_rectangle(_r[0] - 1, _top - 1, _r[2] + 1, _fim + 1, true);
        draw_rectangle(_r[0] - 2, _top - 2, _r[2] + 2, _fim + 2, true);
    }
    texto(_cx, _top + 16 * _esc, (_i == 0) ? "FICAR COM" : "TROCAR POR", _esc * 0.75, _esc * 0.75, 0);
    arma_icone(_chave, _cx, _top + 62 * _esc, 18 * _esc, _cor);
    draw_set_alpha(_alfa);
    draw_set_color(c_white);
    texto_ext(_cx, _top + 96 * _esc, _def.nome, 18, (_r[2] - _r[0] - 16 * _esc) / (_esc * 1.05), _esc * 1.05, _esc * 1.05, 0);
    draw_set_color(c_ltgray);
    texto_ext(_cx, _top + 136 * _esc, _def.texto, 19, (_r[2] - _r[0] - 20 * _esc) / (_esc * 0.75), _esc * 0.75, _esc * 0.75, 0);
    // a Furia da arma, na cor dela: cada uma tem a sua (scr_armas)
    draw_set_color(_cor);
    texto_ext(_cx, _top + 176 * _esc, "FÚRIA, " + _def.furia + ": " + _def.furia_texto, 17, (_r[2] - _r[0] - 20 * _esc) / (_esc * 0.65), _esc * 0.65, _esc * 0.65, 0);
    if (!global.toque_ativo) {
        draw_set_color(c_gray);
        texto(_cx, _fim - 18 * _esc, string(_i + 1), _esc * 0.8, _esc * 0.8, 0);
    }
}
draw_set_alpha(_surgir);
draw_set_color(c_ltgray);
texto(_w / 2, _h / 2 + 166 * _esc, global.toque_ativo ? "Toque na sua escolha" : ((global.ultimo_aparelho == "controle") ? "ALAVANCA para escolher    A confirma    B fica" : "A / D ou 1 2 para escolher    ENTER confirma    ESC fica"), _esc * 0.75, _esc * 0.75, 0);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
