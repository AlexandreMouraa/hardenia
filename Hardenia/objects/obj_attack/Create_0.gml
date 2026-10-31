lifetime = 8;
damage = 1;
knockback = 12;
forte = false; // terceiro golpe do combo (obj_player, golpear)
especial = false; // giro: acerta todos em volta de uma vez (obj_player, girar)
quebra_escudo = false; // golpe carregado, especial e estocada quebram o escudo da elite
visible = false;

// tira vida de um inimigo, com efeito e empurrao
acertar = function(_enemy) {
    // apanhar acorda ele e os vizinhos, mesmo sem ter visto o jogador
    with (_enemy) {
        acordar();
    }
    // escudo da elite: o golpe comum so faz barulho. Quem tem o golpe certo quebra e ja tira vida
    if (_enemy.escudo) {
        var _dir_escudo = instance_exists(obj_player) ? point_direction(obj_player.x, obj_player.y, _enemy.x, _enemy.y) : 0;
        som(snd_escudo, quebra_escudo ? 1.2 : 0.8);
        if (!quebra_escudo) {
            impacto(1, 1);
            fx_faiscas(_enemy.x, _enemy.y, _dir_escudo, make_colour_rgb(120, 220, 255), 4);
            return;
        }
        _enemy.escudo = false;
        impacto(4, 4);
        fx_faiscas(_enemy.x, _enemy.y, _dir_escudo, make_colour_rgb(120, 220, 255), 12);
    }
    _enemy.hp -= damage;
    _enemy.hit_flash = 8;
    var _dir_golpe = instance_exists(obj_player) ? point_direction(obj_player.x, obj_player.y, _enemy.x, _enemy.y) : 0;
    som(_enemy.hp <= 0 ? snd_morte_inimigo : snd_acerto);
    if (_enemy.hp <= 0) {
        if (_enemy.elite == "explosao") {
            instance_create_layer(_enemy.x, _enemy.y, "Instances", obj_explosao);
        }
        // golpe que mata: pausa e tremor maiores, faiscas vermelhas. Inimigo de horda
        // morre sem isso: a cada golpe morrem varios, e o jogo ficaria parando
        if (!_enemy.leve) {
            impacto(forte ? 6 : 5, forte ? 8 : 6);
            fx_faiscas(_enemy.x, _enemy.y, _dir_golpe, c_red, 9);
        }
        with (instance_create_layer(_enemy.x, _enemy.y, "Instances", obj_fx_morte)) {
            sprite_index = _enemy.sprite_index;
            image_index = _enemy.image_index;
        }
        instance_destroy(_enemy);
    } else if (instance_exists(obj_player)) {
        // quem nao se move leva o golpe, mas nao e empurrado
        var _kb = _enemy.imovel ? 0 : knockback;
        if (forte) {
            impacto(4, 4);
            fx_faiscas(_enemy.x, _enemy.y, _dir_golpe, make_colour_rgb(255, 200, 120), 8);
        } else {
            impacto(2, 2);
            fx_faiscas(_enemy.x, _enemy.y, _dir_golpe, c_white, 5);
        }
        if (forte) {
            // terceiro golpe: o inimigo desliza para longe e freia (obj_enemy,
            // Step); 0.35 da distancia no primeiro frame, perdendo 35% a cada um
            _enemy.empurrao_x = lengthdir_x(_kb * 0.35, _dir_golpe);
            _enemy.empurrao_y = lengthdir_y(_kb * 0.35, _dir_golpe);
        } else {
            // golpe comum: o empurrao curto de sempre, na hora. Deslizando, o
            // inimigo ficava na beira do alcance e quase nunca atacava (o robo
            // mostrou: 0 golpes de inimigo em 3 runs, contra 10 assim)
            var _kx = lengthdir_x(_kb, _dir_golpe);
            var _ky = lengthdir_y(_kb, _dir_golpe);
            with (_enemy) {
                if (!place_meeting(x + _kx, y, obj_wall)) {
                    x += _kx;
                }
                if (!place_meeting(x, y + _ky, obj_wall)) {
                    y += _ky;
                }
            }
        }
    }
};
