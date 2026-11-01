event_inherited();
// O Trono: o rei morto, no fim da run. Tres ataques em rodizio, sempre com aviso e zona
// marcada; na metade da vida fica mais rapido e invoca inimigos fracos. Valores da issue #26,
// para ajustar jogando. Sprite do LPC, com o dobro do tamanho
walk_sprite = spr_chefe_andar;
walk_frames = 8;
anim_speed = 7;
sprite_index = walk_sprite;
// os ataques trocam de pose; a mascara fica a do andar, para nao mudar de tamanho no meio
mask_index = spr_chefe_andar;
hp_max = 40;
hp = hp_max;
move_speed = 1.3;
imovel = true;
depois_golpe = "parado";
// a sala inteira e dele
visao = 2000;
raio_alerta = 0;
acordado = true;
metade = false;

// aviso e recarga encurtam na metade da vida (furia)
furia = 1;
ataques = [
    { // varredura: arco largo de perto
        sprite: spr_chefe_golpe, quadros: 6,
        ataque: { forma: "arco", gatilho: 170, alcance: 190, tamanho: 70, aviso: 55, duracao: 20, acerto: 10, recarga: 50, avanco: 0 },
    },
    { // investida: linha atravessando a sala. 24 frames de 20 px = 480, dentro da linha de 520;
      // as colunas param, entao elas sao o abrigo
        sprite: spr_chefe_golpe, quadros: 6,
        ataque: { forma: "linha", gatilho: 420, alcance: 520, tamanho: 34, aviso: 50, duracao: 40, acerto: 24, recarga: 80, avanco: 20 },
    },
    { // magia: um circulo no jogador e outros em volta (obj_explosao), todos com o mesmo aviso
        sprite: spr_chefe_magia, quadros: 7,
        ataque: { forma: "circulo", gatilho: 600, alcance: 0, tamanho: 80, aviso: 65, duracao: 16, acerto: 6, recarga: 70, avanco: 0 },
    },
];
ataque_vez = 0;

// escolhe o proximo ataque do rodizio
ataque_trocar = function() {
    var _a = ataques[ataque_vez];
    ataque_sprite = _a.sprite;
    ataque_frames = _a.quadros;
    ataque = {
        forma: _a.ataque.forma,
        gatilho: _a.ataque.gatilho,
        alcance: _a.ataque.alcance,
        tamanho: _a.ataque.tamanho,
        aviso: round(_a.ataque.aviso * furia),
        duracao: _a.ataque.duracao,
        acerto: _a.ataque.acerto,
        recarga: round(_a.ataque.recarga * furia),
        avanco: _a.ataque.avanco,
    };
    zona_fixa = (ataque.forma == "circulo");
    ataque_vez = (ataque_vez + 1) mod array_length(ataques);
};
ataque_trocar();
ao_voltar = ataque_trocar;

ao_mirar = function() {
    if (ataque.forma == "linha") {
        ataque.alcance = linha_ate_parede(x, y, attack_dir, 520);
    } else if (ataque.forma == "circulo") {
        ataque.alcance = point_distance(x, y, obj_player.x, obj_player.y);
        // em volta do jogador, em lados fixos; na furia, dois a mais
        var _n = metade ? 4 : 2;
        for (var _i = 0; _i < _n; _i++) {
            var _ang = attack_dir + 60 + _i * 360 / _n;
            var _cx = obj_player.x + lengthdir_x(170, _ang);
            var _cy = obj_player.y + lengthdir_y(170, _ang);
            if (collision_point(_cx, _cy, obj_wall, false, true) == noone) {
                var _aviso = ataque.aviso;
                with (instance_create_layer(_cx, _cy, "Instances", obj_explosao)) {
                    causa = "obj_enemy_chefe";
                    aviso = _aviso;
                    tempo = _aviso;
                }
            }
        }
    }
};

disparar_golpe = disparar;
disparar = function() {
    if (ataque.forma == "circulo") {
        // a magia cai do alto: a coluna nao protege
        zona.ox = zona.cx;
        zona.oy = zona.cy;
        som(snd_magia);
    } else {
        audio_play_sound(snd_attack, 1, false, 1, 0, 0.6);
    }
    disparar_golpe();
};
