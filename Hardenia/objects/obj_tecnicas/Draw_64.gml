if (instance_exists(obj_arvore)) exit;
var _u = tecnicas_ui();
var _n = array_length(oferta);
draw_set_alpha(0.96);
draw_set_color(make_colour_rgb(11, 15, 21));
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_colour_rgb(236, 218, 176));
titulo(_u.x + 52 * _u.e, _u.y + 24 * _u.e, "Escolha seu legado", 2 * _u.e);
draw_set_color(c_ltgray);
tecnica_texto(_u, 52, 64, caido_def != undefined ? caido_def.adeus : "Aprenda uma técnica. Ela vale até a próxima morte.", 0.85);
tecnica_texto(_u, 52, 86, string(array_length(global.tecnicas)) + " técnicas adquiridas nesta tentativa", 0.72);
tecnica_botao(_u, 720, 64, 188, "ÁRVORE DE TÉCNICAS");
for (var _i = 0; _i < _n; _i++) {
    var _def = oferta[_i];
    var _caido = variable_struct_get(global.caidos, _def.caido);
    var _x = (960 - (_n * 272 + (_n - 1) * 20)) / 2 + _i * 292;
    var _foco = _i == cursor;
    // entrada: cada carta sobe e aparece, uma atras da outra; a em foco fica um pouco mais alta
    var _vida = premium_entrada(tempo, _i);
    var _y = (_foco ? 117 : 123) + 40 * (1 - _vida) * (1 - _vida);
    var _ativa = escolhido < 0 || escolhido == _i;
    draw_set_alpha(_ativa ? 1 : 0.35);
    var _r = tecnica_ret(_u, _x, _y, 272, 330);
    painel_premium(_r[0], _r[1], _r[2], _r[3], _caido.cor, _foco, _vida, _u.e);
    if (variable_struct_exists(_def, "caido2")) {
        draw_set_alpha((_ativa ? 1 : 0.35) * _vida);
        tecnica_painel(_u, _x + 136, _y, 136, 4, variable_struct_get(global.caidos, _def.caido2).cor);
    }
    draw_set_alpha((_ativa ? 1 : 0.35) * _vida);
    // icone com um halo da cor do Caido atras
    gpu_set_blendmode(bm_add);
    draw_set_alpha((_ativa ? 0.35 : 0.1) * _vida);
    draw_set_color(_caido.cor);
    draw_circle(_u.x + (_x + 35) * _u.e, _u.y + (_y + 35) * _u.e, 24 * _u.e, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha((_ativa ? 1 : 0.35) * _vida);
    tecnica_icone(_def.chave, _u.x + (_x + 35) * _u.e, _u.y + (_y + 35) * _u.e, 17 * _u.e, _caido.cor);
    draw_set_color(_caido.cor);
    tecnica_texto(_u, _x + 65, _y + 17, variable_struct_exists(_def, "requer") ? "COMBINAÇÃO" : _caido.nome, 0.65);
    draw_set_color(c_white);
    tecnica_texto(_u, _x + 65, _y + 35, _def.nome, 0.95, 192);
    draw_set_color(c_ltgray);
    tecnica_texto(_u, _x + 18, _y + 88, _def.detalhe, 0.83, 236);
    draw_set_color(_caido.cor);
    tecnica_texto(_u, _x + 18, _y + 166, "ATIVAÇÃO", 0.7);
    draw_set_color(c_white);
    tecnica_texto(_u, _x + 18, _y + 185, _def.ativacao, 0.78, 236);
    draw_set_color(_caido.cor);
    tecnica_texto(_u, _x + 18, _y + 237, variable_struct_exists(_def, "requer") ? "REQUISITOS CUMPRIDOS" : "CAMINHOS DE COMBINAÇÃO", 0.65);
    draw_set_color(c_ltgray);
    tecnica_texto(_u, _x + 18, _y + 257, variable_struct_exists(_def, "requer") ? "Consulte as ligações na árvore." : tecnica_caminhos(_def.chave), 0.68, 236);
    draw_set_color(_foco ? c_white : c_gray);
    tecnica_texto(_u, _x + 18, _y + 308, escolhido == _i ? "[OK] ADQUIRIDA" : string(_i + 1) + "   " + (_foco ? "CONFIRMAR ESCOLHA" : "SELECIONAR"), 0.68);
}
draw_set_alpha(1);
draw_set_color(c_ltgray);
tecnica_texto(_u, 52, 474, global.toque_ativo ? "Toque em uma carta para escolher. Consulte sua construção na árvore." : (global.ultimo_aparelho == "controle" ? "ALAVANCA: selecionar    A: confirmar    Y: árvore" : "A / D ou SETAS: selecionar    ENTER: confirmar    1 2 3: escolher    TAB: árvore"), 0.77);
draw_set_color(make_colour_rgb(169, 182, 190));
tecnica_texto(_u, 52, 500, "A árvore mostra possibilidades. Técnicas só são adquiridas ao confirmar uma das ofertas.", 0.72);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
