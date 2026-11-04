event_inherited();
// Um dos guerreiros que vieram antes, levantado pelo rei morto: um duelo no fim de algumas salas
// (duelo_tentar, em scr_duelos). Cair libera a tecnica dele no bau da sala
caido = "carrasco";
imovel = true;
visao = 2000;
raio_alerta = 0;
acordado = true;
furia = 1;
hp_max = 30;
fala = "";
fala_tempo = 0;
escudo_volta = 0;
// a mascara do esqueleto: o quadro de 128 e so para caber a arma
mask_index = spr_enemy_walk_skeleton;
som_golpe = noone;
image_xscale = 1.25;
image_yscale = 1.25;
ataques = [];
ataque_vez = 0;
ao_voltar = rodizio_trocar;
ao_mirar = rodizio_mirar;
disparar_golpe = disparar;
disparar = function() {
    rodizio_disparar();
    disparar_golpe();
};

// _vida: da sala. Cada um divide ela do seu jeito: quem foge e fragil, quem aguenta e duro
preparar = function(_chave, _vida) {
    caido = _chave;
    walk_frames = 8;
    anim_speed = 6;
    var _forca = 1;
    switch (_chave) {
        case "carrasco":
            // pesado: dois cortes seguidos, o segundo mais rapido, e depois fica exposto
            walk_sprite = spr_caido_carrasco_andar;
            ataque_sprite = spr_caido_carrasco_golpe;
            move_speed = 1.7;
            depois_golpe = "parado";
            ataques = [
                { sprite: ataque_sprite, quadros: 6, ataque: { tipo: "arco", forma: "arco", gatilho: 110, alcance: 130, tamanho: 70, aviso: 48, duracao: 20, acerto: 10, recarga: 8, avanco: 0 } },
                { sprite: ataque_sprite, quadros: 6, ataque: { tipo: "arco", forma: "arco", gatilho: 140, alcance: 130, tamanho: 70, aviso: 26, duracao: 20, acerto: 10, recarga: 70, avanco: 0 } },
                // 20 frames de 15 px = 300, dentro da linha de 340
                { sprite: ataque_sprite, quadros: 6, ataque: { tipo: "investida", forma: "linha", gatilho: 320, alcance: 340, tamanho: 30, aviso: 52, duracao: 34, acerto: 20, recarga: 90, avanco: 15 } },
            ];
            break;

        case "batedor":
            // rapido e fragil: duas arrancadas de aviso curto e um corte; so para depois do corte
            walk_sprite = spr_caido_batedor_andar;
            ataque_sprite = spr_caido_batedor_golpe;
            move_speed = 2.6;
            depois_golpe = "recua";
            _forca = 0.8;
            ataques = [
                // 14 frames de 20 px = 280, dentro da linha de 320
                { sprite: ataque_sprite, quadros: 6, ataque: { tipo: "investida", forma: "linha", gatilho: 300, alcance: 320, tamanho: 22, aviso: 30, duracao: 26, acerto: 14, recarga: 30, avanco: 20 } },
                { sprite: ataque_sprite, quadros: 6, ataque: { tipo: "investida", forma: "linha", gatilho: 300, alcance: 320, tamanho: 22, aviso: 30, duracao: 26, acerto: 14, recarga: 30, avanco: 20 } },
                { sprite: ataque_sprite, quadros: 6, ataque: { tipo: "arco", forma: "arco", gatilho: 90, alcance: 90, tamanho: 60, aviso: 24, duracao: 16, acerto: 8, recarga: 70, avanco: 0 } },
            ];
            break;

        case "sapador":
            // fica longe e joga bomba; quando acabam as bombas, vem estourar quem esta perto
            walk_sprite = spr_caido_sapador_andar;
            ataque_sprite = spr_caido_sapador_golpe;
            move_speed = 1.4;
            depois_golpe = "recua";
            _forca = 0.7;
            ataques = [
                { sprite: ataque_sprite, quadros: 7, ataque: { tipo: "bombas", forma: "circulo", gatilho: 420, alcance: 0, tamanho: 70, aviso: 62, duracao: 16, acerto: 6, recarga: 34, avanco: 0 } },
                { sprite: ataque_sprite, quadros: 7, ataque: { tipo: "bombas", forma: "circulo", gatilho: 420, alcance: 0, tamanho: 70, aviso: 62, duracao: 16, acerto: 6, recarga: 34, avanco: 0, extras: 2 } },
                { sprite: ataque_sprite, quadros: 7, ataque: { tipo: "bombas", forma: "circulo", gatilho: 420, alcance: 0, tamanho: 70, aviso: 62, duracao: 16, acerto: 6, recarga: 40, avanco: 0, extras: 4 } },
                { sprite: ataque_sprite, quadros: 7, ataque: { tipo: "estouro", forma: "circulo", gatilho: 150, alcance: 0, tamanho: 120, aviso: 50, duracao: 16, acerto: 6, recarga: 80, avanco: 0 } },
            ];
            break;

        case "sentinela":
            // de escudo: o golpe comum nao passa, e o escudo volta depois de um tempo
            walk_sprite = spr_caido_sentinela_andar;
            ataque_sprite = spr_caido_sentinela_golpe;
            move_speed = 1.2;
            depois_golpe = "lado";
            elite = "escudo";
            escudo = true;
            ataques = [
                { sprite: ataque_sprite, quadros: 6, ataque: { tipo: "arco", forma: "arco", gatilho: 130, alcance: 150, tamanho: 75, aviso: 58, duracao: 22, acerto: 10, recarga: 40, avanco: 0 } },
                { sprite: ataque_sprite, quadros: 6, ataque: { tipo: "investida", forma: "linha", gatilho: 240, alcance: 260, tamanho: 18, aviso: 40, duracao: 16, acerto: 8, recarga: 40, avanco: 0 } },
                { sprite: ataque_sprite, quadros: 6, ataque: { tipo: "estouro", forma: "circulo", gatilho: 150, alcance: 0, tamanho: 130, aviso: 52, duracao: 16, acerto: 6, recarga: 70, avanco: 0 } },
            ];
            break;
    }
    hp_max = round(_vida * _forca);
    hp = hp_max;
    sprite_index = walk_sprite;
    rodizio_trocar();
};
