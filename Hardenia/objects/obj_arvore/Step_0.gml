tempo += 1;
if (tempo < 2) exit;
var _u = tecnicas_ui();
if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_tab)
    || pad_volta() || pad_novo(gp_face4) || pad_novo(gp_start)
    || tecnica_clicou(tecnica_ret(_u, 792, 486, 136, 32))) {
    instance_destroy();
    exit;
}
var _n = array_length(global.tecnicas_lista);
var _h = (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || global.pad_novo_h > 0)
    - (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")) || global.pad_novo_h < 0);
var _v = (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")) || global.pad_novo_v > 0)
    - (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")) || global.pad_novo_v < 0);
// Vizinho espacial na direcao pedida, sem saltar entre indices de linhagens diferentes.
if (_h != 0 || _v != 0) {
    var _p = arvore_posicao(cursor);
    var _melhor = cursor;
    var _custo = 100000;
    for (var _i = 0; _i < _n; _i++) {
        var _q = arvore_posicao(_i);
        var _dx = _q[0] - _p[0];
        var _dy = _q[1] - _p[1];
        if ((_h != 0 && _dx * _h <= 0) || (_v != 0 && _dy * _v <= 0)) continue;
        var _c = point_distance(_p[0], _p[1], _q[0], _q[1]) + abs(_h != 0 ? _dy : _dx) * 3;
        if (_c < _custo) { _custo = _c; _melhor = _i; }
    }
    cursor = _melhor;
}
var _mx = ponteiro_gui_x(0);
var _my = ponteiro_gui_y(0);
var _andou = _mx != mouse_antes_x || _my != mouse_antes_y;
mouse_antes_x = _mx;
mouse_antes_y = _my;
for (var _i = 0; _i < _n; _i++) {
    var _p = arvore_posicao(_i);
    var _r = tecnica_ret(_u, _p[0], _p[1], 140, 48);
    if ((_andou && point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) || tecnica_clicou(_r)) cursor = _i;
}
