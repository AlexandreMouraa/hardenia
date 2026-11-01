lifetime = 8;
damage = 1;
knockback = 12;
forte = false; // terceiro golpe do combo (obj_player, golpear)
especial = false; // giro: acerta todos em volta de uma vez (obj_player, girar)
visible = false;

// tira vida de um inimigo, com efeito e empurrao
acertar = function(_enemy) {
    _enemy.hp -= damage;
    _enemy.hit_flash = 8;
    // apanhar acorda ele e os vizinhos, mesmo sem ter visto o jogador
    with (_enemy) {
        acordar();
    }
    var _dir_golpe = instance_exists(obj_player) ? point_direction(obj_player.x, obj_player.y, _enemy.x, _enemy.y) : 0;
    som(_enemy.hp <= 0 ? snd_morte_inimigo : snd_acerto);
    if (_enemy.hp <= 0) {
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
            _enemy.empurrao_x = lengthdir_x(knockback * 0.35, _dir_golpe);
            _enemy.empurrao_y = lengthdir_y(knockback * 0.35, _dir_golpe);
        } else {
            // golpe comum: o empurrao curto de sempre, na hora. Deslizando, o
            // inimigo ficava na beira do alcance e quase nunca atacava (o robo
            // mostrou: 0 golpes de inimigo em 3 runs, contra 10 assim)
            var _kx = lengthdir_x(knockback, _dir_golpe);
            var _ky = lengthdir_y(knockback, _dir_golpe);
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
