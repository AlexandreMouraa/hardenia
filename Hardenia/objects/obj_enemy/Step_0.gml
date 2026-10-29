if (global.game_paused || global.hitstop > 0) {
    exit;
}

if (hit_flash > 0) {
    hit_flash -= 1;
}

// empurrao do terceiro golpe: de 1 em 1 px para encostar na parede sem atravessar
if (abs(empurrao_x) + abs(empurrao_y) > 0.1) {
    var _passos = ceil(max(abs(empurrao_x), abs(empurrao_y)));
    var _ex = empurrao_x / _passos;
    var _ey = empurrao_y / _passos;
    repeat (_passos) {
        if (!place_meeting(x + _ex, y, obj_wall)) {
            x += _ex;
        }
        if (!place_meeting(x, y + _ey, obj_wall)) {
            y += _ey;
        }
    }
    empurrao_x *= 0.65;
    empurrao_y *= 0.65;
} else {
    empurrao_x = 0;
    empurrao_y = 0;
}

var _is_moving = false;

switch (state) {
	case 0: // perseguindo
    if (instance_exists(obj_player)) {
        var _dist = point_distance(x, y, obj_player.x, obj_player.y);

        if (_dist <= alert_range) {
            image_blend = c_red;
        } else {
            image_blend = c_white;
        }

        if (_dist <= attack_range) {
            state = 1;
            state_timer = windup_time;
            // a direcao trava no inicio do aviso: o jogador ve onde o golpe cai e tem tempo de sair
            attack_dir = point_direction(x, y, obj_player.x, obj_player.y);
            var _ax = lengthdir_x(1, attack_dir);
            var _ay = lengthdir_y(1, attack_dir);
            if (abs(_ax) > abs(_ay)) {
                facing_dir = (_ax < 0) ? 1 : 2;
            } else {
                facing_dir = (_ay < 0) ? 3 : 0;
            }
        } else if (_dist <= alert_range) {
            var _dir = point_direction(x, y, obj_player.x, obj_player.y);
            var _move_x = lengthdir_x(move_speed, _dir);
            var _move_y = lengthdir_y(move_speed, _dir);
            if (!place_meeting(x + _move_x, y, obj_wall)) {
                x += _move_x;
            }
            if (!place_meeting(x, y + _move_y, obj_wall)) {
                y += _move_y;
            }
            _is_moving = true;
            if (abs(_move_x) > abs(_move_y)) {
                facing_dir = (_move_x < 0) ? 1 : 2;
            } else {
                facing_dir = (_move_y < 0) ? 3 : 0;
            }
        } else {
            var _patrol_move = patrol_dir * patrol_speed;
            if (!place_meeting(x + _patrol_move, y, obj_wall)) {
                x += _patrol_move;
            } else {
                patrol_dir *= -1;
            }
            if (x >= home_x + patrol_range) {
                patrol_dir = -1;
            }
            if (x <= home_x - patrol_range) {
                patrol_dir = 1;
            }
            _is_moving = true;
            facing_dir = (patrol_dir < 0) ? 1 : 2;
        }
    }
    break;

    case 1: // aviso (telegraph)
        state_timer -= 1;
        image_blend = ((state_timer div 6) mod 2 == 0) ? c_white : c_red;
        if (state_timer <= 0) {
            state = 2;
            state_timer = attack_time;
            image_blend = c_red;

            var _spawn_x = x + lengthdir_x(attack_reach, attack_dir);
            var _spawn_y = y + lengthdir_y(attack_reach, attack_dir);
            instance_create_layer(_spawn_x, _spawn_y, "Instances", obj_enemy_attack);
        }
        break;

    case 2: // atacando
        state_timer -= 1;
        if (state_timer <= 0) {
            state = 3;
            state_timer = cooldown_time;
        }
        break;

    case 3: // cooldown
        state_timer -= 1;
        if (state_timer <= 0) {
            state = 0;
        }
        break;
}

// inimigos encostados se afastam devagar, para nao virarem um bolo so; fora do
// ataque, senao a zona do golpe andaria durante o aviso
if (state == 0) {
    var _outro = instance_place(x, y, obj_enemy);
    if (_outro != noone) {
        var _afasta = (_outro.x == x && _outro.y == y) ? random(360) : point_direction(_outro.x, _outro.y, x, y);
        var _ox = lengthdir_x(1, _afasta);
        var _oy = lengthdir_y(1, _afasta);
        if (!place_meeting(x + _ox, y, obj_wall)) {
            x += _ox;
        }
        if (!place_meeting(x, y + _oy, obj_wall)) {
            y += _oy;
        }
    }
}

if (_is_moving) {
    anim_timer += 1;
    if (anim_timer >= anim_speed) {
        anim_timer = 0;
        anim_frame = (anim_frame + 1) mod walk_frames;
    }
} else {
    anim_timer = 0;
    anim_frame = 0;
}

image_index = facing_dir * walk_frames + anim_frame;