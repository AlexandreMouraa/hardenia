// com o mapa da fase 1 aberto (obj_mapa), os textos do menu saem da frente
if (instance_exists(obj_mapa)) {
    exit;
}

var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);

// pisca sem nunca sumir: no minimo 35% visivel
var _alpha = 0.35 + 0.65 * (0.5 + 0.5 * sin(current_time / 200));
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_set_alpha(_alpha);
draw_text_transformed(_w / 2, _h - 66 * _esc, "ENTER OU CLIQUE PARA INICIAR", _esc, _esc, 0);
draw_set_alpha(1);

draw_set_color(c_ltgray);
draw_text_transformed(_w / 2, _h - 38 * _esc, "WASD / SETAS: mover    MOUSE: mirar    CLIQUE ou J: atacar (3x: combo)    ESPACO: dash    ESC: pausar", _esc * 0.8, _esc * 0.8, 0);
draw_text_transformed(_w / 2, _h - 20 * _esc, "SEGURAR O ATAQUE: golpe carregado    ATACAR NO DASH: estocada    CLIQUE DIREITO ou K: especial", _esc * 0.8, _esc * 0.8, 0);

draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_text_transformed(_w - 16 * _esc, 12 * _esc, os_browser == browser_not_a_browser ? "ESC: sair do jogo" : "F11: tela cheia", _esc * 0.8, _esc * 0.8, 0);

draw_set_halign(fa_left);
draw_text_transformed(16 * _esc, 12 * _esc, "v" + VERSAO_JOGO, _esc * 0.7, _esc * 0.7, 0);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
