var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);
draw_set_alpha(0.86);
draw_set_color(make_colour_rgb(10, 7, 8));
draw_rectangle(0, 0, _w, _h, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (modo == "opcoes") {
    titulo(_w / 2, _h / 2 - 158 * _esc, "Opções", _esc * 2);
    draw_set_valign(fa_middle);
    for (var _i = 0; _i < array_length(itens); _i++) {
        var _r = item_ret(_i);
        var _it = itens[_i];
        var _foco = (_i == cursor);
        var _meio = (_r[1] + _r[3]) / 2;
        if (_foco) {
            draw_set_alpha(0.75);
            draw_set_color(make_colour_rgb(90, 14, 20));
            draw_rectangle(_r[0], _r[1], _r[2], _r[3], false);
            draw_set_alpha(1);
        }
        draw_set_color(_foco ? c_white : c_ltgray);
        if (_it.tipo == "sair") {
            texto(_w / 2, _meio, _it.nome, _esc, _esc, 0);
            continue;
        }
        draw_set_halign(fa_left);
        texto(_r[0] + 10 * _esc, _meio, _it.nome, _esc, _esc, 0);
        draw_set_halign(fa_right);
        if (_it.tipo == "barra") {
            var _bx = _r[2] - 150 * _esc;
            var _bw = 140 * _esc;
            draw_set_color(make_colour_rgb(50, 44, 46));
            draw_rectangle(_bx, _meio - 4 * _esc, _bx + _bw, _meio + 4 * _esc, false);
            draw_set_color(_foco ? make_colour_rgb(230, 70, 60) : make_colour_rgb(170, 60, 55));
            draw_rectangle(_bx, _meio - 4 * _esc, _bx + _bw * _it.ler(), _meio + 4 * _esc, false);
        } else {
            texto(_r[2] - 10 * _esc, _meio, _it.ler(), _esc, _esc, 0);
        }
        draw_set_halign(fa_center);
    }
    draw_set_color(c_gray);
    texto(_w / 2, _h / 2 + 136 * _esc, global.toque_ativo ? "Toque no que quer mudar" : ((global.ultimo_aparelho == "controle") ? "ALAVANCA: escolher e mudar    A: confirmar    B: voltar" : "W / S: escolher    A / D ou ENTER: mudar    ESC: voltar"), _esc * 0.85, _esc * 0.85, 0);
} else if (modo == "como_jogar") {
    titulo(_w / 2, _h * 0.13, "Como jogar", _esc * 2);
    var _linhas = [
        ["Andar", "WASD ou setas", "alavanca", "polegar à esquerda da tela"],
        ["Golpe (seguidos: combo)", "clique ou J", "RB ou X", "ATACAR"],
        ["Golpe carregado (quebra escudo)", "segurar o ataque", "segurar o ataque", "segurar ATACAR"],
        ["Dash (atravessa o golpe)", "espaço", "A ou LB", "DASH"],
        ["Estocada (quebra escudo)", "atacar no dash", "atacar no dash", "ATACAR no dash"],
        ["Giro (acerta em volta)", "clique direito ou K", "B", "GIRO"],
        ["Giro Furioso (Fúria cheia)", "segurar o giro", "segurar B", "segurar GIRO"],
        ["Pausa", "Esc", "Start", "II"],
    ];
    var _xs = [_w * 0.11, _w * 0.42, _w * 0.62, _w * 0.77];
    var _cab = ["", "TECLADO E MOUSE", "CONTROLE", "TOQUE"];
    var _ly = _h * 0.26;
    draw_set_halign(fa_left);
    draw_set_color(make_colour_rgb(230, 90, 70));
    for (var _c = 1; _c < 4; _c++) {
        texto(_xs[_c], _ly, _cab[_c], _esc * 0.85, _esc * 0.85, 0);
    }
    for (var _l = 0; _l < array_length(_linhas); _l++) {
        var _yy = _ly + (_l + 1) * 26 * _esc;
        for (var _c = 0; _c < 4; _c++) {
            draw_set_color((_c == 0) ? c_white : c_ltgray);
            texto(_xs[_c], _yy, _linhas[_l][_c], _esc * 0.9, _esc * 0.9, 0);
        }
    }
    draw_set_halign(fa_center);
    draw_set_color(c_ltgray);
    texto(_w / 2, _h * 0.8, "Saia da zona vermelha antes do golpe. Depois do golpe o inimigo fica apagado: é a hora de bater.", _esc * 0.95, _esc * 0.95, 0);
    texto(_w / 2, _h * 0.8 + 22 * _esc, "Morrer recomeça a run sem as técnicas. O que fica é o que você aprendeu.", _esc * 0.95, _esc * 0.95, 0);
} else {
    titulo(_w / 2, _h * 0.13, "Créditos", _esc * 2);
    var _cred = [
        ["Equipe", global.creditos_equipe],
        ["Música", "Kevin MacLeod (incompetech.com), licença CC BY 4.0: Ossuary 1 - A Beginning, Gathering Darkness,\nOssuary 6 - Air, Unholy Knight, Five Armies e Lost Time"],
        ["Personagens", "Peças do Universal LPC Spritesheet Character Generator, por seus autores (OGA-BY, CC-BY-SA, GPL)"],
        ["Efeitos sonoros", "Kenney (CC0) e sons gerados para o jogo"],
        ["Fontes", "Grenze e Grenze Gotisch, de Omnibus-Type (SIL OFL 1.1)"],
    ];
    var _cy = _h * 0.26;
    for (var _i = 0; _i < array_length(_cred); _i++) {
        draw_set_color(make_colour_rgb(230, 90, 70));
        texto(_w / 2, _cy, _cred[_i][0], _esc * 0.85, _esc * 0.85, 0);
        draw_set_color(c_white);
        texto(_w / 2, _cy + 22 * _esc, _cred[_i][1], _esc * 0.9, _esc * 0.9, 0);
        _cy += (_i == 1 ? 66 : 52) * _esc;
    }
    draw_set_color(c_ltgray);
    texto(_w / 2, _cy + 6 * _esc, "A lista completa, com todos os autores, está no site do jogo.", _esc * 0.85, _esc * 0.85, 0);
}
if (modo != "opcoes") {
    draw_set_color(c_gray);
    texto(_w / 2, _h - 30 * _esc, global.toque_ativo ? "Toque para voltar" : ((global.ultimo_aparelho == "controle") ? "B: voltar" : "ESC, ENTER ou clique: voltar"), _esc * 0.85, _esc * 0.85, 0);
}
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
