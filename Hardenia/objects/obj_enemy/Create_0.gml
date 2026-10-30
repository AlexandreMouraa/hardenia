hp = 3;
move_speed = 1.5;

state = 0;
state_timer = 0;
// o ataque deste inimigo (campos em scr_inimigos). Um filho troca depois do event_inherited
ataque = {
    forma: "quadrado",
    gatilho: 50,
    alcance: 40,
    tamanho: 32,
    aviso: 45,
    duracao: 20,
    acerto: 10,
    recarga: 40,
};
zona = undefined; // onde o ataque atual cai; existe do aviso em diante
attack_damage_dealt = false;
attack_dir = 0;

hit_flash = 0;
// empurrao do terceiro golpe do combo (obj_attack): desliza e freia a cada frame
empurrao_x = 0;
empurrao_y = 0;

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