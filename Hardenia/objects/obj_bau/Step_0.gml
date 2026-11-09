if (global.game_paused) {
    exit;
}

if (aberto) {
    quadro = min(3, quadro + 0.25);
    image_index = floor(quadro);
} else if (instance_exists(obj_player) && !obj_player.is_dead && !instance_exists(obj_tecnicas) && point_distance(x, y, obj_player.x, obj_player.y) < 48) {
    // sem outra tela aberta: a troca de arma (obj_arma_escolha, filha do obj_tecnicas) abre perto
    // dali, e as duas no mesmo frame ficavam uma em cima da outra
    aberto = true;
    sfx(snd_confirm, 1, false);
    instance_create_depth(0, 0, -2000, obj_tecnicas);
}
