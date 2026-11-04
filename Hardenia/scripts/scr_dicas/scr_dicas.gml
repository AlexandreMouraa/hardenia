// Dicas: ensinam os golpes na hora em que servem, uma de cada vez, em vez de um texto no comeco.
// Cada uma aparece uma vez neste aparelho (scr_salvo), e ligar as dicas de novo nas opcoes zera.
// Dica nova: acrescentar em DICAS_ORDEM, e o caso em cada funcao abaixo. So desenho: nao mexe na run.
#macro DICAS_ORDEM ["mover", "golpe", "zona", "combo", "apagado", "giro", "escudo", "estocada", "carga", "furia", "bau", "portao"]
global.dica_agora = "";
global.dica_tempo = 0;
global.dica_espera = 60;

// o nome do botao no aparelho em uso
function dica_botao(_acao) {
    var _toque = global.toque_ativo;
    var _pad = (global.ultimo_aparelho == "controle");
    switch (_acao) {
        case "mover": return _toque ? "O polegar à esquerda da tela" : (_pad ? "A alavanca" : "WASD ou as setas");
        case "golpe": return _toque ? "ATACAR" : (_pad ? "RB ou X" : "CLIQUE ou J");
        case "dash": return _toque ? "DASH" : (_pad ? "A ou LB" : "ESPAÇO");
        case "giro": return _toque ? "GIRO" : (_pad ? "B" : "CLIQUE DIREITO ou K");
    }
    return "";
}

function dica_texto(_k) {
    switch (_k) {
        case "mover": return dica_botao("mover") + " move o guerreiro.";
        case "golpe": return dica_botao("golpe") + ": golpe. Ele vira sozinho para o inimigo mais perto.";
        case "zona": return "Saia da zona vermelha antes do golpe. " + dica_botao("dash") + ": o dash atravessa.";
        case "combo": return "Três golpes seguidos fazem um combo. O último vale o dobro e empurra.";
        case "apagado": return "Inimigo apagado acabou de atacar: é a hora de bater.";
        case "giro": return "Cercado? " + dica_botao("giro") + ": o giro acerta todos em volta.";
        case "escudo": return "Escudo: só quebra com golpe carregado, estocada ou giro.";
        case "estocada": return "Atacar logo depois do dash solta a estocada, um golpe mais longo.";
        case "carga": return "Segure " + dica_botao("golpe") + " até o guerreiro piscar e solte: golpe carregado.";
        case "furia": return "Fúria cheia: segure " + dica_botao("giro") + " para soltar o Giro Furioso.";
        case "bau": return "Encoste no baú para ver o que os Caídos deixaram.";
        case "portao": return "O portão abriu. A seta amarela aponta para ele.";
    }
    return "";
}

// roda no jogador: chegou a hora desta dica?
function dica_pede(_k) {
    var _inimigo = instance_nearest(x, y, obj_enemy);
    var _perto = (_inimigo != noone) ? point_distance(x, y, _inimigo.x, _inimigo.y) : 100000;
    switch (_k) {
        case "mover": return tempo_na_sala > 40;
        case "golpe": return _perto < 260;
        case "zona":
            var _tem = false;
            with (obj_enemy) {
                if (state == 1 && zona_visivel && point_distance(x, y, other.x, other.y) < 220) {
                    _tem = true;
                }
            }
            return _tem;
        case "combo": return combo_passo >= 1;
        case "apagado": return _inimigo != noone && _inimigo.state == 3 && _perto < 150;
        case "giro": return collision_circle(x, y, 150, obj_enemy, false, true) != noone && instance_number(obj_enemy) >= 2 && _perto < 100 && especial_recarga <= 0;
        case "escudo":
            var _esc = false;
            with (obj_enemy) {
                if (escudo && point_distance(x, y, other.x, other.y) < 300) {
                    _esc = true;
                }
            }
            return _esc;
        case "estocada": return dash_freio > 0 && _perto < 200;
        case "carga": return mapa_indice(room) >= 1 && _perto < 200;
        case "furia": return global.furia >= FURIA_MAX;
        case "bau": return instance_exists(obj_bau) && !instance_find(obj_bau, 0).aberto;
        case "portao": return portao_aberto() && mapa_indice(room) >= 0 && room != sala_final();
    }
    return false;
}

// o jogador ja fez o que a dica pedia? Ela sai antes da hora
function dica_feita(_k) {
    switch (_k) {
        case "mover": return tempo_na_sala > 40 && (x != xstart || y != ystart);
        case "golpe": return is_attacking;
        case "zona": return is_dashing;
        case "combo": return is_attacking && golpe_atual == 3;
        case "giro": return especial_recarga > 0;
        case "estocada": return is_attacking && golpe_estocada;
        case "carga": return carga >= carga_max;
        case "furia": return global.furia < FURIA_MAX;
        case "bau": return !instance_exists(obj_bau) || instance_find(obj_bau, 0).aberto;
    }
    return false;
}

// roda no jogador, uma vez por frame de jogo
function dicas_passo() {
    if (is_dead || venceu) {
        global.dica_agora = "";
        return;
    }
    if (global.dica_agora != "") {
        global.dica_tempo += 1;
        // no minimo 1,5 s na tela, para dar tempo de ler; no maximo 6 s
        if (global.dica_tempo > 360 || (global.dica_tempo > 90 && dica_feita(global.dica_agora))) {
            global.dica_agora = "";
            global.dica_espera = 150;
        }
        return;
    }
    if (!global.op_dicas) {
        return;
    }
    if (global.dica_espera > 0) {
        global.dica_espera -= 1;
        return;
    }
    var _ordem = DICAS_ORDEM;
    for (var _i = 0; _i < array_length(_ordem); _i++) {
        var _k = _ordem[_i];
        if (!variable_struct_exists(global.salvo.dicas, _k) && dica_pede(_k)) {
            variable_struct_set(global.salvo.dicas, _k, true);
            global.dica_agora = _k;
            global.dica_tempo = 0;
            salvo_gravar();
            return;
        }
    }
}

// faixa embaixo, acima dos botoes de toque. O texto sai na hora, para mudar com o aparelho
function dica_desenhar() {
    if (global.dica_agora == "") {
        return;
    }
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _esc = max(1, _h / 540);
    var _s = dica_texto(global.dica_agora);
    var _alfa = min(1, global.dica_tempo / 12);
    draw_set_font(global.fonte_texto);
    var _lg = string_width(_s) * FONTE_ESCALA * _esc * 1.05 / 2 + 18 * _esc;
    var _y = _h * 0.74;
    draw_set_alpha(0.72 * _alfa);
    draw_set_color(make_colour_rgb(20, 12, 12));
    draw_rectangle(_w / 2 - _lg, _y - 16 * _esc, _w / 2 + _lg, _y + 16 * _esc, false);
    draw_set_alpha(_alfa);
    draw_set_color(make_colour_rgb(235, 120, 80));
    draw_rectangle(_w / 2 - _lg, _y - 16 * _esc, _w / 2 - _lg + 3 * _esc, _y + 16 * _esc, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    texto(_w / 2, _y, _s, _esc * 1.05, _esc * 1.05, 0);
    draw_set_alpha(1);
}
