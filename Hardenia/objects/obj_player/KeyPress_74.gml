if (global.game_paused || is_dead || venceu) {
    exit;
}

if (attack_cooldown <= 0) {
    var _spawn_x = x + face_h * 32;
    var _spawn_y = y + face_v * 32;
    instance_create_layer(_spawn_x, _spawn_y, "Instances", obj_attack);
    attack_cooldown = attack_cooldown_max;
    is_attacking = true;
    attack_anim_timer = attack_anim_duration;
    audio_play_sound(snd_attack, 1, false);
}
