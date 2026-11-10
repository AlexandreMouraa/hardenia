if (global.consulta_bloqueio > 0 || instance_exists(obj_arvore) || instance_exists(obj_mapa) || instance_exists(obj_tecnicas) || instance_exists(obj_cena) || instance_exists(obj_opcoes)) {
    exit;
}
global.game_paused = !global.game_paused;
sfx(snd_confirm, 1, false);
window_set_cursor(global.game_paused ? cr_default : cr_none);
