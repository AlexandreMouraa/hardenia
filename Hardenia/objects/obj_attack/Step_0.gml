if (global.game_paused || global.hitstop > 0) {
    exit;
}

// especial: acerta quem estiver em volta neste frame e acaba
if (especial) {
    var _lista = ds_list_create();
    var _n = instance_place_list(x, y, obj_enemy, _lista, false);
    for (var _i = 0; _i < _n; _i++) {
        acertar(_lista[| _i]);
    }
    ds_list_destroy(_lista);
    if (instance_exists(obj_player)) {
        obj_player.especial_acertos = _n;
    }
    instance_destroy();
    exit;
}

lifetime -= 1;
if (lifetime <= 0) {
    instance_destroy();
    exit;
}

var _enemy = instance_place(x, y, obj_enemy);
if (_enemy != noone) {
    acertar(_enemy);
    instance_destroy();
}
