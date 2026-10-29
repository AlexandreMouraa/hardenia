// Enter de novo com o mapa aberto: quem pula e o obj_mapa
if (instance_exists(obj_mapa)) {
    exit;
}
audio_play_sound(snd_confirm, 1, false);
audio_stop_sound(snd_menu_music);
audio_play_sound(snd_game_music, 1, true);
// comeca a run: zera o tempo e avisa o site (estatisticas de partidas)
global.run_frames = 0;
rede_evento("inicio");
ir_para_sala(Room1);