if (global.game_paused || global.hitstop > 0) {
    exit;
}

tempo -= 1;
if (estado == 1) {
    if (tempo <= 0) {
        estado = 2;
        tempo = duracao;
        som(snd_explosao);
        impacto(3, 6);
        with (instance_create_depth(x, y, 50, obj_fx)) {
            tipo = "anel";
            cor = make_colour_rgb(255, 150, 40);
            vida_max = 16;
            vida = vida_max;
        }
    }
    exit;
}

if (tempo <= 0) {
    instance_destroy();
    exit;
}

if (duracao - tempo <= acerto && instance_exists(obj_player)) {
    var _p = instance_find(obj_player, 0);
    if (_p.invuln_timer <= 0 && !_p.is_dashing && !_p.venceu && zona_acerta_jogador(zona)) {
        _p.morto_por = "obj_explosao";
        _p.levar_dano(1);
    }
}
