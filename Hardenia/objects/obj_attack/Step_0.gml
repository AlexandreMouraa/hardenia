if (global.game_paused || global.hitstop > 0) {
    exit;
}

if (!especial) {
    lifetime -= 1;
    if (lifetime <= 0) {
        instance_destroy();
        exit;
    }
}

// acerta todos os que encostarem no mesmo frame: numa horda, um golpe que acerta
// um so nao resolve. O golpe comum acaba no primeiro frame em que tocar em alguem; o
// especial acaba no primeiro frame de qualquer jeito
var _lista = ds_list_create();
var _n = instance_place_list(x, y, obj_enemy, _lista, false);
for (var _i = 0; _i < _n; _i++) {
    acertar(_lista[| _i]);
}
ds_list_destroy(_lista);
if (especial && instance_exists(obj_player)) {
    obj_player.especial_acertos = _n;
}
if (especial || _n > 0) {
    instance_destroy();
}
