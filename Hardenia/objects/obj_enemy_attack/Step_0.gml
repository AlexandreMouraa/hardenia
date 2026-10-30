// este objeto e invisivel: quem desenha a zona vermelha e o inimigo. Morto ele, o
// golpe some junto, senao o jogador morre de um acerto que nao aparece na tela
if (!instance_exists(dono)) {
    instance_destroy();
    exit;
}

if (global.game_paused || global.hitstop > 0) {
    exit;
}

lifetime -= 1;
if (lifetime <= 0) {
    instance_destroy();
    exit;
}

if (instance_exists(obj_player) && obj_player.invuln_timer <= 0 && !obj_player.is_dashing) {
    if (zona_acerta_jogador(zona)) {
        obj_player.levar_dano(1);
        instance_destroy();
    }
}