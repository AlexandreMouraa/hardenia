var _u = tecnicas_ui();
var _n = array_length(global.tecnicas_lista);
var _d = global.tecnicas_lista[cursor];
draw_set_alpha(0.98);
draw_set_color(make_colour_rgb(10, 15, 21));
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_colour_rgb(235, 218, 174));
titulo(_u.x + 32 * _u.e, _u.y + 22 * _u.e, "Legado dos Caídos", 2 * _u.e);
draw_set_color(c_ltgray);
tecnica_texto(_u, 32, 64, string(array_length(global.tecnicas)) + " / " + string(_n) + " adquiridas nesta tentativa. Todas são perdidas ao morrer.", 0.86);
tecnica_texto(_u, 32, 87, "Explore os nós para ver efeitos, caminhos e requisitos.", 0.76);
var _grupos = ["carrasco", "batedor", "sapador", "sentinela"];
for (var _g = 0; _g < 4; _g++) {
    var _caido = variable_struct_get(global.caidos, _grupos[_g]);
    draw_set_color(_caido.cor);
    tecnica_texto(_u, 32 + 154 * _g, 119, _caido.nome, 0.75);
}
// Ligacoes derivadas dos grupos AND/OR reais. O painel explica as alternativas.
for (var _i = 0; _i < _n; _i++) {
    var _combo = global.tecnicas_lista[_i];
    if (!variable_struct_exists(_combo, "requer")) continue;
    var _fim = arvore_posicao(_i);
    for (var _g = 0; _g < array_length(_combo.requer); _g++) {
        for (var _k = 0; _k < array_length(_combo.requer[_g]); _k++) {
            var _chave = _combo.requer[_g][_k];
            for (var _j = 0; _j < _n; _j++) {
                if (global.tecnicas_lista[_j].chave != _chave) continue;
                var _ini = arvore_posicao(_j);
                var _foco = cursor == _i || cursor == _j;
                draw_set_color(_foco ? make_colour_rgb(190, 165, 104) : make_colour_rgb(53, 66, 76));
                draw_set_alpha(_foco ? 0.85 : 0.35);
                var _x1 = _u.x + (_ini[0] + 70) * _u.e;
                var _y1 = _u.y + (_ini[1] + 48) * _u.e;
                var _x2 = _u.x + (_fim[0] + 70) * _u.e;
                var _y2 = _u.y + _fim[1] * _u.e;
                draw_line_width(_x1, _y1, _x2, _y2, _foco ? 2 * _u.e : _u.e);
                if (_foco) {
                    var _t = ((current_time + _j * 140) mod 1450) / 1450;
                    draw_set_color(make_colour_rgb(255, 228, 154));
                    draw_circle(lerp(_x1, _x2, _t), lerp(_y1, _y2, _t), 2.5 * _u.e, false);
                }
            }
        }
    }
}
draw_set_alpha(1);
draw_set_color(c_ltgray);
tecnica_texto(_u, 32, 351, "COMBINAÇÕES   |   Consulte no painel os grupos E e as alternativas OU.", 0.66);
for (var _i = 0; _i < _n; _i++) {
    var _def = global.tecnicas_lista[_i];
    var _p = arvore_posicao(_i);
    var _estado = tecnica_estado(_def);
    var _cor = variable_struct_get(global.caidos, _def.caido).cor;
    var _ativa = tem_tecnica(_def.chave);
    var _r = tecnica_ret(_u, _p[0], _p[1], 140, 48);
    var _entrada = clamp((tempo - _i) / 12, 0, 1);
    tecnica_moldura(_r[0], _r[1], _r[2], _r[3], _u.e, _cor, cursor == _i, _entrada);
    tecnica_painel(_u, _p[0] + 6, _p[1] + 9, 2, 23, _cor);
    tecnica_icone(_def.chave, _u.x + (_p[0] + 17) * _u.e, _u.y + (_p[1] + 19) * _u.e, 9 * _u.e, _cor);
    draw_set_color(c_white);
    tecnica_texto(_u, _p[0] + 33, _p[1] + 5, _def.nome, 0.65, 102);
    draw_set_color(_ativa ? _cor : c_ltgray);
    var _legenda = _ativa ? "[OK] ADQUIRIDA" : (_estado == "REQUISITOS CUMPRIDOS" ? "PODE SER OFERECIDA" : _estado);
    tecnica_texto(_u, _p[0] + 9, _p[1] + 35, _legenda, 0.48);
}
draw_set_alpha(1);
tecnica_painel(_u, 664, 112, 264, 360, make_colour_rgb(23, 30, 39));
var _cor = variable_struct_get(global.caidos, _d.caido).cor;
tecnica_icone(_d.chave, _u.x + 691 * _u.e, _u.y + 142 * _u.e, 15 * _u.e, _cor);
draw_set_color(_cor);
tecnica_texto(_u, 716, 126, _d.nome, 0.87, 198);
draw_set_color(c_ltgray);
tecnica_texto(_u, 680, 175, tecnica_estado(_d), 0.68);
draw_set_color(c_white);
tecnica_texto(_u, 680, 201, "ATIVAÇÃO", 0.7);
tecnica_texto(_u, 680, 219, _d.ativacao, 0.73, 232);
draw_set_color(c_ltgray);
tecnica_texto(_u, 680, 258, _d.detalhe, 0.73, 232);
draw_set_color(_cor);
tecnica_texto(_u, 680, 326, "REQUISITOS", 0.7);
draw_set_color(c_white);
tecnica_texto(_u, 680, 345, tecnica_requisitos(_d), 0.65, 232);
draw_set_color(c_ltgray);
tecnica_texto(_u, 32, 448, "Requisitos cumpridos permitem aparecer em uma oferta. É preciso escolher a técnica para adquiri-la.", 0.72, 610);
tecnica_texto(_u, 32, 490, global.toque_ativo ? "Toque em um nó para consultar." : (global.ultimo_aparelho == "controle" ? "ALAVANCA: explorar    B: voltar" : "SETAS / WASD: explorar    TAB / ESC: voltar"), 0.75);
tecnica_botao(_u, 792, 486, 136, "VOLTAR");
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
