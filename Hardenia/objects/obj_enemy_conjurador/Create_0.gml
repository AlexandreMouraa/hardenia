event_inherited();
// mantem distancia, marca um circulo onde o jogador esta e uma bomba cai nele. O arqueiro
// pune quem anda em linha; este pune quem fica parado e obriga a ir atras dele
walk_sprite = spr_conjurador_andar;
walk_frames = 8;
anim_speed = 6;
sprite_index = walk_sprite;
mask_index = spr_enemy_walk_skeleton;
ataque_sprite = spr_conjurador_magia;
ataque_frames = 7;
hp = 2;
move_speed = 1.1;
depois_golpe = "recua";
// o circulo fica onde foi marcado, mesmo se ele apanhar durante o aviso
zona_fixa = true;
bomba = true;
som_golpe = noone;
// gatilho 280: abaixo da meia altura da camera (324), entao nao ataca de fora da tela.
// raio 70 e aviso de 60: da para sair andando (3 px por frame), sem precisar de dash
ataque = {
    forma: "circulo",
    gatilho: 280,
    alcance: 0,
    tamanho: 70,
    aviso: 60,
    duracao: 16,
    acerto: 6,
    recarga: 100,
    avanco: 0,
};
// marca o lugar onde o jogador esta agora
ao_mirar = function() {
    ataque.alcance = point_distance(x, y, obj_player.x, obj_player.y);
    som(snd_bomba_cai);
};
disparar_golpe = disparar;
disparar = function() {
    // a bomba cai do alto: a parede entre ele e o jogador nao protege
    zona.ox = zona.cx;
    zona.oy = zona.cy;
    disparar_golpe();
    fx_explosao(zona.cx, zona.cy, ataque.tamanho);
    som(snd_explosao);
};
