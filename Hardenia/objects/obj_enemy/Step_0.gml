if (global.game_paused) {
    exit;
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
        if (state_timer <= 0) {
            state = 2;
            state_timer = attack_time;

            var _dir = point_direction(x, y, obj_player.x, obj_player.y);
            var _spawn_x = x + lengthdir_x(40, _dir);
            var _spawn_y = y + lengthdir_y(40, _dir);
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