// Controles de toque (#34): direcional na tela e botoes, para tablet e celular. Ficam
// escondidos ate o primeiro toque, e quem joga com mouse e teclado nao ve nada mudar.
// Tudo entra no obj_player, Step, pelas mesmas variaveis do teclado e do robo.
// No robo (-toque), os dedos sao de mentira (bot_dedos): ele joga pelo mesmo caminho.
#macro TOQUE_DEDOS 5

global.toque_ativo = false;
global.toque_px = 0;
global.toque_py = 0;
global.toque_janela = 0;
global.toque_mouse_em = -100000;
global.toque = {
    h: 0,
    v: 0,
    ataque_novo: false,
    ataque_preso: false,
    dash_novo: false,
    especial_novo: false,
    pausa_novo: false,
    qualquer_novo: false,
    dedo_direcional: -1,
    dedo_ataque: -1,
    base_x: 0,
    base_y: 0,
    ponta_x: 0,
    ponta_y: 0,
};

// ---------- posicao do ponteiro, na tela do jogo ----------
// O site estica o jogo com CSS para caber na janela (deploy/jogar-index.py), e o GameMaker
// nao fica sabendo: a posicao vem em pixels da pagina, a partir do canto do jogo. Em janela
// menor que 1920 de largura, o toque e o clique cairiam longe de onde a pessoa encostou.
// A conta e a mesma do CSS: min(100vw, 177.78vh)
function ponteiro_fator() {
    if (os_browser == browser_not_a_browser) {
        return 1;
    }
    var _pagina = min(browser_width, browser_height * 16 / 9);
    return (_pagina > 0) ? display_get_gui_width() / _pagina : 1;
}

function ponteiro_gui_x(_d) {
    return device_mouse_x_to_gui(_d) * ponteiro_fator();
}

function ponteiro_gui_y(_d) {
    return device_mouse_y_to_gui(_d) * ponteiro_fator();
}

// ---------- os dedos: de verdade ou do robo ----------
function toque_dedo_preso(_d) {
    if (instance_exists(obj_autotest)) {
        return obj_autotest.bot_dedos[_d] != undefined;
    }
    return device_mouse_check_button(_d, mb_left);
}

function toque_dedo_novo(_d) {
    if (instance_exists(obj_autotest)) {
        return obj_autotest.bot_dedos[_d] != undefined && obj_autotest.bot_dedos_antes[_d] == undefined;
    }
    return device_mouse_check_button_pressed(_d, mb_left);
}

function toque_dedo_x(_d) {
    if (instance_exists(obj_autotest)) {
        return obj_autotest.bot_dedos[_d][0];
    }
    return ponteiro_gui_x(_d);
}

function toque_dedo_y(_d) {
    if (instance_exists(obj_autotest)) {
        return obj_autotest.bot_dedos[_d][1];
    }
    return ponteiro_gui_y(_d);
}

// O jogo nao tem como perguntar se a tela e de toque, entao descobre pelo jeito de apertar:
// o mouse anda ate o lugar e aperta, o dedo aparece la de repente. Mexer o mouse sem apertar
// ou usar o teclado esconde os controles de novo (iPad com teclado, notebook com tela de toque)
function toque_detectar() {
    if (instance_exists(obj_autotest)) {
        global.toque_ativo = obj_autotest.usar_toque;
        return;
    }
    var _x = ponteiro_gui_x(0);
    var _y = ponteiro_gui_y(0);
    // janela mudou (girou o aparelho, a barra do navegador sumiu): o ponteiro "andou" sem
    // ninguem mexer, e isso nao pode esconder os controles
    var _janela = browser_width * 100000 + browser_height;
    if (_janela != global.toque_janela) {
        global.toque_janela = _janela;
        global.toque_px = _x;
        global.toque_py = _y;
    }
    var _longe = point_distance(_x, _y, global.toque_px, global.toque_py);
    if (device_mouse_check_button_pressed(0, mb_left)) {
        // o ponteiro andou sem apertar ha pouco: e mouse, mesmo que a mao esteja em movimento
        // na hora do clique. Dedo nao anda sem apertar
        if (_longe > 24 && current_time - global.toque_mouse_em > 1000) {
            global.toque_ativo = true;
        }
    } else if (_longe > 2 && !device_mouse_check_button(0, mb_left)) {
        global.toque_ativo = false;
        global.toque_mouse_em = current_time;
    }
    // segundo dedo: mouse nao faz isso
    if (device_mouse_check_button(1, mb_left)) {
        global.toque_ativo = true;
    }
    if (keyboard_check_pressed(vk_anykey)) {
        global.toque_ativo = false;
    }
    global.toque_px = _x;
    global.toque_py = _y;
}

// ---------- onde fica cada coisa, na tela ----------
function toque_escala() {
    return max(1, display_get_gui_height() / 540);
}

// ao alcance do polegar direito, sem cobrir o HUD. O ataque e o maior: e o mais usado
function toque_botoes() {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _e = toque_escala();
    return {
        ataque: { x: _w - 96 * _e, y: _h - 92 * _e, r: 52 * _e, texto: "ATACAR" },
        dash: { x: _w - 206 * _e, y: _h - 62 * _e, r: 38 * _e, texto: "DASH" },
        especial: { x: _w - 72 * _e, y: _h - 204 * _e, r: 38 * _e, texto: "GIRO" },
        pausa: { x: _w - 40 * _e, y: 66 * _e, r: 26 * _e, texto: "II" },
    };
}

// retangulos das telas sem HUD: [esquerda, cima, direita, baixo, texto]
function toque_botoes_pausa() {
    var _cx = display_get_gui_width() / 2;
    var _cy = display_get_gui_height() / 2;
    var _e = toque_escala();
    return {
        continuar: [_cx - 190 * _e, _cy - 130 * _e, _cx - 10 * _e, _cy - 84 * _e, "CONTINUAR"],
        menu: [_cx + 10 * _e, _cy - 130 * _e, _cx + 190 * _e, _cy - 84 * _e, "VOLTAR AO MENU"],
    };
}

function toque_botoes_nome() {
    var _cx = display_get_gui_width() / 2;
    var _y = display_get_gui_height() / 2 - 130 * toque_escala();
    var _e = toque_escala();
    return {
        escrever: [_cx - 190 * _e, _y + 156 * _e, _cx - 10 * _e, _y + 202 * _e, "ESCREVER NOME"],
        pular: [_cx + 10 * _e, _y + 156 * _e, _cx + 190 * _e, _y + 202 * _e, "PULAR"],
    };
}

// um pouco maior que o desenho: o dedo nao tem a precisao do mouse
function toque_no_botao(_x, _y, _b) {
    return point_distance(_x, _y, _b.x, _b.y) <= _b.r * 1.25;
}

// algum dedo novo dentro do retangulo?
function toque_tap_em(_r) {
    for (var _d = 0; _d < TOQUE_DEDOS; _d++) {
        if (toque_dedo_novo(_d) && point_in_rectangle(toque_dedo_x(_d), toque_dedo_y(_d), _r[0], _r[1], _r[2], _r[3])) {
            return true;
        }
    }
    return false;
}

// ---------- leitura, uma vez por frame ----------
function toque_ler() {
    var _t = global.toque;
    var _b = toque_botoes();
    var _e = toque_escala();
    _t.ataque_novo = false;
    _t.dash_novo = false;
    _t.especial_novo = false;
    _t.pausa_novo = false;
    _t.qualquer_novo = false;

    for (var _d = 0; _d < TOQUE_DEDOS; _d++) {
        if (!toque_dedo_novo(_d)) {
            continue;
        }
        var _x = toque_dedo_x(_d);
        var _y = toque_dedo_y(_d);
        _t.qualquer_novo = true;
        if (toque_no_botao(_x, _y, _b.ataque)) {
            _t.ataque_novo = true;
            _t.dedo_ataque = _d;
        } else if (toque_no_botao(_x, _y, _b.dash)) {
            _t.dash_novo = true;
        } else if (toque_no_botao(_x, _y, _b.especial)) {
            _t.especial_novo = true;
        } else if (toque_no_botao(_x, _y, _b.pausa)) {
            _t.pausa_novo = true;
        } else if (_t.dedo_direcional < 0 && _x < display_get_gui_width() * 0.5) {
            // o direcional nasce onde o polegar encostar, na metade esquerda da tela
            _t.dedo_direcional = _d;
            _t.base_x = _x;
            _t.base_y = _y;
        }
    }

    if (_t.dedo_ataque >= 0 && !toque_dedo_preso(_t.dedo_ataque)) {
        _t.dedo_ataque = -1;
    }
    _t.ataque_preso = (_t.dedo_ataque >= 0);

    _t.h = 0;
    _t.v = 0;
    if (_t.dedo_direcional >= 0 && !toque_dedo_preso(_t.dedo_direcional)) {
        _t.dedo_direcional = -1;
    }
    if (_t.dedo_direcional >= 0) {
        _t.ponta_x = toque_dedo_x(_t.dedo_direcional);
        _t.ponta_y = toque_dedo_y(_t.dedo_direcional);
        var _dist = point_distance(_t.base_x, _t.base_y, _t.ponta_x, _t.ponta_y);
        var _ang = point_direction(_t.base_x, _t.base_y, _t.ponta_x, _t.ponta_y);
        // o direcional segue o polegar que passa do limite: nao precisa voltar para virar
        var _raio = 60 * _e;
        if (_dist > _raio) {
            _t.base_x = _t.ponta_x - lengthdir_x(_raio, _ang);
            _t.base_y = _t.ponta_y - lengthdir_y(_raio, _ang);
        }
        // 8 direcoes iguais, como no teclado. A folga evita andar com o polegar so encostado
        if (_dist > 12 * _e) {
            var _lado = round(_ang / 45) mod 8;
            _t.h = [1, 1, 0, -1, -1, -1, 0, 1][_lado];
            _t.v = [0, -1, -1, -1, 0, 1, 1, 1][_lado];
        }
    }
}

// ---------- desenho ----------
function toque_circulo(_b, _aceso, _pronto) {
    draw_set_alpha(_aceso ? 0.5 : 0.22);
    draw_set_color(_aceso ? make_colour_rgb(200, 40, 50) : c_black);
    draw_circle(_b.x, _b.y, _b.r, false);
    draw_set_alpha(_pronto ? 0.85 : 0.3);
    draw_set_color(c_white);
    draw_circle(_b.x, _b.y, _b.r, true);
    draw_circle(_b.x, _b.y, _b.r - 1, true);
    draw_text_transformed(_b.x, _b.y, _b.texto, toque_escala() * 0.8, toque_escala() * 0.8, 0);
    draw_set_alpha(1);
}

// _dash, _especial: se o botao esta pronto. Apagado mostra que ainda nao recarregou
function toque_desenhar(_dash, _especial) {
    var _t = global.toque;
    var _b = toque_botoes();
    var _e = toque_escala();
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    toque_circulo(_b.ataque, _t.ataque_preso, true);
    toque_circulo(_b.dash, false, _dash);
    toque_circulo(_b.especial, false, _especial);
    toque_circulo(_b.pausa, false, true);

    var _preso = (_t.dedo_direcional >= 0);
    var _bx = _preso ? _t.base_x : 120 * _e;
    var _by = _preso ? _t.base_y : display_get_gui_height() - 110 * _e;
    var _px = _preso ? _t.ponta_x : _bx;
    var _py = _preso ? _t.ponta_y : _by;
    if (point_distance(_bx, _by, _px, _py) > 60 * _e) {
        var _ang = point_direction(_bx, _by, _px, _py);
        _px = _bx + lengthdir_x(60 * _e, _ang);
        _py = _by + lengthdir_y(60 * _e, _ang);
    }
    draw_set_alpha(_preso ? 0.3 : 0.15);
    draw_set_color(c_black);
    draw_circle(_bx, _by, 60 * _e, false);
    draw_set_alpha(_preso ? 0.8 : 0.45);
    draw_set_color(c_white);
    draw_circle(_bx, _by, 60 * _e, true);
    draw_circle(_bx, _by, 60 * _e - 1, true);
    draw_set_alpha(_preso ? 0.75 : 0.35);
    draw_circle(_px, _py, 24 * _e, false);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function toque_botao_ret(_r) {
    var _e = toque_escala();
    draw_set_alpha(0.75);
    draw_set_color(make_colour_rgb(90, 14, 20));
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], true);
    draw_text_transformed((_r[0] + _r[2]) / 2, (_r[1] + _r[3]) / 2, _r[4], _e * 0.9, _e * 0.9, 0);
}
