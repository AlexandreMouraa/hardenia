// Enter de novo com o mapa ou a abertura na tela: quem pula sao eles
if (instance_exists(obj_mapa) || instance_exists(obj_abertura)) {
    exit;
}
audio_play_sound(snd_confirm, 1, false);
// a abertura aparece uma vez a cada vez que o jogo abre
if (!global.abertura_vista) {
    global.abertura_vista = true;
    instance_create_depth(0, 0, -9000, obj_abertura);
    exit;
}
comecar_run();
