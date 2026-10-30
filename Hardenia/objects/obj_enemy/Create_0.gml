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
    avanco: 0,
};
zona = undefined; // onde o ataque atual cai; existe do aviso em diante
attack_damage_dealt = false;
attack_dir = 0;

hit_flash = 0;
// empurrao do terceiro golpe do combo (obj_attack): desliza e freia a cada frame
empurrao_x = 0;
empurrao_y = 0;

// inteligencia. Os valores sao os iniciais da issue #22, para ajustar jogando
// visao: alcance, com a parede bloqueando. A camera mostra 1152 x 648, e com 150 dava
// para matar um de cada vez sem o vizinho reagir
visao = 360;
vendo = false;
// olha a cada 6 frames, cada um num frame diferente: nada de todos no mesmo frame
visao_timer = 1 + instance_number(obj_enemy) mod 6;
acordado = false;
// perdeu de vista: vai ate o ultimo lugar onde viu e desiste depois de 4 s
memoria_x = x;
memoria_y = y;
procura = 0;
procura_max = 240;
// quem acorda chama os vizinhos ate esta distancia
raio_alerta = 320;
// lado em volta do jogador (cerco_escolher); ronda balanca em volta desse lado
cerco_ang = 0;
cerco_timer = 0;
ronda = 0;
// o que faz durante a recarga: "recua", "lado" ou "parado"
depois_golpe = "recua";

// viu o jogador ou apanhou: acorda e chama os vizinhos
acordar = function() {
    with (obj_enemy) {
        if (!acordado && point_distance(x, y, other.x, other.y) <= other.raio_alerta) {
            acordado = true;
            memoria_x = obj_player.x;
            memoria_y = obj_player.y;
            procura = procura_max;
            cerco_timer = 0;
        }
    }
};

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