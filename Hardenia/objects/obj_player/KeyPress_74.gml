if (global.consulta_bloqueio > 0 || instance_exists(obj_arvore) || global.game_paused || is_dead || venceu || instance_exists(obj_mapa) || instance_exists(obj_tecnicas) || instance_exists(obj_cena)) {
    exit;
}

// o golpe sai no Step (golpear, no Create): apertar durante a recarga ou a
// micro-pausa fica guardado e emenda o proximo golpe do combo
ataque_buffer = ataque_buffer_max;
carga_armada = true;
