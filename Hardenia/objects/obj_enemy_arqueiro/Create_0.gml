event_inherited();
// ataca de longe: para, puxa o arco e atira. Sem linha no chao: quem avisa e a pose, o brilho
// na ponta da flecha e o som do arco. Sprite do LPC (CREDITOS_ASSETS)
walk_sprite = spr_arqueiro_andar;
walk_frames = 8;
anim_speed = 5;
sprite_index = walk_sprite;
// a mascara do esqueleto: o arco nao conta como corpo, e o mapa de direcoes espera esse tamanho
mask_index = spr_enemy_walk_skeleton;
ataque_sprite = spr_arqueiro_tiro;
ataque_frames = 13;
// na folha, a flecha sai no quadro 9: o aviso vai ate o 8, e o tiro comeca dali
ataque_solta = 9;
zona_visivel = false;
// fragil e lento: chegar nele resolve, entao o risco e atravessar a linha de tiro
hp = 2;
move_speed = 1.3;
depois_golpe = "recua";
// gatilho de 300: abaixo da meia altura da camera (324), entao nao atira de fora da tela.
// O cerco tambem deixa ele a essa distancia, e chegar perto faz ele recuar. duracao 36:
// tempo de a flecha percorrer a linha inteira (480 / 14), para a zona durar o voo todo
ataque = {
    forma: "linha",
    gatilho: 300,
    alcance: 480,
    tamanho: 14,
    aviso: 50,
    duracao: 36,
    acerto: 1,
    recarga: 70,
    avanco: 0,
};
// a linha para na parede: o aviso mostra ate onde a flecha vai de verdade
ao_mirar = function() {
    ataque.alcance = linha_ate_parede(x, y, attack_dir, 480);
};
// brilho na ponta da flecha, logo antes do tiro: mostra para onde e quando
ao_desenhar = function() {
    if (state == 1 && state_timer <= 16) {
        var _b = 1 - state_timer / 16;
        var _px = x + lengthdir_x(30, attack_dir);
        var _py = y + lengthdir_y(30, attack_dir);
        var _r = 3 + 7 * _b;
        gpu_set_blendmode(bm_add);
        draw_set_alpha(_b);
        draw_line_width_colour(_px - _r, _py, _px + _r, _py, 2, c_white, c_white);
        draw_line_width_colour(_px, _py - _r, _px, _py + _r, 2, c_white, c_white);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
    }
};
disparar = function() {
    var _nome = object_get_name(object_index);
    with (instance_create_layer(x, y, "Instances", obj_flecha)) {
        direcao = other.attack_dir;
        image_angle = direcao;
        zona = other.zona;
        causa = _nome;
    }
    audio_play_sound(snd_attack, 1, false, 0.7, 0, 1.4);
};
