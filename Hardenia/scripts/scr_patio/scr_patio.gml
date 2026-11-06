// Interacoes do Patio. Sem sorteio: efeitos e perigos repetem a mesma simulacao.
function defensor_interceptar(_e, _ox, _oy, _quebra) {
    if (!_e.defensor || _e.state == 3 || _e.guarda_quebrada > 0) return false;
    var _lado = point_direction(_e.x, _e.y, _ox, _oy);
    if (abs(angle_difference(_e.guarda_dir, _lado)) > 65) return false;
    _e.guarda_flash = 10;
    sfx(snd_escudo, 1, false, 0.8);
    fx_faiscas(_e.x, _e.y, _lado, make_colour_rgb(160, 220, 240), 5);
    // Carregado, estocada, giro e cenario abrem a guarda por um segundo.
    if (_quebra) _e.guarda_quebrada = 60;
    return !_quebra;
}

function patio_parado() {
    return global.game_paused || global.hitstop > 0 || !instance_exists(obj_player)
        || obj_player.is_dead || obj_player.venceu || instance_exists(obj_mapa)
        || instance_exists(obj_tecnicas) || instance_exists(obj_arvore) || instance_exists(obj_cena);
}

function patio_acender(_p) {
    if (_p.tipo == "barril" && _p.estado == 0) {
        _p.estado = 1;
        _p.tempo = _p.aviso;
        sfx(snd_arco_tensao, 1, false, 0.5);
        return true;
    }
    return false;
}

// A espada usa sua mascara real; um barril nao pode ser acionado atraves da parede.
function patio_golpe(_g) {
    var _n = 0;
    with (obj_perigo_patio) {
        if (tipo == "barril" && estado == 0
            && rectangle_in_rectangle(x - 14, y - 20, x + 14, y + 12,
                _g.bbox_left, _g.bbox_top, _g.bbox_right, _g.bbox_bottom) != 0
            && collision_line(obj_player.x, obj_player.y, x, y, obj_wall, false, true) == noone) {
            patio_acender(id);
            _n += 1;
        }
    }
    return _n;
}

function patio_raio(_x, _y, _raio) {
    with (obj_perigo_patio) {
        if (point_distance(_x, _y, x, y) <= _raio
            && collision_line(_x, _y, x, y, obj_wall, false, true) == noone) {
            patio_acender(id);
        }
    }
}

function patio_zona(_z) {
    with (obj_perigo_patio) {
        if (tipo == "barril" && estado == 0
            && zona_toca_retangulo(_z, x - 14, y - 20, x + 14, y + 12)
            && collision_line(_z.ox, _z.oy, x, y, obj_wall, false, true) == noone) {
            patio_acender(id);
        }
    }
}

function patio_segmento(_x, _y, _px, _py) {
    var _atingiu = false;
    with (obj_perigo_patio) {
        if (tipo == "barril" && estado == 0
            && segmento_toca_retangulo(_x, _y, _px, _py, x - 14, y - 20, x + 14, y + 12)
            && collision_line(_x, _y, x, y, obj_wall, false, true) == noone) {
            patio_acender(id);
            _atingiu = true;
        }
    }
    return _atingiu;
}

// Dano neutro: nao aplica tecnicas do jogador. Colunas protegem dos dois lados.
function patio_atingir(_perigo) {
    var _lista = ds_list_create();
    var _n = collision_circle_list(_perigo.x, _perigo.y, _perigo.raio, obj_enemy, false, true, _lista, false);
    for (var _i = 0; _i < _n; _i++) {
        var _e = _lista[| _i];
        if (instance_exists(_e) && collision_line(_perigo.x, _perigo.y, _e.x, _e.y, obj_wall, false, true) == noone) {
            golpe_acertar(_e, _perigo.dano, 0, false, true, _perigo.x, _perigo.y, true);
        }
    }
    ds_list_destroy(_lista);
    var _p = instance_find(obj_player, 0);
    if (_p != noone && !_p.is_dead && !_p.venceu && !_p.is_dashing && _p.invuln_timer <= 0
        && zona_acerta_jogador(_perigo.zona)) {
        _p.morto_por = "obj_perigo_patio";
        _p.levar_dano(1);
    }
    patio_raio(_perigo.x, _perigo.y, _perigo.raio);
}
