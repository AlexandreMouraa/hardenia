// Begin Step: roda antes do Step do jogador, entao o que o robo decide aqui
// vale neste mesmo frame.
if (encerrando) {
    exit;
}

frame += 1;
bot_h = 0;
bot_v = 0;
bot_dash = false;
bot_enter = false;
bot_clique = false;
bot_especial = false;
segurar_frames = max(0, segurar_frames - 1);
bot_segurar = (segurar_frames > 0);

// trava de seguranca: 40 min de jogo
if (frame > 60 * 60 * 40) {
    log("FALHA_limite_de_tempo", "");
    encerrar(1);
    exit;
}

// mapa da proxima fase (obj_mapa): passa sozinho; print na primeira run
if (instance_exists(obj_mapa)) {
    if (run_atual <= 1 && obj_mapa.tempo == 90) {
        pedir_print("mapa");
    }
    exit;
}

if (room == Room_Menu) {
    espera += 1;
    if (espera == 20 && run_atual == 0) {
        pedir_print("menu");
    }
    if (espera == 40) {
        if (runs_feitas >= runs_total) {
            if (morrer && curas == 0) {
                log("FALHA_vida", "-morrer nao viu a cura");
            }
            log("resumo", "runs=" + string(runs_feitas) + " vitorias=" + string(vitorias) + " mortes=" + string(mortes_total) + " golpes_inimigos=" + string(golpes) + " danos=" + string(danos) + " avisos_max=" + string(avisos_max) + " combos=" + string(combos) + (carregar ? " carregados=" + string(carregados) : "") + (usar_especial ? " especiais=" + string(especiais) : "") + (usar_estocada ? " estocadas=" + string(estocadas) : "") + (testar_formas ? " formas=" + string(variable_struct_names_count(formas_vistas)) : "") + (testar_grupo ? " grupo=" + string(grupo_ok) : ""));
            encerrar(0);
            exit;
        }
        run_atual += 1;
        log("run_inicio", "");
        with (obj_menu) {
            if (other.usar_horda) {
                horda_iniciar();
            } else {
                event_perform(ev_keypress, vk_enter);
            }
        }
    }
    exit;
}

if (!instance_exists(obj_player)) {
    exit;
}

var _p = instance_find(obj_player, 0);
tempo_sala += 1;

// ---------- eventos para o log ----------
if (_p.hp < vida_antes) {
    danos += vida_antes - _p.hp;
    log("dano", "hp=" + string(_p.hp));
    if (danos == 1) {
        pedir_print("dano");
    }
} else if (_p.hp > vida_antes) {
    curas += 1;
    log("cura", "hp=" + string(_p.hp));
}
vida_antes = _p.hp;

// -horda: a medida roda parada, e a 60 fps de verdade. Depois de vencer as ondas
if (usar_horda && room == Room_Horda) {
    var _h = instance_find(obj_horda, 0);
    if (_p.hp < _p.hp_max) {
        _p.hp = _p.hp_max;
        global.vida = _p.hp;
        vida_antes = _p.hp;
    }
    if (_h.medida_fim) {
        log("horda_limite", "inimigos=" + string(_h.medida_limite));
        game_set_speed(velocidade, gamespeed_fps);
        vitorias += 1;
        terminar_run("horda");
        exit;
    }
    if (_h.medindo) {
        if (_h.tempo mod 60 == 59) {
            log("horda_fps", "vivos=" + string(instance_number(obj_enemy_horda)) + " fps=" + string(fps) + " fps_real=" + string(round(fps_real)));
        }
        if (_h.tempo == 1200 || _h.tempo == 3600) {
            pedir_print("horda_medindo");
        }
        exit;
    }
    if (_h.fim) {
        log("horda_vencida", "combos=" + string(combos) + " danos=" + string(danos));
        pedir_print("horda_vencida");
        game_set_speed(60, gamespeed_fps);
        with (_h) {
            medir();
        }
        exit;
    }
    if (_h.onda >= 0 && tempo_sala mod 240 == 0) {
        pedir_print("horda_onda");
    }
}

var _n = instance_number(obj_enemy);
if (_n < inimigos_antes) {
    log("inimigo_morto", "restam=" + string(_n));
    if (run_atual == 1 && !viu_fx_morte) {
        viu_fx_morte = true;
        pedir_print("fx_morte");
    }
}
inimigos_antes = _n;

if (_n == 0 && !sala_limpa_logada) {
    sala_limpa_logada = true;
    limpa_desde = tempo_sala;
    log("sala_limpa", "segundos=" + string(round(tempo_sala / 60)));
    if (run_atual == 1) {
        pedir_print("sala_limpa");
    }
}
// um pouco depois de limpar: seta para o portao, se ele estiver fora da tela
if (run_atual == 1 && sala_limpa_logada && tempo_sala == limpa_desde + 45) {
    pedir_print("indo_ao_portao");
}

if (run_atual == 1 && tempo_sala == 30) {
    pedir_print("inicio");
}
if (run_atual == 1 && dash_prints == 0 && _p.is_dashing && _p.dash_timer == 5) {
    dash_prints = 1;
    pedir_print("dash_meio");
} else if (run_atual == 1 && dash_prints == 1 && !_p.is_dashing) {
    dash_prints = 2;
    pedir_print("dash_fim");
}
// combos completos: conta quando o terceiro golpe comeca
var _forte_agora = _p.is_attacking && _p.golpe_atual == 3;
if (_forte_agora && !forte_antes) {
    if (_p.golpe_carregado) {
        carregados += 1;
    } else {
        combos += 1;
    }
}
forte_antes = _forte_agora;
if (run_atual == 1 && !viu_carga && _p.carga >= _p.carga_max) {
    viu_carga = true;
    pedir_print("carga_cheia");
}
// -estocar: o ataque depois do dash
if (estocar_em > 0) {
    estocar_em -= 1;
    if (estocar_em == 0) {
        if (usar_mouse) {
            bot_clique = true;
        } else {
            with (_p) {
                event_perform(ev_keypress, ord("J"));
            }
        }
    }
}
var _estocada_agora = _p.is_attacking && _p.golpe_estocada;
if (_estocada_agora && !estocada_antes) {
    estocadas += 1;
}
estocada_antes = _estocada_agora;
if (run_atual == 1 && !viu_estocada && _estocada_agora && _p.attack_anim_timer == 8) {
    viu_estocada = true;
    pedir_print("estocada");
}
// -especial, uma vez: cerca o jogador com os inimigos da sala e gira. Sozinho o
// robo quase nunca fica cercado, e o log precisa mostrar um giro acertando varios
if (usar_especial && run_atual == 1 && !cercou && tempo_sala == 60) {
    cercou = true;
    var _k = 0;
    with (obj_enemy) {
        var _cx = _p.x + lengthdir_x(50, _k * 90);
        var _cy = _p.y + lengthdir_y(50, _k * 90);
        if (!place_meeting(_cx, _cy, obj_wall)) {
            x = _cx;
            y = _cy;
        }
        _k += 1;
    }
    bot_especial = true;
}
// giro: 3 frames depois de sair, o obj_attack ja contou os acertos
if (_p.especial_recarga == _p.especial_recarga_max - 3 && !especial_logado) {
    especial_logado = true;
    especiais += 1;
    log("especial", "acertos=" + string(_p.especial_acertos));
    if (run_atual == 1 && !viu_especial) {
        viu_especial = true;
        pedir_print("especial");
    }
} else if (_p.especial_recarga < _p.especial_recarga_max - 3) {
    especial_logado = false;
}
// terceiro golpe do combo, com o arco largo no meio da varrida
if (run_atual == 1 && !viu_combo && _p.is_attacking && _p.golpe_atual == 3 && _p.attack_anim_timer == 9) {
    viu_combo = true;
    pedir_print("combo_3");
}

if (_p.is_dead) {
    if (!estava_morto) {
        estava_morto = true;
        mortes_total += 1;
        mortes_run += 1;
        mortes_sala += 1;
        variable_struct_set(salas_morreu, room_get_name(room), true);
        var _perto = instance_nearest(_p.x, _p.y, obj_enemy);
        var _quem = "?";
        if (_perto != noone) {
            _quem = object_get_name(_perto.object_index) + " a " + string(round(point_distance(_p.x, _p.y, _perto.x, _perto.y))) + "px";
        }
        log("morte", "x=" + string(round(_p.x)) + " y=" + string(round(_p.y)) + " perto=" + _quem + " mortes_na_sala=" + string(mortes_sala) + " frase=" + _p.frase_morte);
        if (mortes_total <= 6) {
            pedir_print("morte");
        }
        if (mortes_run >= 25) {
            log("FALHA_desistiu", "25 mortes na mesma run");
            terminar_run("desistiu");
        }
    }
    exit;
}
estava_morto = false;

if (_p.venceu) {
    espera += 1;
    if (espera == 30) {
        vitorias += 1;
        log("vitoria", "tentativas=" + string(global.tentativas));
        if (vitorias <= 2) {
            pedir_print("vitoria");
        }
    }
    // com rede (-api) a vitoria pede nome: digita antes do primeiro Enter
    if (espera == 40 && _p.vitoria_estado == "nome") {
        keyboard_string = nome_robo;
    }
    if (espera == 60) {
        runs_feitas += 1;
        log("run_fim", "vitoria tentativas=" + string(global.tentativas));
        bot_enter = true;
    }
    // ranking: Enter de novo a cada segundo ate voltar ao menu (espera a resposta)
    if (espera > 60 && espera mod 60 == 0) {
        log("ranking", _p.vitoria_estado + " posicao=" + string(_p.vitoria_posicao) + "/" + string(_p.vitoria_total) + " top=" + string(array_length(_p.vitoria_ranking)));
        if (espera == 120 && vitorias <= 2) {
            pedir_print("vitoria_ranking");
        }
        if (espera >= 180) {
            bot_enter = true;
        }
    }
    exit;
}

if (tempo_sala > 60 * 150 && room != Room_Horda) {
    log("FALHA_timeout_sala", "150s sem sair da sala");
    pedir_print("timeout");
    terminar_run("timeout");
    exit;
}

// pausa: abre, tira print e fecha, uma vez na primeira sala
if (!testou_pausa && room == Room1 && tempo_sala >= 90) {
    if (tempo_sala == 90 || tempo_sala == 120) {
        with (_p) {
            event_perform(ev_keypress, vk_escape);
        }
    }
    if (tempo_sala == 105) {
        if (!global.game_paused) {
            log("FALHA_pausa", "Esc nao pausou");
        }
        pedir_print("pausa");
    }
    if (tempo_sala == 125) {
        testou_pausa = true;
        if (global.game_paused) {
            log("FALHA_pausa", "Esc nao saiu da pausa");
        }
    }
    exit;
}

// -grupo: parado na primeira sala enquanto confere o comportamento em grupo
var _esperando_grupo = false;
if (testar_grupo && run_atual == 1 && room == Room1 && grupo_passo < 4) {
    _esperando_grupo = true;
    grupo_conferir(_p);
}

// ---------- zonas de golpe ativas ----------
var _quer_morrer = morrer && run_atual == 1 && !variable_struct_exists(salas_morreu, room_get_name(room));
// -morrer, segunda run: apanha ate ficar com 3 de vida, sem morrer, para o log mostrar
// a vida passando de uma sala para a outra e a cura de limpar a fase
if ((morrer && run_atual == 2 && _p.hp > 3) || _esperando_grupo) {
    _quer_morrer = true;
}
var _zonas = [];
var _em_aviso = 0;
with (obj_enemy) {
    if (state == 1) {
        _em_aviso += 1;
    }
    if (state == 1 || state == 2) {
        // golpe saiu agora (o inimigo entrou no estado 2 no frame anterior)
        if (state == 2 && state_timer == ataque.duracao) {
            other.golpes += 1;
            other.log("golpe_inimigo", object_get_name(object_index) + " forma=" + zona.forma + " dentro=" + string(other.zona_toca(zona, _p.x, _p.y, 0)) + " dash=" + string(_p.is_dashing));
        }
        // -formas: um print de cada forma no aviso e outro logo depois do golpe
        if (other.testar_formas) {
            var _foto = "";
            if (state == 1 && state_timer == 20) {
                _foto = "aviso_" + zona.forma;
            } else if (state == 2 && state_timer == ataque.duracao - 2) {
                _foto = "golpe_" + zona.forma;
            }
            if (_foto != "" && other.print_pendente == "" && !variable_struct_exists(other.formas_vistas, _foto)) {
                variable_struct_set(other.formas_vistas, _foto, true);
                other.pedir_print(_foto);
            }
        }
        // primeira run: um print do aviso e outro do golpe de cada tipo de inimigo
        if (other.run_atual == 1) {
            var _tipo = "";
            if (state == 1 && state_timer == 20) {
                _tipo = "aviso_" + object_get_name(object_index);
            } else if (state == 2 && state_timer == ataque.duracao - 5) {
                _tipo = "golpe_" + object_get_name(object_index);
            }
            if (_tipo != "" && other.print_pendente == "" && !variable_struct_exists(other.tipos_vistos, _tipo)) {
                variable_struct_set(other.tipos_vistos, _tipo, true);
                other.pedir_print(_tipo);
            }
        }
        // cada aviso novo sorteia se o robo percebe ou nao (-desatento)
        var _k = string(id);
        if (!variable_struct_exists(other.percebeu, _k) || (state == 1 && state_timer == ataque.aviso)) {
            variable_struct_set(other.percebeu, _k, random(100) >= other.desatento);
        }
        if (variable_struct_get(other.percebeu, _k) && !_quer_morrer) {
            array_push(_zonas, [zona, state, state_timer]);
        }
    }
}
// a vez de atacar (scr_inimigos): no maximo 2 em aviso ao mesmo tempo
avisos_max = max(avisos_max, _em_aviso);
if (_em_aviso > 2) {
    log("FALHA_vez", string(_em_aviso) + " avisos ao mesmo tempo");
}
if (!ja_viu_aviso && array_length(_zonas) > 0 && run_atual == 1) {
    ja_viu_aviso = true;
    pedir_print("aviso");
}

var _ameacado = false;
var _urgente = false;
var _zona_perto = -1;
var _zona_grande = false;
for (var _i = 0; _i < array_length(_zonas); _i++) {
    if (zona_toca(_zonas[_i][0], _p.x, _p.y, 8)) {
        _ameacado = true;
        _zona_perto = _i;
        _zona_grande = _zona_grande || zona_grande(_zonas[_i][0]);
        if (_zonas[_i][1] == 2 || _zonas[_i][2] <= 6) {
            _urgente = true;
        }
    }
}

// ---------- objetivo: inimigo mais perto, ou o portao adiante ----------
var _alvo = instance_nearest(_p.x, _p.y, obj_enemy);
var _gx = _p.x;
var _gy = _p.y;
if (_alvo != noone) {
    _gx = _alvo.x;
    _gy = _alvo.y;
} else {
    var _s = saida_adiante();
    if (_s != noone) {
        _gx = (_s.bbox_left + _s.bbox_right) / 2;
        _gy = (_s.bbox_top + _s.bbox_bottom) / 2;
    }
}

// parede no meio (ou travou ha pouco): segue o caminho da grade
var _wx = _gx;
var _wy = _gy;
if (forcar_caminho > 0) {
    forcar_caminho -= 1;
}
if (forcar_caminho > 0 || collision_line(_p.x, _p.y, _gx, _gy, obj_wall, false, true) != noone) {
    if (tempo_sala mod 10 == 0 || proximo_x < 0 || point_distance(_p.x, _p.y, proximo_x, proximo_y) < 6) {
        proximo_x = -1;
        if (tem_caminho(_p.x, _p.y, _gx, _gy)) {
            for (var _k = 1; _k < path_get_number(caminho); _k++) {
                var _cx = path_get_point_x(caminho, _k);
                var _cy = path_get_point_y(caminho, _k);
                if (point_distance(_p.x, _p.y, _cx, _cy) > 20 || _k == path_get_number(caminho) - 1) {
                    proximo_x = _cx;
                    proximo_y = _cy;
                    break;
                }
            }
        } else if (!sem_caminho_logado) {
            sem_caminho_logado = true;
            log("ALERTA_sem_caminho", "de " + string(round(_p.x)) + "," + string(round(_p.y)) + " para " + string(round(_gx)) + "," + string(round(_gy)));
        }
    }
    if (proximo_x >= 0) {
        _wx = proximo_x;
        _wy = proximo_y;
    }
} else {
    proximo_x = -1;
}

// ---------- movimento: a direcao mais alinhada com o objetivo, sem parede e
// sem zona de golpe (olhando 1 e 6 frames a frente) ----------
var _dir_alvo = point_direction(_p.x, _p.y, _wx, _wy);
var _perto_do_ponto = point_distance(_p.x, _p.y, _wx, _wy) < 4;
var _mh = 0;
var _mv = 0;
var _melhor = 1000000000;
for (var _dh = -1; _dh <= 1; _dh++) {
    for (var _dv = -1; _dv <= 1; _dv++) {
        var _custo = 0;
        if (_dh == 0 && _dv == 0) {
            _custo = _perto_do_ponto ? 0 : 200;
        } else {
            _custo = abs(angle_difference(point_direction(0, 0, _dh, _dv), _dir_alvo));
            var _bloq_h = false;
            var _bloq_v = false;
            with (_p) {
                _bloq_h = (_dh != 0) && place_meeting(x + _dh * 3, y, obj_wall);
                _bloq_v = (_dv != 0) && place_meeting(x, y + _dv * 3, obj_wall);
            }
            if ((_dh == 0 || _bloq_h) && (_dv == 0 || _bloq_v)) {
                _custo += 5000;
            } else if (_bloq_h || _bloq_v) {
                _custo += 40;
            }
            // inercia: manter a direcao custa menos, inverter custa mais (sem isso
            // o robo fica indo e voltando 3px quando duas opcoes empatam)
            if (_dh == mov_h && _dv == mov_v) {
                _custo -= 15;
            } else if (_dh == -mov_h && _dv == -mov_v) {
                _custo += 25;
            }
        }
        for (var _i = 0; _i < array_length(_zonas); _i++) {
            if (zona_toca(_zonas[_i][0], _p.x + _dh * 3, _p.y + _dv * 3, 4)) {
                _custo += 600;
            }
            if (zona_toca(_zonas[_i][0], _p.x + _dh * 18, _p.y + _dv * 18, 10)) {
                _custo += 1000;
            }
        }
        // dentro de uma zona grande, o caminho mais curto para fora pesa mais que o objetivo
        if (_zona_grande) {
            _custo += 200 * ((_dh == 0 && _dv == 0) ? passos_max + 1 : passos_ate_sair(_zonas, _p.x, _p.y, _dh, _dv));
        }
        if (_custo < _melhor) {
            _melhor = _custo;
            _mh = _dh;
            _mv = _dv;
        }
    }
}

// -morrer: chega perto e espera o golpe, sem atacar
if (_quer_morrer && _alvo != noone && (_esperando_grupo || point_distance(_p.x, _p.y, _alvo.x, _alvo.y) < 36)) {
    _mh = 0;
    _mv = 0;
}

// ---------- ataque: vira para o alvo e bate quando ele esta no alcance ----------
if (_alvo != noone && !_ameacado && !_quer_morrer) {
    var _dx = _alvo.x - _p.x;
    var _dy = _alvo.y - _p.y;
    var _fh = (abs(_dx) > 16) ? sign(_dx) : 0;
    var _fv = (abs(_dy) > 16) ? sign(_dy) : 0;
    if (_fh == 0 && _fv == 0) {
        _fv = 1;
    }
    var _ax = _p.x + _fh * 32;
    var _ay = _p.y + _fv * 32;
    if (usar_mouse) {
        // mesma conta do golpe com mira (obj_player, golpear): alcance de 32
        // nas retas, ate 45 nas diagonais
        var _ang = point_direction(_p.x, _p.y, _alvo.x, _alvo.y);
        var _cx = lengthdir_x(1, _ang);
        var _cy = lengthdir_y(1, _ang);
        var _k = 32 / max(abs(_cx), abs(_cy));
        _ax = _p.x + _cx * _k;
        _ay = _p.y + _cy * _k;
    }
    if (rectangle_in_rectangle(_alvo.bbox_left, _alvo.bbox_top, _alvo.bbox_right, _alvo.bbox_bottom, _ax - 32, _ay - 32, _ax + 32, _ay + 32) > 0) {
        if (usar_mouse || (_p.face_h == _fh && _p.face_v == _fv)) {
            _mh = 0;
            _mv = 0;
            if (_p.attack_cooldown <= 0 && segurar_frames <= 0) {
                // golpe que nao tira vida: alvo do outro lado de uma parede, no
                // limite do alcance (a conta acima tem 1 px a mais que a hitbox
                // real). Depois de 5 seguidos, sai dali como se tivesse travado
                if (_alvo.id == alvo_golpeado && _alvo.hp == hp_golpeado) {
                    golpes_vazios += 1;
                } else {
                    golpes_vazios = 0;
                }
                alvo_golpeado = _alvo.id;
                hp_golpeado = _alvo.hp;
                if (usar_especial && _p.especial_recarga <= 0) {
                    bot_especial = true;
                } else if (usar_estocada && _p.dash_charges > 0) {
                    bot_dash = true;
                    estocar_em = 2;
                } else if (golpes_vazios >= 5) {
                    log("travado", "golpes no vazio x=" + string(round(_p.x)) + " y=" + string(round(_p.y)));
                    golpes_vazios = 0;
                    desvio_frames = 20;
                    desvio_h = choose(-1, 1);
                    desvio_v = choose(-1, 0, 1);
                    forcar_caminho = 120;
                } else if (usar_mouse) {
                    bot_clique = true;
                    bot_mira_x = _alvo.x;
                    bot_mira_y = _alvo.y;
                } else {
                    with (_p) {
                        event_perform(ev_keypress, ord("J"));
                    }
                }
                // animacao (12) + carga (30) + folga para as micro-pausas
                if (carregar) {
                    segurar_frames = 70;
                    bot_segurar = true;
                }
            }
        } else {
            _mh = _fh;
            _mv = _fv;
        }
    }
}

// ---------- dash: o golpe vai cair agora e ainda estou dentro ----------
if (_urgente && _p.dash_charges > 0 && !_p.is_dashing) {
    if (_mh == 0 && _mv == 0) {
        var _fuga = point_direction(_zonas[_zona_perto][0].cx, _zonas[_zona_perto][0].cy, _p.x, _p.y);
        _mh = round(lengthdir_x(1, _fuga));
        _mv = round(lengthdir_y(1, _fuga));
    }
    bot_dash = true;
}

// ---------- travado: quer andar e nao sai do lugar ----------
if (desvio_frames > 0) {
    desvio_frames -= 1;
    _mh = desvio_h;
    _mv = desvio_v;
}
var _travou = false;
if ((_mh != 0 || _mv != 0) && point_distance(_p.x, _p.y, ultimo_x, ultimo_y) < 0.5) {
    quieto += 1;
} else {
    quieto = 0;
}
ultimo_x = _p.x;
ultimo_y = _p.y;
if (quieto >= 45) {
    _travou = true;
}
// vai e volta: andou quase o segundo todo e o deslocamento liquido foi minimo
if (_mh != 0 || _mv != 0) {
    andou_frames += 1;
}
if (tempo_sala mod 60 == 0) {
    if (andou_frames >= 40 && point_distance(_p.x, _p.y, janela_x, janela_y) < 8) {
        _travou = true;
    }
    janela_x = _p.x;
    janela_y = _p.y;
    andou_frames = 0;
}
if (_travou) {
    quieto = 0;
    travado += 1;
    log("travado", "x=" + string(round(_p.x)) + " y=" + string(round(_p.y)) + " vezes=" + string(travado));
    if (travado <= 3) {
        pedir_print("travado");
    }
    desvio_frames = 20;
    desvio_h = choose(-1, 0, 1);
    desvio_v = choose(-1, 1);
    forcar_caminho = 120;
}

// parado sem atacar com inimigo vivo: bug do robo, nao do jogo
if (_mh == 0 && _mv == 0 && _alvo != noone && _p.attack_cooldown <= 0 && !_ameacado && !_quer_morrer) {
    ocioso += 1;
    if (ocioso == 180) {
        log("ALERTA_robo_ocioso", "x=" + string(round(_p.x)) + " y=" + string(round(_p.y)));
        pedir_print("ocioso");
    }
} else {
    ocioso = 0;
}

bot_h = _mh;
bot_v = _mv;
mov_h = _mh;
mov_v = _mv;

if (diag && tempo_sala mod 60 == 0) {
    log("DIAG", "p=" + string(round(_p.x)) + "," + string(round(_p.y)) + " alvo=" + ((_alvo != noone) ? object_get_name(_alvo.object_index) + "@" + string(round(_alvo.x)) + "," + string(round(_alvo.y)) + " st=" + string(_alvo.state) : "saida")
        + " w=" + string(round(_wx)) + "," + string(round(_wy)) + " m=" + string(_mh) + "," + string(_mv) + " face=" + string(_p.face_h) + "," + string(_p.face_v)
        + " amea=" + string(_ameacado) + " zonas=" + string(array_length(_zonas)) + " cd=" + string(_p.attack_cooldown)
        + " pausa=" + string(global.game_paused) + " hitstop=" + string(global.hitstop) + " runf=" + string(global.run_frames) + " tsala=" + string(_p.tempo_na_sala) + " fx=" + string(instance_number(obj_fx)) + " dash=" + string(_p.is_dashing) + "/" + string(_p.dash_timer) + " nplayer=" + string(instance_number(obj_player))
        + " morto=" + string(_p.is_dead) + " venceu=" + string(_p.venceu) + " hp=" + string(_p.hp) + " atk=" + string(_p.is_attacking) + "/" + string(_p.attack_anim_timer));
    if (tempo_sala mod 600 == 0) {
        pedir_print("diag");
    }
}
