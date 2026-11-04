tempo += 1;
// a pausa curta evita que o mesmo aperto que abriu a tela ja faca alguma coisa aqui
if (tempo < 8) {
    exit;
}
var _volta = keyboard_check_pressed(vk_escape) || pad_volta();
if (modo != "opcoes") {
    if (_volta || aperto_de_passar()) {
        fechar();
    }
    exit;
}
if (_volta) {
    fechar();
    exit;
}
var _n = array_length(itens);
var _dv = (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")) || global.pad_novo_v > 0) - (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")) || global.pad_novo_v < 0);
if (_dv != 0) {
    cursor = (cursor + _dv + _n) mod _n;
    sfx(snd_menu_mover, 1, false, 0.6);
}
var _dh = (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || global.pad_novo_h > 0) - (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")) || global.pad_novo_h < 0);
var _confirma = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("J")) || pad_novo(gp_face1);
// mouse e toque: o item embaixo do ponteiro; na barra, a metade da esquerda abaixa
var _mx = ponteiro_gui_x(0);
var _my = ponteiro_gui_y(0);
if (mouse_check_button_pressed(mb_left)) {
    for (var _i = 0; _i < _n; _i++) {
        var _r = item_ret(_i);
        if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) {
            cursor = _i;
            if (itens[_i].tipo == "barra") {
                _dh = (_mx > (_r[0] + _r[2]) / 2 + (_r[2] - _r[0]) * 0.25) ? 1 : -1;
            } else {
                _confirma = true;
            }
        }
    }
}
var _item = itens[cursor];
if (_item.tipo == "sair") {
    if (_confirma) {
        fechar();
    }
    exit;
}
if (_dh != 0 || (_confirma && _item.tipo == "texto")) {
    _item.mudar(_dh != 0 ? _dh : 1);
    mudou = true;
}
