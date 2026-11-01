event_inherited();
walk_sprite = spr_enemy_walk_wight;
sprite_index = walk_sprite;
// lento e duro: o combo de 3 tira 4, entao 6 pede mais de um combo
hp = 6;
move_speed = 1.1;
// varredura larga com aviso longo: da tempo de sair ou de passar para as costas dele
ataque = {
    forma: "arco",
    gatilho: 80,
    alcance: 110,
    tamanho: 65,
    aviso: 70,
    duracao: 24,
    acerto: 10,
    recarga: 50,
    avanco: 0,
};
