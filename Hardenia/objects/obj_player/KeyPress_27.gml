if (instance_exists(obj_mapa) || instance_exists(obj_tecnicas)) {
    exit;
}
global.game_paused = !global.game_paused;
audio_play_sound(snd_confirm, 1, false);
