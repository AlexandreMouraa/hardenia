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
    _enemy.hit_flash = 8;
    if (_enemy.hp <= 0) {
        with (instance_create_layer(_enemy.x, _enemy.y, "Instances", obj_fx_morte)) {
            sprite_index = _enemy.sprite_index;
            image_index = _enemy.image_index;
        }
        instance_destroy(_enemy);
    } else if (instance_exists(obj_player)) {
        // empurrao curto para longe do jogador, sem atravessar parede
        var _dir = point_direction(obj_player.x, obj_player.y, _enemy.x, _enemy.y);
        var _kx = lengthdir_x(knockback, _dir);
        var _ky = lengthdir_y(knockback, _dir);
        with (_enemy) {
            if (!place_meeting(x + _kx, y, obj_wall)) {
                x += _kx;
            }
            if (!place_meeting(x, y + _ky, obj_wall)) {
                y += _ky;
            }
        }
    }
    instance_destroy();
}
