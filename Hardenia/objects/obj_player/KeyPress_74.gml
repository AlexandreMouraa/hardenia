if (global.game_paused || is_dead || venceu || instance_exists(obj_mapa)) {
    exit;
}

// o golpe sai no Step (golpear, no Create): apertar durante a recarga ou a
// micro-pausa fica guardado e emenda o proximo golpe do combo. Com J, o golpe
// vai para onde o jogador esta virado (com o clique, para o mouse)
global.mira_mouse = false;
ataque_buffer = ataque_buffer_max;
