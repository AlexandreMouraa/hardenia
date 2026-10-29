if (global.game_paused || global.hitstop > 0) {
    exit;
}

lifetime -= 1;
if (lifetime <= 0) {
    instance_destroy();
    exit;
}

if (instance_exists(obj_player) && obj_player.invuln_timer <= 0 && !obj_player.is_dashing) {
    if (instance_place(x, y, obj_player) != noone) {
        obj_player.hp -= 1;
        obj_player.invuln_timer = 45;
        instance_destroy();
    }
}