// Controle (gamepad). As mesmas acoes do teclado entram no obj_player, Step, junto com as teclas.
// RB ou RT: ataque. A, LB ou LT: dash. B: giro. Start: pausa. Lido uma vez por frame, em
// toque_detectar. Sem controle, tudo aqui devolve "nao apertou".
global.pad = -1;
global.pad_procura = 0;
global.pad_h = 0;
global.pad_v = 0;
global.pad_h_antes = 0;
global.pad_v_antes = 0;
global.pad_novo_h = 0;
global.pad_novo_v = 0;
// o que o jogador usou por ultimo: muda o texto das dicas ("teclado", "toque" ou "controle")
global.ultimo_aparelho = "teclado";

function pad_ler() {
    // procura de vez em quando: no navegador o controle so aparece depois de apertar um botao
    global.pad_procura -= 1;
    if (global.pad_procura <= 0) {
        global.pad_procura = 60;
        if (global.pad == -1 || !gamepad_is_connected(global.pad)) {
            global.pad = -1;
            for (var _i = 0; _i < gamepad_get_device_count(); _i++) {
                if (gamepad_is_connected(_i)) {
                    global.pad = _i;
                    gamepad_set_axis_deadzone(_i, 0.25);
                    break;
                }
            }
        }
    }
    global.pad_h_antes = global.pad_h;
    global.pad_v_antes = global.pad_v;
    global.pad_h = 0;
    global.pad_v = 0;
    if (global.pad != -1) {
        var _ax = gamepad_axis_value(global.pad, gp_axislh);
        var _ay = gamepad_axis_value(global.pad, gp_axislv);
        // 8 direcoes, como no teclado
        if (point_distance(0, 0, _ax, _ay) > 0.4) {
            var _lado = round(point_direction(0, 0, _ax, _ay) / 45) mod 8;
            global.pad_h = [1, 1, 0, -1, -1, -1, 0, 1][_lado];
            global.pad_v = [0, -1, -1, -1, 0, 1, 1, 1][_lado];
        }
        global.pad_h = clamp(global.pad_h + gamepad_button_check(global.pad, gp_padr) - gamepad_button_check(global.pad, gp_padl), -1, 1);
        global.pad_v = clamp(global.pad_v + gamepad_button_check(global.pad, gp_padd) - gamepad_button_check(global.pad, gp_padu), -1, 1);
    }
    global.pad_novo_h = (global.pad_h != global.pad_h_antes) ? global.pad_h : 0;
    global.pad_novo_v = (global.pad_v != global.pad_v_antes) ? global.pad_v : 0;
    if (global.pad_h != 0 || global.pad_v != 0 || pad_algum_novo()) {
        global.ultimo_aparelho = "controle";
        global.toque_ativo = false;
    } else if (keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_any)) {
        global.ultimo_aparelho = global.toque_ativo ? "toque" : "teclado";
    }
}

function pad_novo(_botao) {
    return global.pad != -1 && gamepad_button_check_pressed(global.pad, _botao);
}

function pad_preso(_botao) {
    return global.pad != -1 && gamepad_button_check(global.pad, _botao);
}

function pad_algum_novo() {
    return pad_novo(gp_face1) || pad_novo(gp_face2) || pad_novo(gp_face3) || pad_novo(gp_face4) || pad_novo(gp_start) || pad_novo(gp_select) || pad_novo(gp_shoulderl) || pad_novo(gp_shoulderr) || pad_novo(gp_shoulderlb) || pad_novo(gp_shoulderrb);
}

// acoes do jogo
function pad_ataque_novo() {
    return pad_novo(gp_shoulderr) || pad_novo(gp_shoulderrb) || pad_novo(gp_face3);
}

function pad_ataque_preso() {
    return pad_preso(gp_shoulderr) || pad_preso(gp_shoulderrb) || pad_preso(gp_face3);
}

function pad_dash_novo() {
    return pad_novo(gp_face1) || pad_novo(gp_shoulderl) || pad_novo(gp_shoulderlb);
}

// nas telas: passar o texto, confirmar, voltar
function pad_confirma() {
    return pad_novo(gp_face1) || pad_novo(gp_start);
}

function pad_volta() {
    return pad_novo(gp_face2);
}

// tecla, clique ou botao: passa a tela de texto
function aperto_de_passar() {
    return keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("J")) || mouse_check_button_pressed(mb_left) || pad_confirma();
}
