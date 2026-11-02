toque_detectar();

// mapa da fase 1 ou abertura na tela: quem cuida do clique sao eles
if (instance_exists(obj_mapa) || instance_exists(obj_abertura)) {
    exit;
}

if (keyboard_check_pressed(ord("H"))) {
    horda_iniciar();
    exit;
}

// clique tambem comeca, como o Enter; no texto da horda, abre o teste
if (mouse_check_button_pressed(mb_left)) {
    var _b = botao_horda();
    if (point_in_rectangle(ponteiro_gui_x(0), ponteiro_gui_y(0), _b[0], _b[1], _b[2], _b[3])) {
        horda_iniciar();
    } else {
        event_perform(ev_keypress, vk_enter);
    }
}
