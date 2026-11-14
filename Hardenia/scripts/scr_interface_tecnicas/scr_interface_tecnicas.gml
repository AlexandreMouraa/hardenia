global.consulta_bloqueio = 0;

// Coordenadas logicas comuns a cartas e arvore; cabem tambem em janelas menores que 960x540.
function tecnicas_ui() {
    var _e = min(display_get_gui_width() / 960, display_get_gui_height() / 540);
    return { e: _e, x: (display_get_gui_width() - 960 * _e) / 2,
        y: (display_get_gui_height() - 540 * _e) / 2 };
}

function tecnica_ret(_u, _x, _y, _w, _h) {
    return [_u.x + _x * _u.e, _u.y + _y * _u.e,
        _u.x + (_x + _w) * _u.e, _u.y + (_y + _h) * _u.e];
}

function tecnica_painel(_u, _x, _y, _w, _h, _cor, _borda = false) {
    var _r = tecnica_ret(_u, _x, _y, _w, _h);
    draw_set_color(_cor);
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], _borda);
}

function tecnica_texto(_u, _x, _y, _s, _esc = 1, _largura = 0) {
    if (_largura > 0) {
        texto_ext(_u.x + _x * _u.e, _u.y + _y * _u.e, _s, 18,
            _largura / _esc, _u.e * _esc, _u.e * _esc, 0);
    } else {
        texto(_u.x + _x * _u.e, _u.y + _y * _u.e, _s, _u.e * _esc, _u.e * _esc, 0);
    }
}

function tecnica_botao(_u, _x, _y, _w, _rotulo) {
    tecnica_painel(_u, _x, _y, _w, 32, make_colour_rgb(29, 37, 45));
    tecnica_painel(_u, _x, _y, _w, 32, make_colour_rgb(137, 154, 164), true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    tecnica_texto(_u, _x + _w / 2, _y + 16, _rotulo, 0.76);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function tecnica_clicou(_r) {
    return (mouse_check_button_pressed(mb_left)
        && point_in_rectangle(ponteiro_gui_x(0), ponteiro_gui_y(0), _r[0], _r[1], _r[2], _r[3]))
        || (global.toque_ativo && toque_tap_em(_r));
}

function tecnica_em_oferta(_chave) {
    if (instance_exists(obj_tecnicas)) {
        var _oferta = obj_tecnicas.oferta;
        for (var _i = 0; _i < array_length(_oferta); _i++) {
            if (_oferta[_i].chave == _chave) return true;
        }
    }
    return false;
}

function tecnica_estado(_d) {
    if (tem_tecnica(_d.chave)) return "ADQUIRIDA";
    if (tecnica_em_oferta(_d.chave)) return "EM OFERTA";
    if (!variable_struct_exists(_d, "requer")) return "NÃO ADQUIRIDA";
    return combinacao_liberada(_d) ? "REQUISITOS CUMPRIDOS" : "BLOQUEADA";
}

// AND entre grupos, OR dentro do grupo: a interface usa os requisitos reais do sorteio.
function tecnica_requisitos(_d) {
    if (!variable_struct_exists(_d, "requer")) return "Técnica básica: pode aparecer nas ofertas.";
    var _s = "";
    for (var _g = 0; _g < array_length(_d.requer); _g++) {
        var _grupo = _d.requer[_g];
        var _tem = false;
        var _nomes = "";
        for (var _i = 0; _i < array_length(_grupo); _i++) {
            _tem = _tem || tem_tecnica(_grupo[_i]);
            _nomes += (_i > 0 ? " OU " : "") + tecnica_def(_grupo[_i]).nome;
        }
        _s += (_g > 0 ? "\nE\n" : "") + (_tem ? "[OK] " : "[FALTA] ") + _nomes;
    }
    return _s;
}

function tecnica_caminhos(_chave) {
    var _s = "";
    for (var _i = 0; _i < array_length(global.tecnicas_lista); _i++) {
        var _d = global.tecnicas_lista[_i];
        if (!variable_struct_exists(_d, "requer")) continue;
        var _usa = false;
        for (var _g = 0; _g < array_length(_d.requer); _g++) {
            _usa = _usa || array_contains(_d.requer[_g], _chave);
        }
        if (_usa) _s += (_s == "" ? "" : "\n") + _d.nome;
    }
    return _s == "" ? "Combinação final desta linhagem." : _s;
}

// Icones vetoriais compartilhados pelo HUD, cartas e arvore. Nenhum arquivo externo ou fonte de icones.
function tecnica_icone(_chave, _x, _y, _r, _cor) {
    var _i = 0;
    for (var _n = 0; _n < array_length(global.tecnicas_lista); _n++) {
        if (global.tecnicas_lista[_n].chave == _chave) { _i = _n; break; }
    }
    draw_set_color(_cor);
    var _esp = max(1, _r / 7);
    switch (_i) {
        case 0: // gota
            draw_triangle(_x, _y - _r, _x - _r * 0.6, _y + _r * 0.3, _x + _r * 0.6, _y + _r * 0.3, false);
            draw_circle(_x, _y + _r * 0.3, _r * 0.6, false);
            break;
        case 1: // machado
            draw_line_width(_x - _r * 0.6, _y + _r, _x + _r * 0.4, _y - _r, _esp);
            draw_triangle(_x, _y - _r, _x + _r, _y - _r * 0.4, _x + _r * 0.4, _y + _r * 0.2, false);
            break;
        case 2: case 4: case 10: // passo ou bomba
            draw_line_width(_x - _r, _y, _x + _r * 0.7, _y, _esp);
            draw_line_width(_x, _y - _r * 0.6, _x + _r * 0.7, _y, _esp);
            draw_line_width(_x, _y + _r * 0.6, _x + _r * 0.7, _y, _esp);
            if (_i != 2) draw_circle(_x - _r * 0.5, _y - _r * 0.5, _r * 0.45, true);
            if (_i == 10) draw_circle(_x + _r * 0.7, _y + _r * 0.5, _r * 0.25, false);
            break;
        case 3: // tres cargas
            for (var _f = -1; _f <= 1; _f++) draw_rectangle(_x + _f * _r * 0.7 - _r * 0.2, _y - _r * 0.6, _x + _f * _r * 0.7 + _r * 0.2, _y + _r * 0.6, true);
            break;
        case 5: case 9: // polvora ou sangue e polvora
            for (var _b = 0; _b < 4; _b++) draw_circle(_x + lengthdir_x(_r * 0.7, _b * 90), _y + lengthdir_y(_r * 0.7, _b * 90), _r * 0.23, false);
            if (_i == 9) draw_triangle(_x, _y - _r * 0.5, _x - _r * 0.3, _y + _r * 0.4, _x + _r * 0.3, _y + _r * 0.4, false);
            break;
        case 6: case 8: case 12: // relogio, janela de ataque ou contra-passo
            draw_circle(_x, _y, _r * 0.85, true);
            draw_line_width(_x, _y, _x, _y - _r * 0.6, _esp);
            draw_line_width(_x, _y, _x + _r * 0.5, _y + _r * 0.2, _esp);
            if (_i == 8) draw_line_width(_x - _r, _y + _r, _x + _r, _y - _r, _esp);
            if (_i == 12) draw_triangle(_x - _r, _y, _x - _r * 0.3, _y - _r * 0.3, _x - _r * 0.3, _y + _r * 0.3, false);
            break;
        case 7: // escudo
            draw_line_width(_x - _r * 0.7, _y - _r * 0.7, _x + _r * 0.7, _y - _r * 0.7, _esp);
            draw_line_width(_x - _r * 0.7, _y - _r * 0.7, _x, _y + _r, _esp);
            draw_line_width(_x + _r * 0.7, _y - _r * 0.7, _x, _y + _r, _esp);
            break;
        case 11: // sentenca
            draw_line_width(_x - _r * 0.7, _y - _r, _x + _r * 0.7, _y + _r, _esp);
            draw_line_width(_x + _r * 0.7, _y - _r, _x - _r * 0.7, _y + _r, _esp);
            draw_circle(_x, _y, _r * 0.3, true);
            break;
    }
    draw_set_color(c_white);
}

// ---------- painel premium: cartas, carta da arma e nos da arvore (pedido dos lideres, 13/11) ----------
// Tudo so desenho, sem random: o brilho anda com o relogio (current_time), como o pisca do HUD.
// _cor: cor do Caido ou da arma; _foco: pulsa um halo; _vida: 0 a 1, entrada (sobe e aparece)
#macro PREMIUM_OURO make_colour_rgb(214, 178, 96)
#macro PREMIUM_OURO_ESCURO make_colour_rgb(120, 92, 44)
function painel_premium(_x1, _y1, _x2, _y2, _cor, _foco, _vida = 1, _esc = 1) {
    var _a_antes = draw_get_alpha();
    var _a = _a_antes * _vida;
    var _w = _x2 - _x1;
    var _h = _y2 - _y1;
    var _rel = current_time / 1000;
    // halo em volta, pulsando devagar quando em foco
    if (_foco) {
        var _p = 0.5 + 0.5 * sin(_rel * 4);
        gpu_set_blendmode(bm_add);
        for (var _k = 1; _k <= 4; _k++) {
            draw_set_alpha(_a * (0.10 + 0.08 * _p) * (1 - _k / 5));
            draw_set_color(merge_colour(_cor, c_white, 0.3));
            draw_rectangle(_x1 - _k * 3 * _esc, _y1 - _k * 3 * _esc, _x2 + _k * 3 * _esc, _y2 + _k * 3 * _esc, false);
        }
        gpu_set_blendmode(bm_normal);
    }
    // fundo: degrade de cima (mais claro, com um pouco da cor) para baixo (quase preto)
    draw_set_alpha(_a);
    var _topo = merge_colour(make_colour_rgb(30, 26, 36), _cor, 0.18);
    var _base = make_colour_rgb(12, 9, 14);
    draw_rectangle_colour(_x1, _y1, _x2, _y2, _topo, _topo, _base, _base, false);
    // faixa da cor em cima, com brilho
    draw_set_color(_cor);
    draw_rectangle(_x1, _y1, _x2, _y1 + 4 * _esc, false);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(_a * 0.35);
    draw_rectangle_colour(_x1, _y1 + 4 * _esc, _x2, _y1 + 28 * _esc, _cor, _cor, c_black, c_black, false);
    // brilho varrendo: uma faixa vertical clara que atravessa o painel a cada 3 s, mais forte no foco
    var _fase = ((_rel * 0.33 + _x1 * 0.0007) mod 1);
    var _bx = _x1 - _w * 0.25 + _fase * _w * 1.5;
    var _bw = _w * 0.18;
    var _bint = (_foco ? 0.22 : 0.10) * _a;
    var _l = clamp(_bx - _bw, _x1, _x2);
    var _m = clamp(_bx, _x1, _x2);
    var _r = clamp(_bx + _bw, _x1, _x2);
    if (_m > _l) draw_rectangle_colour(_l, _y1, _m, _y2, c_black, c_white, c_white, c_black, false);
    draw_set_alpha(_bint);
    if (_m > _l) draw_rectangle_colour(_l, _y1, _m, _y2, c_black, c_white, c_white, c_black, false);
    if (_r > _m) draw_rectangle_colour(_m, _y1, _r, _y2, c_white, c_black, c_black, c_white, false);
    gpu_set_blendmode(bm_normal);
    // borda dupla: ouro escuro fora, ouro claro dentro (branco no foco)
    draw_set_alpha(_a);
    draw_set_color(PREMIUM_OURO_ESCURO);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    draw_set_color(_foco ? c_white : PREMIUM_OURO);
    draw_rectangle(_x1 + 3 * _esc, _y1 + 3 * _esc, _x2 - 3 * _esc, _y2 - 3 * _esc, true);
    // ornamento: um losango em cada canto
    var _d = 5 * _esc;
    var _cantos = [[_x1, _y1], [_x2, _y1], [_x1, _y2], [_x2, _y2]];
    for (var _c = 0; _c < 4; _c++) {
        var _cx = _cantos[_c][0];
        var _cy = _cantos[_c][1];
        draw_set_color(make_colour_rgb(12, 9, 14));
        draw_triangle(_cx - _d - 1, _cy, _cx, _cy - _d - 1, _cx + _d + 1, _cy, false);
        draw_triangle(_cx - _d - 1, _cy, _cx, _cy + _d + 1, _cx + _d + 1, _cy, false);
        draw_set_color(_foco ? c_white : PREMIUM_OURO);
        draw_triangle(_cx - _d, _cy, _cx, _cy - _d, _cx + _d, _cy, false);
        draw_triangle(_cx - _d, _cy, _cx, _cy + _d, _cx + _d, _cy, false);
    }
    draw_set_alpha(_a_antes);
    draw_set_color(c_white);
}

// entrada de uma carta: 0 no primeiro quadro, 1 depois de 14 quadros, com atraso por carta
function premium_entrada(_tempo, _i) {
    return clamp((_tempo - 4 * _i) / 14, 0, 1);
}

// ligacao da arvore: linha e um ponto de luz que corre por ela (mais forte em foco)
function ligacao_viva(_x1, _y1, _x2, _y2, _cor, _foco, _esc) {
    draw_set_color(_foco ? PREMIUM_OURO : make_colour_rgb(53, 66, 76));
    draw_set_alpha(_foco ? 0.85 : 0.35);
    draw_line_width(_x1, _y1, _x2, _y2, _foco ? 2 * _esc : _esc);
    var _f = (current_time / 1400 + (_x1 + _y2) * 0.001) mod 1;
    var _px = lerp(_x1, _x2, _f);
    var _py = lerp(_y1, _y2, _f);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(_foco ? 0.9 : 0.35);
    draw_set_color(_foco ? c_white : _cor);
    draw_circle(_px, _py, (_foco ? 3 : 2) * _esc, false);
    draw_set_alpha((_foco ? 0.35 : 0.12));
    draw_circle(_px, _py, (_foco ? 7 : 4) * _esc, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

function arvore_abrir() {
    if (!instance_exists(obj_arvore)) instance_create_depth(0, 0, -11000, obj_arvore);
}

function arvore_posicao(_i) {
    // Cada linhagem tem uma coluna. Combinacoes ocupam a ultima linha.
    var _col = [0, 0, 1, 1, 2, 2, 3, 3, 3, 0, 1, 2, 3][_i];
    var _fila = [0, 1, 0, 1, 0, 1, 0, 1, 2, 4, 4, 4, 4][_i];
    return [32 + _col * 154, 142 + _fila * 58];
}
