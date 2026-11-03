var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);
var _inimigos = instance_number(obj_enemy);
// pisca sem nunca sumir: no minimo 40% visivel
var _piscar = 0.4 + 0.6 * (0.5 + 0.5 * sin(current_time / 200));

// golpe que pegou: a tela fica vermelha e volta
if (hud_dano > 0) {
    draw_set_alpha(0.3 * hud_dano / hud_dano_max);
    draw_set_color(c_red);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
}

// o golpe que limpou a sala
if (global.flash > 0) {
    draw_set_alpha(global.flash);
    draw_set_color(make_colour_rgb(255, 245, 225));
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
}

// HUD: tentativa, vida e cargas de dash
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text_transformed(16 * _esc, 12 * _esc, "TENTATIVA " + string(global.tentativas), _esc, _esc, 0);

// barra de vida: um pedaco por golpe que aguenta. Ao levar golpe ela treme e o
// pedaco perdido apaga do branco; com o ultimo, pulsa; ao ganhar vida, o pedaco pisca
var _vl = 26 * _esc;
var _va = 12 * _esc;
var _vy = 34 * _esc;
var _vx0 = 16 * _esc;
if (hud_dano > 0) {
    _vx0 += sin(hud_dano * 2.1) * 3 * _esc * hud_dano / hud_dano_max;
}
for (var _i = 0; _i < hp_max; _i++) {
    var _vx = _vx0 + _i * (_vl + 2 * _esc);
    draw_set_color(make_colour_rgb(50, 20, 20));
    draw_rectangle(_vx, _vy, _vx + _vl, _vy + _va, false);
    if (_i < hp) {
        draw_set_alpha(hp == 1 ? _piscar : 1);
        draw_set_color(make_colour_rgb(210, 30, 40));
        draw_rectangle(_vx, _vy, _vx + _vl, _vy + _va, false);
        draw_set_alpha(1);
    }
    if (hud_dano > 0 && _i == hp) {
        draw_set_alpha(hud_dano / hud_dano_max);
        draw_set_color(c_white);
        draw_rectangle(_vx, _vy, _vx + _vl, _vy + _va, false);
        draw_set_alpha(1);
    }
    if (hud_cura > 0 && _i == hp - 1) {
        draw_set_alpha(((hud_cura div 6) mod 2 == 0) ? 0.9 : 0.2);
        draw_set_color(c_white);
        draw_rectangle(_vx, _vy, _vx + _vl, _vy + _va, false);
        draw_set_alpha(1);
    }
}
draw_set_color(c_ltgray);
draw_text_transformed(_vx0 + hp_max * (_vl + 2 * _esc) + 4 * _esc, 34 * _esc, "VIDA", _esc * 0.7, _esc * 0.7, 0);

// a carga que esta voltando enche aos poucos; sem carga, treme vermelha; ao
// voltar, pisca
for (var _i = 0; _i < dash_charges_max; _i++) {
    var _px = 16 * _esc + _i * 16 * _esc;
    var _py = 54 * _esc;
    if (dash_negado > 0) {
        _px += sin(dash_negado * 2.1) * 2 * _esc;
    }
    draw_set_color(dash_negado > 0 ? make_colour_rgb(150, 30, 30) : c_dkgray);
    draw_rectangle(_px, _py, _px + 12 * _esc, _py + 6 * _esc, false);
    if (_i < dash_charges) {
        draw_set_color(c_white);
        draw_rectangle(_px, _py, _px + 12 * _esc, _py + 6 * _esc, false);
    } else if (_i == dash_charges && dash_cooldown > 0) {
        var _cheio = 1 - dash_cooldown / dash_cooldown_max;
        draw_set_color(c_gray);
        draw_rectangle(_px, _py, _px + 12 * _esc * _cheio, _py + 6 * _esc, false);
    }
    if (hud_recarga[_i] > 0) {
        var _f = hud_recarga[_i] / 12;
        var _m = (1 - _f) * 3 * _esc;
        draw_set_alpha(_f);
        draw_set_color(c_white);
        draw_rectangle(_px - _m, _py - _m, _px + 12 * _esc + _m, _py + 6 * _esc + _m, true);
        draw_set_alpha(1);
    }
}
draw_set_color(c_ltgray);
draw_text_transformed(16 * _esc + dash_charges_max * 16 * _esc + 4 * _esc, 51 * _esc, "DASH", _esc * 0.7, _esc * 0.7, 0);

// recarga do especial, embaixo do dash e com a largura das duas cargas: enche
// aos poucos; apertando sem recarga, treme vermelha; pronta, pisca
var _ex = 16 * _esc;
var _ey = 68 * _esc;
var _ew = 28 * _esc;
if (especial_negado > 0) {
    _ex += sin(especial_negado * 2.1) * 2 * _esc;
}
draw_set_color(especial_negado > 0 ? make_colour_rgb(150, 30, 30) : c_dkgray);
draw_rectangle(_ex, _ey, _ex + _ew, _ey + 6 * _esc, false);
draw_set_color(especial_recarga > 0 ? c_gray : c_white);
draw_rectangle(_ex, _ey, _ex + _ew * (1 - especial_recarga / especial_recarga_max), _ey + 6 * _esc, false);
if (especial_pronto > 0) {
    var _ef = especial_pronto / 12;
    var _em = (1 - _ef) * 3 * _esc;
    draw_set_alpha(_ef);
    draw_set_color(c_white);
    draw_rectangle(_ex - _em, _ey - _em, _ex + _ew + _em, _ey + 6 * _esc + _em, true);
    draw_set_alpha(1);
}
draw_set_color(c_ltgray);
draw_text_transformed(16 * _esc + dash_charges_max * 16 * _esc + 4 * _esc, 65 * _esc, "ESPECIAL", _esc * 0.7, _esc * 0.7, 0);

// as tecnicas da run: um quadradinho para cada uma, na cor de quem ensinou (nomes na pausa)
for (var _i = 0; _i < array_length(global.tecnicas); _i++) {
    var _def = tecnica_def(global.tecnicas[_i]);
    draw_set_color(variable_struct_get(global.caidos, _def.caido).cor);
    draw_rectangle(16 * _esc + _i * 12 * _esc, 80 * _esc, 16 * _esc + _i * 12 * _esc + 8 * _esc, 88 * _esc, false);
}

// HUD: fase atual; fora do caminho da run, sala de teste
var _fase = mapa_indice(room) + 1;
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text_transformed(_w / 2, 12 * _esc, _fase > 0 ? "FASE " + string(_fase) + " / " + string(array_length(global.mapa_fases)) : "TESTE DE HORDA", _esc, _esc, 0);
draw_set_halign(fa_left);

// HUD: inimigos restantes ou portao aberto
draw_set_halign(fa_right);
if (_inimigos > 0) {
    draw_set_color(c_white);
    draw_text_transformed(_w - 16 * _esc, 12 * _esc, "INIMIGOS: " + string(_inimigos), _esc, _esc, 0);
} else if (_fase > 0 && room != sala_final()) {
    draw_set_color(c_yellow);
    draw_set_alpha(_piscar);
    draw_text_transformed(_w - 16 * _esc, 12 * _esc, portao_aberto() ? "PORTAO ABERTO" : "ABRA O BAU", _esc, _esc, 0);
    draw_set_alpha(1);
}

// seta na borda da tela apontando para o portao aberto quando ele esta fora
// da camera
if (portao_aberto() && _fase > 0 && room != sala_final() && !is_dead && !venceu) {
    var _saida = noone;
    with (obj_exit_to_room1) {
        if (room_next(room) == Room1) {
            _saida = id;
        }
    }
    with (obj_exit_to_room2) {
        if (room_next(room) == Room2) {
            _saida = id;
        }
    }
    with (obj_exit_to_tunel) {
        if (room_next(room) == Room_Tunel) {
            _saida = id;
        }
    }
    with (obj_exit_to_trono) {
        if (room_next(room) == Room_Trono) {
            _saida = id;
        }
    }
    with (obj_exit_to_room3) {
        if (room_next(room) == Room3) {
            _saida = id;
        }
    }
    if (_saida != noone) {
        var _cam = view_camera[0];
        var _cx = camera_get_view_x(_cam);
        var _cy = camera_get_view_y(_cam);
        var _cw = camera_get_view_width(_cam);
        var _ch = camera_get_view_height(_cam);
        var _sx = ((_saida.bbox_left + _saida.bbox_right) / 2 - _cx) / _cw * _w;
        var _sy = ((_saida.bbox_top + _saida.bbox_bottom) / 2 - _cy) / _ch * _h;
        if (_sx < 0 || _sx > _w || _sy < 0 || _sy > _h) {
            var _dir = point_direction(_w / 2, _h / 2, _sx, _sy);
            var _ax = clamp(_sx, 40 * _esc, _w - 40 * _esc);
            var _ay = clamp(_sy, 40 * _esc, _h - 40 * _esc);
            var _t = 16 * _esc;
            draw_set_color(c_yellow);
            draw_set_alpha(_piscar);
            draw_triangle(_ax + lengthdir_x(_t, _dir), _ay + lengthdir_y(_t, _dir),
                _ax + lengthdir_x(_t, _dir + 140), _ay + lengthdir_y(_t, _dir + 140),
                _ax + lengthdir_x(_t, _dir - 140), _ay + lengthdir_y(_t, _dir - 140), false);
            draw_set_alpha(1);
        }
    }
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// dica do objetivo nos primeiros segundos da primeira sala, so na 1a tentativa
if (room == room_next(room_first) && global.tentativas == 1 && tempo_na_sala < 300 && !is_dead && !instance_exists(obj_tecnicas)) {
    draw_set_alpha(min(1, (300 - tempo_na_sala) / 60));
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h * 0.2, "DERROTE TODOS OS INIMIGOS PARA ABRIR O PORTAO", _esc, _esc, 0);
    draw_set_color(c_ltgray);
    draw_text_transformed(_w / 2, _h * 0.2 + 24 * _esc, global.toque_ativo ? "Saia da area vermelha antes do golpe.   Esquerda da tela: andar.   Direita: botoes." : "Saia da area vermelha antes do golpe.   ESC: pausa e controles", _esc * 0.8, _esc * 0.8, 0);
    draw_set_alpha(1);
}

if (is_dead) {
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    draw_set_color(c_red);
    draw_text_transformed(_w / 2, _h / 2 - 20 * _esc, "VOCE MORREU", _esc * 3, _esc * 3, 0);
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h / 2 + 24 * _esc, frase_morte, _esc, _esc, 0);
    draw_set_color(c_ltgray);
    draw_text_transformed(_w / 2, _h / 2 + 46 * _esc, "A run recomeca.", _esc * 0.85, _esc * 0.85, 0);
    draw_set_color(c_white);
} else if (venceu) {
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    var _y = _h / 2 - 130 * _esc;
    draw_set_color(c_red);
    draw_text_transformed(_w / 2, _y, "VITORIA", _esc * 3, _esc * 3, 0);
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _y + 52 * _esc, "O ultimo guerreiro venceu em " + string(global.tentativas) + " tentativa(s), em " + tempo_texto(frames_para_ms(global.run_frames)) + ".", _esc, _esc, 0);
    var _voltar = global.toque_ativo ? "TOQUE NA TELA PARA VOLTAR AO MENU" : "PRESSIONE ENTER PARA VOLTAR AO MENU";

    if (vitoria_estado == "nome") {
        draw_set_color(vitoria_nome_recusado ? c_red : c_ltgray);
        draw_text_transformed(_w / 2, _y + 100 * _esc, vitoria_nome_recusado ? "Esse nome nao pode. Digite outro." : "DIGITE SEU NOME PARA O RANKING", _esc, _esc, 0);
        var _bw = 150 * _esc;
        draw_set_color(c_dkgray);
        draw_rectangle(_w / 2 - _bw, _y + 118 * _esc, _w / 2 + _bw, _y + 146 * _esc, true);
        draw_set_color(c_yellow);
        var _cursor = (current_time div 500) mod 2 == 0 ? "_" : " ";
        draw_text_transformed(_w / 2, _y + 132 * _esc, vitoria_nome + _cursor, _esc * 1.2, _esc * 1.2, 0);
        draw_set_color(c_white);
        if (global.toque_ativo) {
            var _botoes_nome = toque_botoes_nome();
            toque_botao_ret(_botoes_nome.escrever);
            toque_botao_ret(_botoes_nome.pular);
        } else {
            draw_set_alpha(_piscar);
            draw_text_transformed(_w / 2, _y + 172 * _esc, "ENTER: ENVIAR    (VAZIO: PULAR)", _esc * 0.9, _esc * 0.9, 0);
            draw_set_alpha(1);
        }
    } else if (vitoria_estado == "enviando") {
        draw_set_color(c_ltgray);
        draw_text_transformed(_w / 2, _y + 110 * _esc, "ENVIANDO...", _esc, _esc, 0);
    } else if (vitoria_estado == "enviado") {
        draw_set_color(c_yellow);
        draw_text_transformed(_w / 2, _y + 100 * _esc, "VOCE FICOU EM #" + string(vitoria_posicao) + " DE " + string(vitoria_total) + " NO RANKING", _esc, _esc, 0);
        // top 5: posicao e nome a esquerda, tentativas e tempo a direita
        var _n = array_length(vitoria_ranking);
        for (var _i = 0; _i < _n; _i++) {
            var _linha = vitoria_ranking[_i];
            var _ly = _y + (136 + _i * 22) * _esc;
            draw_set_color(string_lower(_linha.nome) == string_lower(string_trim(vitoria_nome)) ? c_yellow : c_white);
            draw_set_halign(fa_left);
            draw_text_transformed(_w / 2 - 170 * _esc, _ly, string(_i + 1) + ".  " + _linha.nome, _esc * 0.9, _esc * 0.9, 0);
            draw_set_halign(fa_right);
            draw_text_transformed(_w / 2 + 170 * _esc, _ly, string(_linha.tentativas) + " tent.   " + tempo_texto(_linha.tempo_ms), _esc * 0.9, _esc * 0.9, 0);
        }
        draw_set_halign(fa_center);
        draw_set_color(c_white);
        draw_set_alpha(_piscar);
        draw_text_transformed(_w / 2, _y + (156 + max(_n, 1) * 22) * _esc, _voltar, _esc, _esc, 0);
        draw_set_alpha(1);
    } else {
        if (vitoria_estado == "falhou") {
            draw_set_color(c_ltgray);
            draw_text_transformed(_w / 2, _y + 100 * _esc, "SEM CONEXAO COM O RANKING", _esc, _esc, 0);
        }
        draw_set_color(c_white);
        draw_set_alpha(_piscar);
        draw_text_transformed(_w / 2, _y + 132 * _esc, _voltar, _esc, _esc, 0);
        draw_set_alpha(1);
    }
}

if (global.toque_ativo && !venceu && !is_dead && !global.game_paused && !instance_exists(obj_mapa)) {
    toque_desenhar(dash_charges > 0, especial_recarga <= 0);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
}

if (global.game_paused) {
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(_piscar);
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h / 2 - 40 * _esc, "PAUSADO", _esc * 2, _esc * 2, 0);
    draw_set_alpha(1);
    if (array_length(global.tecnicas) > 0) {
        var _nomes = "";
        for (var _i = 0; _i < array_length(global.tecnicas); _i++) {
            _nomes += (_i > 0 ? "   " : "") + tecnica_def(global.tecnicas[_i]).nome;
        }
        draw_set_color(c_ltgray);
        draw_text_transformed(_w / 2, _h / 2 - 72 * _esc, _nomes, _esc * 0.7, _esc * 0.7, 0);
        draw_set_color(c_white);
    }
    if (global.toque_ativo) {
        // os controles de toque no lugar dos de teclado
        var _botoes_pausa = toque_botoes_pausa();
        toque_botao_ret(_botoes_pausa.continuar);
        toque_botao_ret(_botoes_pausa.menu);
        draw_text_transformed(_w / 2, _h / 2, "ESQUERDA DA TELA: andar    ATACAR: golpe (3 seguidos: combo)    DASH: esquiva", _esc, _esc, 0);
        draw_text_transformed(_w / 2, _h / 2 + 22 * _esc, "SEGURAR ATACAR: golpe carregado    ATACAR NO DASH: estocada    GIRO: especial", _esc, _esc, 0);
        draw_set_color(c_ltgray);
        draw_text_transformed(_w / 2, _h / 2 + 42 * _esc, "O golpe vira sozinho para o inimigo mais perto", _esc * 0.85, _esc * 0.85, 0);
        draw_set_color(c_white);
    } else {
    draw_text_transformed(_w / 2, _h / 2, "WASD / SETAS: mover    CLIQUE ou J: atacar (3 seguidos: combo)    ESPACO: dash", _esc, _esc, 0);
    draw_text_transformed(_w / 2, _h / 2 + 22 * _esc, "SEGURAR O ATAQUE: golpe carregado    ATACAR NO DASH: estocada    CLIQUE DIREITO ou K: especial", _esc, _esc, 0);
    draw_set_color(c_ltgray);
    draw_text_transformed(_w / 2, _h / 2 + 42 * _esc, "O golpe vira sozinho para o inimigo mais perto", _esc * 0.85, _esc * 0.85, 0);
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h / 2 + 62 * _esc, "ESC: CONTINUAR    M: VOLTAR AO MENU", _esc, _esc, 0);
    }
    // onde voce esta no caminho ate o fim
    var _fase_mapa = mapa_indice(room);
    if (_fase_mapa >= 0) {
        var _my = _h / 2 + 140 * _esc;
        draw_set_alpha(0.7);
        draw_set_color(c_black);
        draw_rectangle(0, _my - 66 * _esc, _w, _my + 52 * _esc, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        mapa_desenhar(_my, _esc * 0.8, _fase_mapa, 1);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
    }
}

if (fade > 0) {
    draw_set_alpha(fade);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    fade = max(0, fade - 0.05);
}

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
