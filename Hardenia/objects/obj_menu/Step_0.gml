// mapa da fase 1 aberto: quem cuida do clique e o obj_mapa
if (instance_exists(obj_mapa)) {
    exit;
}

if (keyboard_check_pressed(ord("H"))) {
    horda_iniciar();
    exit;
}

// clique tambem comeca, como o Enter; no texto da horda, abre o teste
if (mouse_check_button_pressed(mb_left)) {
    var _b = botao_horda();
    if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _b[0], _b[1], _b[2], _b[3])) {
        horda_iniciar();
    } else {
        event_perform(ev_keypress, vk_enter);
    }
}
