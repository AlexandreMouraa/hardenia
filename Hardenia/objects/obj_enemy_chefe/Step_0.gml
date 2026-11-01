event_inherited();

if (global.game_paused || global.hitstop > 0) {
    exit;
}

// metade da vida: uma vez so
if (!metade && hp <= hp_max / 2) {
    metade = true;
    furia = 0.75;
    move_speed = 1.8;
    elite = "invocacao";
    invocar_timer = 60;
    impacto(8, 12);
    som(snd_explosao);
    with (instance_create_depth(x, y, 50, obj_fx)) {
        tipo = "anel";
        cor = make_colour_rgb(255, 60, 60);
        vida_max = 20;
        vida = vida_max;
    }
}
