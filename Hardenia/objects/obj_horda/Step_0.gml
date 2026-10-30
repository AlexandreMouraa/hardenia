if (global.game_paused || global.hitstop > 0) {
    exit;
}

var _clique = mouse_check_button_pressed(mb_left);

if (medindo) {
    if (medida_fim) {
        if (_clique || keyboard_check_pressed(vk_enter)) {
            room_goto(Room_Menu);
        }
        exit;
    }
    // jogador invencivel: aqui a pergunta e so quantos o aparelho aguenta
    obj_player.invuln_timer = 2;
    tempo += 1;
    // 20 por segundo. O fps do jogo so atualiza uma vez por segundo
    if (tempo mod 3 == 0) {
        criar_um();
    }
    if (tempo mod 60 == 0) {
        var _vivos = instance_number(obj_enemy_horda);
        if (fps >= game_get_speed(gamespeed_fps) * 0.95) {
            medida_limite = _vivos;
            medida_ruim = 0;
        } else {
            medida_ruim += 1;
        }
        if (medida_ruim >= 5 || _vivos >= medida_teto) {
            medida_fim = true;
            instance_destroy(obj_enemy_horda);
        }
    }
    exit;
}

if (keyboard_check_pressed(ord("L"))) {
    medir();
    exit;
}
if (_clique) {
    var _b = botao_medir();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    if (point_in_rectangle(_mx, _my, _b[0], _b[1], _b[2], _b[3])) {
        medir();
        exit;
    }
}

if (fim) {
    if (keyboard_check_pressed(vk_enter)) {
        room_goto(Room_Menu);
    }
    exit;
}

if (faltam > 0) {
    // 20 por segundo, para virem em fila pela borda e nao de uma vez
    tempo += 1;
    if (tempo mod 3 == 0 && criar_um()) {
        faltam -= 1;
    }
} else if (instance_number(obj_enemy_horda) == 0) {
    espera -= 1;
    if (espera <= 0) {
        onda += 1;
        espera = 120;
        if (onda >= array_length(ondas)) {
            fim = true;
        } else {
            faltam = ondas[onda];
        }
    }
}
