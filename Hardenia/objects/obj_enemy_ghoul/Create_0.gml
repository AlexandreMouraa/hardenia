event_inherited();
walk_sprite = spr_enemy_walk_ghoul;
sprite_index = walk_sprite;
// rapido e fragil: abaixo da velocidade do jogador (3), para ainda dar para fugir
hp = 2;
move_speed = 2.4;
// parado depois do bote: e o que o deixa exposto
depois_golpe = "parado";
// bote: de longe, avisa em linha, avanca reto e fica exposto no fim (recarga longa).
// 12 frames de 13 px = 156 px, dentro da linha de 170
ataque = {
    forma: "linha",
    gatilho: 150,
    alcance: 170,
    tamanho: 20,
    aviso: 40,
    duracao: 30,
    acerto: 12,
    recarga: 90,
    avanco: 13,
};
