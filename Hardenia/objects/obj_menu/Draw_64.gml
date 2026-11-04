// com o mapa da fase 1, a abertura ou outra tela aberta, os textos do menu saem da frente
if (instance_exists(obj_mapa) || instance_exists(obj_abertura) || instance_exists(obj_opcoes)) {
    exit;
}

var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);

// fagulhas subindo sobre a arte. Sem random: o robo depende do RNG
gpu_set_blendmode(bm_add);
for (var _i = 0; _i < 34; _i++) {
    var _sobe = (current_time * (0.012 + 0.02 * frac(_i * 0.37)) + _i * 73) mod (_h + 40);
    var _fx = _w * frac(_i * 0.618034) + 14 * _esc * sin(current_time / 900 + _i);
    var _fy = _h + 20 - _sobe;
    var _r = (1 + 2 * frac(_i * 0.73)) * _esc * 0.5;
    draw_set_alpha(0.2 + 0.5 * frac(_i * 0.41));
    draw_set_color(make_colour_rgb(255, 130 + 60 * frac(_i * 0.29), 50));
    draw_rectangle(_fx - _r, _fy - _r, _fx + _r, _fy + _r, false);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// os itens, com uma faixa escura atras: a arte e clara nesse lado
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
for (var _i = 0; _i < array_length(itens); _i++) {
    var _r = item_ret(_i);
    var _foco = (_i == cursor);
    var _meio = (_r[1] + _r[3]) / 2;
    draw_set_alpha(_foco ? 0.78 : 0.42);
    draw_set_color(_foco ? make_colour_rgb(90, 14, 20) : c_black);
    draw_rectangle(_r[0], _r[1] + 2 * _esc, _r[2], _r[3] - 2 * _esc, false);
    draw_set_alpha(1);
    draw_set_color(_foco ? c_white : c_ltgray);
    titulo(_r[0] + 12 * _esc, _meio, itens[_i].nome, _esc * 1.25);
}

if (itens[cursor].acao == "desafio") {
    var _d = item_ret(array_length(itens));
    draw_set_color(c_ltgray);
    texto(_d[0], _d[1] + 10 * _esc, "A mesma run para todo mundo hoje, com ranking próprio.", _esc * 0.8, _esc * 0.8, 0);
}

// recordes do aparelho
var _s = global.salvo;
if (_s.mortes_total > 0 || _s.vitorias > 0) {
    var _linha = "Mortes: " + string(_s.mortes_total) + "    Vitórias: " + string(_s.vitorias) + "    Caídos libertados: " + string(array_length(_s.caidos_livres)) + " de " + string(array_length(global.caidos_chaves));
    if (_s.melhor_ms > 0) {
        _linha += "    Melhor: " + tempo_texto(_s.melhor_ms) + " em " + string(_s.melhor_tentativas) + " tentativa(s)";
    }
    draw_set_color(c_ltgray);
    texto(16 * _esc, _h - 20 * _esc, _linha, _esc * 0.8, _esc * 0.8, 0);
}

draw_set_color(c_ltgray);
draw_set_halign(fa_right);
draw_set_valign(fa_top);
texto(_w - 16 * _esc, 12 * _esc, os_browser == browser_not_a_browser ? "ESC: sair do jogo" : "F11: tela cheia", _esc * 0.8, _esc * 0.8, 0);

draw_set_color(c_yellow);
texto(_w - 16 * _esc, 40 * _esc, "H OU TOQUE: TESTE DE HORDA", _esc * 0.8, _esc * 0.8, 0);
draw_set_color(c_ltgray);

draw_set_halign(fa_left);
texto(16 * _esc, 12 * _esc, "v" + VERSAO_JOGO, _esc * 0.7, _esc * 0.7, 0);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
