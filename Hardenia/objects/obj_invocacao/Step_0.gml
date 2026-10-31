if (!instance_exists(dono)) {
    instance_destroy();
    exit;
}

if (global.game_paused || global.hitstop > 0) {
    exit;
}

tempo -= 1;
if (tempo <= 0) {
    var _novo = instance_create_layer(x, y, "Instances", obj_enemy_horda);
    array_push(dono.invocados, _novo);
    fx_faiscas(x, y, 90, make_colour_rgb(120, 230, 120), 8);
    instance_destroy();
}
