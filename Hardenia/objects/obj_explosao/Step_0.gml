if (global.game_paused || global.hitstop > 0) {
    exit;
}

tempo -= 1;
if (estado == 1) {
    if (tempo <= 0) {
        estado = 2;
        tempo = duracao;
        if (explode) {
            som(snd_explosao);
            impacto(3, 6);
            fx_explosao(x, y, 90);
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
        _p.morto_por = causa;
        _p.levar_dano(1);
    }
}
