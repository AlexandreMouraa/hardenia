// Um alvo ferido por conjuracao. Nao ressuscita nem cura chefes, horda ou outros curandeiros.
function cura_alvo_valido(_curador, _alvo) {
    if (!instance_exists(_alvo) || _alvo == _curador) return false;
    if (_alvo.hp <= 0 || _alvo.imovel || _alvo.leve
        || _alvo.object_index == obj_enemy_curandeiro) return false;
    return _alvo.hp < _alvo.vida_maxima_cura
        && point_distance(_curador.x, _curador.y, _alvo.x, _alvo.y) <= _curador.cura_raio
        && collision_line(_curador.x, _curador.y, _alvo.x, _alvo.y, obj_wall, false, true) == noone;
}

function cura_escolher(_curador) {
    var _melhor = noone;
    var _menor = 1;
    with (obj_enemy) {
        if (cura_alvo_valido(_curador, id)) {
            var _proporcao = hp / vida_maxima_cura;
            if (_proporcao < _menor) {
                _menor = _proporcao;
                _melhor = id;
            }
        }
    }
    return _melhor;
}

function cura_interromper(_curador) {
    if (!_curador.cura_conjurando) return;
    _curador.cura_conjurando = false;
    _curador.cura_alvo = noone;
    // Dois segundos ate tentar de novo: recompensam a interrupcao sem travar o suporte.
    _curador.cura_recarga = 120;
    _curador.cura_interrompida = 30;
    fx_faiscas(_curador.x, _curador.y - 16, 90, make_colour_rgb(170, 235, 205), 5);
    if (instance_exists(obj_autotest)) obj_autotest.log("cura_interrompida", "golpe ou alvo perdido");
}

function cura_concluir(_curador) {
    var _alvo = _curador.cura_alvo;
    if (!cura_alvo_valido(_curador, _alvo)) {
        cura_interromper(_curador);
        return 0;
    }
    var _antes = _alvo.hp;
    _alvo.hp = min(_alvo.vida_maxima_cura, _alvo.hp + _curador.cura_quantidade);
    var _ganho = _alvo.hp - _antes;
    _curador.cura_conjurando = false;
    _curador.cura_alvo = noone;
    _curador.cura_recarga = _curador.cura_recarga_max;
    _curador.cura_pulso = 24;
    var _cor = make_colour_rgb(120, 235, 176);
    fx_onda(_alvo.x, _alvo.y, 48, _cor);
    fx_onda(_curador.x, _curador.y, 34, _cor);
    fx_numero(_alvo.x, _alvo.bbox_top, round(_ganho * 10), _cor);
    sfx(snd_confirm, 1, false, 0.55);
    if (instance_exists(obj_autotest)) obj_autotest.log("cura_inimiga", "vida=" + string(_ganho));
    return _ganho;
}

// Metodo do curandeiro: chamado pelo Step do pai depois dos danos continuos e do empurrao.
function curandeiro_passo() {
    if (!instance_exists(obj_player) || obj_player.is_dead || obj_player.venceu
        || instance_exists(obj_mapa) || instance_exists(obj_tecnicas)
        || instance_exists(obj_arvore) || instance_exists(obj_cena)) return;
    cura_interrompida = max(0, cura_interrompida - 1);
    cura_pulso = max(0, cura_pulso - 1);
    cura_recarga = max(0, cura_recarga - 1);
    var _andou = false;
    var _dir = point_direction(x, y, obj_player.x, obj_player.y);
    if (point_distance(x, y, obj_player.x, obj_player.y) <= visao
        && collision_line(x, y, obj_player.x, obj_player.y, obj_wall, false, true) == noone) {
        if (!acordado) acordar();
    }
    if (cura_conjurando) {
        if (!cura_alvo_valido(id, cura_alvo)) {
            cura_interromper(id);
        } else {
            cura_tempo -= 1;
            inimigo_virar(point_direction(x, y, cura_alvo.x, cura_alvo.y));
            if (cura_tempo <= 0) cura_concluir(id);
        }
    } else if (acordado) {
        if (cura_recarga <= 0) {
            cura_alvo = cura_escolher(id);
            if (cura_alvo != noone) {
                cura_conjurando = true;
                cura_tempo = cura_aviso;
                sfx(snd_arco_tensao, 1, false, 0.35);
            }
        }
        if (!cura_conjurando) {
            var _dist = point_distance(x, y, obj_player.x, obj_player.y);
            // Recuo curto; sozinho se aproxima para nao obrigar o jogador a persegui-lo sem fim.
            var _aliado = cura_escolher(id);
            if (_aliado != noone && _dist < 130) {
                inimigo_andar(_dir + 180, move_speed);
                _andou = true;
            } else if (collision_line(x, y, obj_player.x, obj_player.y, obj_wall, false, true) != noone) {
                var _rumo = campo_rumo();
                if (_rumo >= 0) {
                    inimigo_andar(_rumo, move_speed);
                    _andou = true;
                }
            } else if (_dist > 200 || (_aliado == noone && _dist > 90)) {
                inimigo_andar(_dir, move_speed);
                _andou = true;
            }
            inimigo_virar(_dir);
        }
    }
    if (cura_conjurando) {
        sprite_index = spr_conjurador_magia;
        image_index = facing_dir * 7 + min(6, floor((1 - cura_tempo / cura_aviso) * 7));
    } else {
        sprite_index = walk_sprite;
        anim_timer = _andou ? anim_timer + 1 : 0;
        if (anim_timer >= anim_speed) {
            anim_timer = 0;
            anim_frame = (anim_frame + 1) mod walk_frames;
        }
        image_index = facing_dir * walk_frames + (_andou ? anim_frame : 0);
    }
    image_blend = make_colour_rgb(155, 235, 188);
}
