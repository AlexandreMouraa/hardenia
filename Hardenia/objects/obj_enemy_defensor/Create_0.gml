event_inherited();
defensor = true;
walk_sprite = spr_enemy_walk_wight;
sprite_index = walk_sprite;
hp = 5; // entre o esqueleto (3) e o wight (6), antes da dificuldade da sala
move_speed = 1.05;
patrol_range = 32;
guarda_dir = 180;
depois_golpe = "parado";
// Golpe comprometido: aviso longo e recarga generosa para flanquear.
ataque = { forma: "arco", gatilho: 75, alcance: 96, tamanho: 45,
    aviso: 72, duracao: 20, acerto: 8, recarga: 90, avanco: 0 };
