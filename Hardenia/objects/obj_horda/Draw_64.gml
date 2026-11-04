var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);

draw_set_valign(fa_top);
draw_set_halign(fa_right);
draw_set_color(c_ltgray);
texto(_w - 16 * _esc, 34 * _esc, "FPS " + string(fps), _esc * 0.8, _esc * 0.8, 0);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
if (medindo) {
    if (medida_fim) {
        draw_set_color(c_yellow);
        texto(_w / 2, _h * 0.4, "LIMITE: " + string(medida_limite) + " INIMIGOS A " + string(game_get_speed(gamespeed_fps)) + " FPS", _esc * 1.6, _esc * 1.6, 0);
        draw_set_color(c_white);
        texto(_w / 2, _h * 0.4 + 36 * _esc, "ENTER OU TOQUE: VOLTAR AO MENU", _esc, _esc, 0);
    } else {
        texto(_w / 2, _h * 0.15, "MEDINDO: " + string(instance_number(obj_enemy_horda)) + " INIMIGOS", _esc * 1.2, _esc * 1.2, 0);
        draw_set_color(c_ltgray);
        texto(_w / 2, _h * 0.15 + 24 * _esc, "Melhor até agora: " + string(medida_limite), _esc * 0.8, _esc * 0.8, 0);
    }
} else {
    if (fim) {
        draw_set_color(c_yellow);
        titulo(_w / 2, _h * 0.4, "Horda vencida", _esc * 2);
        draw_set_color(c_white);
        texto(_w / 2, _h * 0.4 + 36 * _esc, "ENTER OU TOQUE: VOLTAR AO MENU", _esc, _esc, 0);
    } else if (onda >= 0) {
        texto(_w / 2, _h * 0.12, "ONDA " + string(onda + 1) + " / " + string(array_length(ondas)), _esc * 1.2, _esc * 1.2, 0);
    } else {
        texto(_w / 2, _h * 0.3, "ELES VEM DE FORA DA TELA, E ENCOSTAR MACHUCA", _esc, _esc, 0);
    }
    var _b = botao_medir();
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(_b[0], _b[1], _b[2], _b[3], false);
    draw_set_alpha(1);
    draw_set_color(c_ltgray);
    texto(_w / 2, (_b[1] + _b[3]) / 2, "TOQUE AQUI OU L: MEDIR O LIMITE DO APARELHO", _esc * 0.8, _esc * 0.8, 0);
}

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
