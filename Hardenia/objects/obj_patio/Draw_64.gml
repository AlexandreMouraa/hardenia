if (global.game_paused || instance_exists(obj_tecnicas) || instance_exists(obj_arvore)
    || instance_exists(obj_mapa) || !instance_exists(obj_player) || obj_player.is_dead) exit;
var _e = display_get_gui_height() / 540;
var _w = display_get_gui_width();
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_colour_rgb(221, 196, 143));
texto(_w / 2, 35 * _e, "PÁTIO DO CASTELO", _e * 0.85, _e * 0.85, 0);
if (obj_player.tempo_na_sala < 600) {
    draw_set_color(c_ltgray);
    texto(_w / 2, 52 * _e, obj_player.tempo_na_sala < 300 ? "Use as colunas contra flechas. Pólvora e espinhos atingem os dois lados." : "O curandeiro recupera aliados. Acerte-o para interromper a cura.", _e * 0.7, _e * 0.7, 0);
}
draw_set_color(c_white);
draw_set_halign(fa_left);
