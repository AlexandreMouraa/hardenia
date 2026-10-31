if (global.game_paused || global.hitstop > 0) {
    exit;
}

if (!instance_exists(obj_player)) {
    exit;
}

var _dir = point_direction(x, y, obj_player.x, obj_player.y);
inimigo_andar(_dir, move_speed);
inimigo_virar(_dir);

separar_timer -= 1;
if (separar_timer <= 0) {
    separar_timer = 6;
    var _outro = instance_place(x, y, obj_enemy_horda);
    if (_outro != noone) {
        var _afasta = (_outro.x == x && _outro.y == y) ? _dir + 90 : point_direction(_outro.x, _outro.y, x, y);
        inimigo_andar(_afasta, 4);
    }
}

// encostou: machuca, sem aviso. O dash atravessa, e a invencibilidade depois do
// golpe segura o resto da horda
if (point_distance(x, y, obj_player.x, obj_player.y) < 22 && obj_player.invuln_timer <= 0 && !obj_player.is_dashing) {
    obj_player.morto_por = object_get_name(object_index);
    obj_player.levar_dano(1);
}

anim_timer += 1;
if (anim_timer >= anim_speed) {
    anim_timer = 0;
    anim_frame = (anim_frame + 1) mod walk_frames;
}
image_index = facing_dir * walk_frames + anim_frame;
