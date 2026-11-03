if (global.game_paused || global.hitstop > 0) {
    exit;
}

if (hit_flash > 0) {
    hit_flash -= 1;
}
if (alerta > 0) {
    alerta -= 1;
}

// empurrao do terceiro golpe: de 1 em 1 px para encostar na parede sem atravessar
if (abs(empurrao_x) + abs(empurrao_y) > 0.1) {
    var _passos = ceil(max(abs(empurrao_x), abs(empurrao_y)));
    var _ex = empurrao_x / _passos;
    var _ey = empurrao_y / _passos;
    repeat (_passos) {
        if (!place_meeting(x + _ex, y, obj_wall)) {
            x += _ex;
        }
        if (!place_meeting(x, y + _ey, obj_wall)) {
            y += _ey;
        }
    }
    empurrao_x *= 0.65;
    empurrao_y *= 0.65;
} else {
    empurrao_x = 0;
    empurrao_y = 0;
}

// a zona acompanha o inimigo empurrado durante o aviso; depois do golpe, fica onde caiu
if (state == 1 && !zona_fixa) {
    zona_posicionar(zona, x, y);
}

var _is_moving = false;

switch (state) {
	case 0: // sem atacar: patrulha, procura ou cerca
    if (instance_exists(obj_player)) {
        visao_timer -= 1;
        if (visao_timer <= 0) {
            visao_timer = 6;
            vendo = inimigo_ve_jogador();
            if (vendo) {
                memoria_x = obj_player.x;
                memoria_y = obj_player.y;
                procura = procura_max;
                campo_ver(obj_player.x, obj_player.y);
                if (!acordado) {
                    acordar();
                }
            }
        }
        var _dist = point_distance(x, y, obj_player.x, obj_player.y);
        var _dir = point_direction(x, y, obj_player.x, obj_player.y);
        image_blend = c_white;

        if (acordado && vendo) {
            if (elite == "invocacao") {
                invocar_passo();
            }
            // com parede no meio nao ataca: o golpe nao passaria. Sem a vez, espera
            if (_dist <= ataque.gatilho && collision_line(x, y, obj_player.x, obj_player.y, obj_wall, false, true) == noone && vez_pegar()) {
                state = 1;
                state_timer = ataque.aviso;
                // a direcao trava no inicio do aviso: o jogador ve onde o golpe cai e tem tempo de sair
                attack_dir = _dir;
                if (ao_mirar != undefined) {
                    ao_mirar();
                }
                zona = zona_criar(ataque, x, y, attack_dir);
                inimigo_virar(attack_dir);
            } else {
                cerco_timer -= 1;
                if (cerco_timer <= 0) {
                    cerco_timer = 90;
                    cerco_escolher();
                }
                // vai para o seu lado do jogador. Com a vez livre, chega ao alcance do
                // golpe; sem ela, ronda um pouco mais longe, balancando de um lado para o outro
                ronda += 1;
                var _raio = vez_livre() ? ataque.gatilho * 0.85 : ataque.gatilho + 45;
                var _ang = cerco_ang + 12 * sin(ronda * 0.03);
                var _tx = obj_player.x + lengthdir_x(_raio, _ang);
                var _ty = obj_player.y + lengthdir_y(_raio, _ang);
                if (point_distance(x, y, _tx, _ty) > move_speed) {
                    inimigo_andar(point_direction(x, y, _tx, _ty), move_speed);
                    _is_moving = true;
                }
                inimigo_virar(_dir);
            }
        } else if (acordado) {
            procura -= 1;
            if (procura <= 0 || point_distance(x, y, memoria_x, memoria_y) < 8) {
                acordado = false;
                casa_passo = -1;
            } else {
                var _dir_memoria = point_direction(x, y, memoria_x, memoria_y);
                // parede no meio: segue o mapa, que leva ao ultimo lugar onde alguem do
                // grupo viu o jogador. Os 4 s de memoria nao bastam para um caminho longo:
                // ganha o tempo de andar ate la, e enquanto alguem ainda ve, ele nao desiste
                if (collision_line(x, y, memoria_x, memoria_y, obj_wall, false, true) != noone) {
                    var _rumo = campo_rumo();
                    if (_rumo >= 0) {
                        _dir_memoria = _rumo;
                        memoria_x = global.campo.alvo_x;
                        memoria_y = global.campo.alvo_y;
                        if (global.campo.visto_em > campo_visto) {
                            campo_visto = global.campo.visto_em;
                            procura = procura_max;
                        }
                        procura = max(procura, ceil(campo_passos * CAMPO_CELULA / move_speed) + 30);
                    }
                }
                inimigo_andar(_dir_memoria, move_speed);
                inimigo_virar(_dir_memoria);
                _is_moving = true;
            }
        } else if (abs(y - home_y) > 4 || abs(x - home_x) > patrol_range + 4) {
            // de volta para casa, antes de patrulhar de novo
            var _dir_casa = casa_rumo();
            inimigo_andar(_dir_casa, patrol_speed);
            inimigo_virar(_dir_casa);
            _is_moving = true;
        } else {
            var _patrol_move = patrol_dir * patrol_speed;
            if (!place_meeting(x + _patrol_move, y, obj_wall)) {
                x += _patrol_move;
            } else {
                patrol_dir *= -1;
            }
            if (x >= home_x + patrol_range) {
                patrol_dir = -1;
            }
            if (x <= home_x - patrol_range) {
                patrol_dir = 1;
            }
            _is_moving = true;
            facing_dir = (patrol_dir < 0) ? 1 : 2;
        }
    }
    break;

    case 1: // aviso (telegraph)
        state_timer -= 1;
        if (state_timer <= 0) {
            state = 2;
            state_timer = ataque.duracao;
            disparar();
        }
        break;

    case 2: // atacando
        // bote: anda reto enquanto o golpe acerta; a parede para o bote
        if (ataque.avanco > 0 && ataque.duracao - state_timer < ataque.acerto) {
            var _bx = lengthdir_x(ataque.avanco, attack_dir);
            var _by = lengthdir_y(ataque.avanco, attack_dir);
            if (!place_meeting(x + _bx, y + _by, obj_wall)) {
                with (instance_create_depth(x, y, depth + 1, obj_fx)) {
                    tipo = "rastro";
                    sprite_index = other.sprite_index;
                    image_index = other.image_index;
                    cor = make_colour_rgb(200, 30, 40);
                    vida_max = 12;
                    vida = vida_max;
                }
                x += _bx;
                y += _by;
            }
        }
        state_timer -= 1;
        if (state_timer <= 0) {
            state = 3;
            state_timer = ataque.recarga;
        }
        break;

    case 3: // cooldown
        // apagado: a hora de bater nele
        image_blend = c_gray;
        if (depois_golpe != "parado" && instance_exists(obj_player)) {
            var _de_frente = point_direction(x, y, obj_player.x, obj_player.y);
            inimigo_andar(_de_frente + (depois_golpe == "recua" ? 180 : 90), 1);
            inimigo_virar(_de_frente);
            _is_moving = true;
        }
        state_timer -= 1;
        if (state_timer <= 0) {
            state = 0;
            if (ao_voltar != undefined) {
                ao_voltar();
            }
        }
        break;
}

// inimigos encostados se afastam devagar, para nao virarem um bolo so; fora do
// ataque, senao a zona do golpe andaria durante o aviso
if (state == 0 || state == 3) {
    var _outro = instance_place(x, y, obj_enemy);
    if (_outro != noone) {
        var _afasta = (_outro.x == x && _outro.y == y) ? random(360) : point_direction(_outro.x, _outro.y, x, y);
        var _ox = lengthdir_x(1, _afasta);
        var _oy = lengthdir_y(1, _afasta);
        if (!place_meeting(x + _ox, y, obj_wall)) {
            x += _ox;
        }
        if (!place_meeting(x, y + _oy, obj_wall)) {
            y += _oy;
        }
    }
}

if (_is_moving) {
    anim_timer += 1;
    if (anim_timer >= anim_speed) {
        anim_timer = 0;
        anim_frame = (anim_frame + 1) mod walk_frames;
    }
} else {
    anim_timer = 0;
    anim_frame = 0;
}

if ((state == 1 || state == 2) && ataque_sprite != noone) {
    // a pose avanca durante o aviso e termina no golpe
    sprite_index = ataque_sprite;
    var _quadro = ataque_frames - 1;
    var _no_golpe = (ataque_solta >= 0) ? ataque_solta : ataque_frames - 1;
    if (state == 1) {
        _quadro = floor((1 - state_timer / ataque.aviso) * _no_golpe);
    } else if (ataque_solta >= 0) {
        // o resto da folha logo depois do golpe, sem o ultimo quadro (ja volta a pegar flecha)
        _quadro = min(ataque_frames - 2, ataque_solta + (ataque.duracao - state_timer) div 4);
    }
    image_index = facing_dir * ataque_frames + _quadro;
} else {
    sprite_index = walk_sprite;
    image_index = facing_dir * walk_frames + anim_frame;
}
