if (instance_exists(obj_mapa)) {
    exit;
}
global.game_paused = !global.game_paused;
audio_play_sound(snd_confirm, 1, false);
