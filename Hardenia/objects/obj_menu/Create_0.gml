// modo de teste automatico: Hardenia.exe -autotest (ver obj_autotest)
if (!instance_exists(obj_autotest)) {
    for (var _i = 1; _i <= parameter_count(); _i++) {
        if (parameter_string(_i) == "-autotest") {
            instance_create_depth(0, 0, 0, obj_autotest);
            break;
        }
    }
}

if (!instance_exists(obj_autotest)) {
    window_set_fullscreen(true);
}

// cada morte conta uma tentativa; a run inteira comeca aqui
global.tentativas = 1;

audio_stop_sound(snd_game_music);
audio_play_sound(snd_menu_music, 1, true);
