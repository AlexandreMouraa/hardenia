if (instance_exists(obj_mapa) || instance_exists(obj_tecnicas) || instance_exists(obj_cena) || instance_exists(obj_opcoes)) {
    exit;
}
global.game_paused = !global.game_paused;
sfx(snd_confirm, 1, false);
