global.hitstop = 1;
tempo += 1;

if (escolhido >= 0) {
    saindo -= 1;
    if (saindo <= 0) {
        instance_destroy();
    }
    exit;
}

// o robo escolhe por fora (obj_autotest). A pausa curta evita escolher sem querer, com o mesmo
// aperto que trouxe ate aqui
if (tempo < 20 || instance_exists(obj_autotest)) {
    exit;
}

var _n = array_length(oferta);
if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
    cursor = (cursor + _n - 1) mod _n;
    sfx(snd_dash_negado, 1, false, 0.3);
}
if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
    cursor = (cursor + 1) mod _n;
    sfx(snd_dash_negado, 1, false, 0.3);
}
for (var _i = 0; _i < _n; _i++) {
    if (keyboard_check_pressed(ord("1") + _i)) {
        cursor = _i;
        escolher(_i);
        exit;
    }
}
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("J"))) {
    escolher(cursor);
    exit;
}

// mouse: so muda a selecao se ele andou, senao atrapalha quem esta no teclado
var _mx = ponteiro_gui_x(0);
var _my = ponteiro_gui_y(0);
var _andou = (_mx != mouse_antes_x || _my != mouse_antes_y);
mouse_antes_x = _mx;
mouse_antes_y = _my;
for (var _i = 0; _i < _n; _i++) {
    var _r = carta(_i);
    if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) {
        if (_andou) {
            cursor = _i;
        }
        if (mouse_check_button_pressed(mb_left)) {
            escolher(_i);
            exit;
        }
    }
    if (global.toque_ativo && toque_tap_em(_r)) {
        escolher(_i);
        exit;
    }
}
