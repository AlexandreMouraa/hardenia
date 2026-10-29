hp = 3;
move_speed = 1.5;

state = 0;
state_timer = 0;
attack_range = 50;
windup_time = 45;
attack_time = 20;
cooldown_time = 40;
attack_damage_dealt = false;

alert_range = 150;
home_x = x;
home_y = y;
patrol_dir = 1;
patrol_speed = 1;
patrol_range = 64;

walk_sprite = spr_enemy_walk_skeleton;
walk_frames = 3;
facing_dir = 0; // 0 = baixo, 1 = esquerda, 2 = direita, 3 = cima

anim_timer = 0;
anim_speed = 8;
anim_frame = 0;

sprite_index = walk_sprite;
image_speed = 0;
image_index = facing_dir * walk_frames + anim_frame;