window_set_fullscreen(true);

// cada morte conta uma tentativa; a run inteira comeca aqui
global.tentativas = 1;

audio_stop_sound(snd_game_music);
audio_play_sound(snd_menu_music, 1, true);
