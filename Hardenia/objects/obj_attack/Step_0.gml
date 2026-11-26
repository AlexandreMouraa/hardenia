if (global.game_paused || global.hitstop > 0) {
    exit;
}

if (atraso > 0) {
    atraso -= 1;
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
var _cenario = instance_exists(obj_player) ? patio_golpe(id) : 0;
var _lista = ds_list_create();
var _n = 0;
if (setor) {
    // quem esta a menos de raio do centro e dentro da abertura, na ordem das instancias
    var _perto = collision_circle_list(ox, oy, raio + 2, obj_enemy, false, true, _lista, false);
    for (var _i = 0; _i < _perto; _i++) {
        var _e = _lista[| _i];
        if (setor_toca_retangulo(ox, oy, raio, abertura, dir, _e.bbox_left, _e.bbox_top, _e.bbox_right, _e.bbox_bottom)) {
            _n += 1;
            acertar(_e);
        }
    }
} else {
    _n = instance_place_list(x, y, obj_enemy, _lista, false);
    for (var _i = 0; _i < _n; _i++) {
        acertar(_lista[| _i]);
    }
}
ds_list_destroy(_lista);
if (especial && instance_exists(obj_player)) {
    obj_player.especial_acertos = _n;
}
if (especial || _n > 0 || _cenario > 0) {
    instance_destroy();
}
