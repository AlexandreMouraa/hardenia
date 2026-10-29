if (global.game_paused) {
    exit;
}

lifetime -= 1;
if (lifetime <= 0) {
    instance_destroy();
    exit;
}

var _enemy = instance_place(x, y, obj_enemy);
if (_enemy != noone) {
    _enemy.hp -= damage;
    if (_enemy.hp <= 0) {
        instance_destroy(_enemy);
    }
    instance_destroy();
}