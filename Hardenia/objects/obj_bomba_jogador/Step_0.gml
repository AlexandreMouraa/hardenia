if (global.game_paused || global.hitstop > 0) {
    exit;
}

tempo += 1;
if (tempo <= voo) {
    x = lerp(de_x, para_x, tempo / voo);
    y = lerp(de_y, para_y, tempo / voo);
}
if (tempo >= voo + espera) {
    fx_explosao(x, y, raio);
    som(snd_explosao, 0.8);
    golpe_em_volta(x, y, raio, dano, 20, true, true);
    instance_destroy();
}
