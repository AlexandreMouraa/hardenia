toque_detectar();

// mapa da fase 1, abertura ou outra tela aberta: quem cuida da entrada sao eles
if (instance_exists(obj_mapa) || instance_exists(obj_abertura) || instance_exists(obj_opcoes)) {
    exit;
}

if (keyboard_check_pressed(ord("H"))) {
    horda_iniciar();
    exit;
}

var _n = array_length(itens);
var _dv = (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")) || global.pad_novo_v > 0) - (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")) || global.pad_novo_v < 0);
if (_dv != 0) {
    cursor = (cursor + _dv + _n) mod _n;
    sfx(snd_menu_mover, 1, false, 0.6);
}

// mouse: so muda a selecao se ele andou, senao atrapalha quem esta no teclado
var _mx = ponteiro_gui_x(0);
var _my = ponteiro_gui_y(0);
var _andou = (_mx != mouse_antes_x || _my != mouse_antes_y);
mouse_antes_x = _mx;
mouse_antes_y = _my;
var _sobre = -1;
for (var _i = 0; _i < _n; _i++) {
    var _r = item_ret(_i);
    if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) {
        _sobre = _i;
        if (_andou && cursor != _i) {
            cursor = _i;
            sfx(snd_menu_mover, 1, false, 0.4);
        }
    }
}

if (mouse_check_button_pressed(mb_left)) {
    var _b = botao_horda();
    if (point_in_rectangle(_mx, _my, _b[0], _b[1], _b[2], _b[3])) {
        horda_iniciar();
    } else if (_sobre >= 0) {
        cursor = _sobre;
        acionar(itens[cursor].acao);
    }
    exit;
}

// Enter e o evento de tecla (KeyPress_13), que tambem e o que o robo aperta
if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("J")) || pad_confirma()) {
    acionar(itens[cursor].acao);
}
