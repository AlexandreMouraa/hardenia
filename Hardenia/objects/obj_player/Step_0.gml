if (global.game_paused) {
    exit;
}

if (is_dead) {
    death_timer -= 1;
    if (death_timer <= 0) {
        global.tentativas += 1;
        room_restart();
    }
    exit;
}

// ultima sala limpa = fim da run
if (!venceu && room == room_last && instance_number(obj_enemy) == 0) {
    venceu = true;
    sprite_index = spr_player_idle;
    image_index = facing_dir * idle_frames;
    image_alpha = 1;
}

if (venceu) {
    if (keyboard_check_pressed(vk_enter)) {
        room_goto(Room_Menu);
    }
    exit;
}

var _h = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
var _v = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));

if (_h != 0 || _v != 0) {
    face_h = _h;
    face_v = _v;
}

if (_h != 0) {
    facing_dir = (_h < 0) ? 0 : 1;
} else if (_v != 0) {
    facing_dir = (_v < 0) ? 2 : 3;
}

if (dash_charges < dash_charges_max) {
    if (dash_cooldown > 0) {
        dash_cooldown -= 1;
    }
    if (dash_cooldown <= 0) {
        dash_charges += 1;
        dash_cooldown = (dash_charges < dash_charges_max) ? dash_cooldown_max : 0;
    }
}

if (attack_cooldown > 0) {
    attack_cooldown -= 1;
}

if (keyboard_check_pressed(vk_space) && !is_dashing && dash_charges > 0) {
    is_dashing = true;
    dash_timer = dash_duration;
    dash_charges -= 1;
    if (dash_cooldown <= 0) {
        dash_cooldown = dash_cooldown_max;
    }
    audio_play_sound(snd_dash, 1, false);
}

var _move_x = 0;
var _move_y = 0;

if (is_dashing) {
    _move_x = face_h * dash_speed;
    _move_y = face_v * dash_speed;
    dash_timer -= 1;
    if (dash_timer <= 0) {
        is_dashing = false;
    }
} else {
    _move_x = _h * move_speed;
    _move_y = _v * move_speed;
}

if (!place_meeting(x + _move_x, y, obj_wall)) {
    x += _move_x;
}
if (!place_meeting(x, y + _move_y, obj_wall)) {
    y += _move_y;
}

if (is_attacking) {
    attack_anim_timer -= 1;
    if (attack_anim_timer <= 0) {
        is_attacking = false;
    }
}

if (is_attacking) {
    sprite_index = spr_player_slash;
    var _progress = 1 - (attack_anim_timer / attack_anim_duration);
    anim_frame = floor(_progress * slash_frames);
    if (anim_frame >= slash_frames) {
        anim_frame = slash_frames - 1;
    }
    image_index = facing_dir * slash_frames + anim_frame;
} else if (_h != 0 || _v != 0) {
    sprite_index = spr_player_walk;
    anim_timer += 1;
    if (anim_timer >= anim_speed) {
        anim_timer = 0;
        anim_frame = (anim_frame + 1) mod walk_frames;
    }
    image_index = facing_dir * walk_frames + anim_frame;
} else {
    sprite_index = spr_player_idle;
    anim_timer += 1;
    if (anim_timer >= anim_speed) {
        anim_timer = 0;
        anim_frame = (anim_frame + 1) mod idle_frames;
    }
    image_index = facing_dir * idle_frames + anim_frame;
}

if (invuln_timer > 0) {
    invuln_timer -= 1;
    image_alpha = (invuln_timer div 4) % 2 == 0 ? 0.3 : 1;
} else {
    image_alpha = 1;
}

if (hp <= 0) {
    is_dead = true;
    death_timer = death_timer_max;
    image_alpha = 1;
    image_blend = c_red;
}