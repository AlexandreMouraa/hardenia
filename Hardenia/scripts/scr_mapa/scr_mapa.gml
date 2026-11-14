// Mapa de progresso: o caminho da run, do comeco ao fim. Aparece ao entrar em
// cada fase nova (obj_mapa) e na pausa. Fase nova: acrescentar aqui, na ordem.
global.mapa_fases = [
    { sala: Room1, nome: "Ruínas", musica: snd_game_music, frase: "As ruínas guardam os ossos de quem veio antes de mim." },
    { sala: Room_Tunel, nome: "Catacumbas", musica: snd_musica_catacumbas, frase: "Aqui embaixo ninguém vem me buscar. Nem eles esperam que eu volte." },
    { sala: Room2, nome: "Pátio do Castelo", musica: snd_musica_patio, frase: "No pátio, quem fica parado não chega ao castelo." },
    { sala: Room3, nome: "Cemitério Gelado", musica: snd_musica_cemiterio, frase: "O cemitério tem lugar para mais um. Ainda não." },
    { sala: Room_Trono, nome: "O Trono", musica: -1, frase: "O trono está logo ali. Ele também morreu um dia." },
];
// ponto trancado no fim do caminho, para um lugar que ainda nao existe no jogo. "" = nenhum
global.mapa_final = "";

// golpes que o jogador aguenta (decisao de 30/10: com 1, horda seria morte certa;
// ajustar jogando)
#macro VIDA_MAX 5

// a vida passa de uma sala para a outra (o obj_player nasce de novo em cada uma).
// fase_curada: ate onde limpar a fase ja devolveu vida nesta run
// tecnicas: scr_tecnicas. No jogo a semente vem do relogio: cada run oferece outras. No robo,
// da contagem de runs: muda a cada run, e a rodada inteira se repete igual. No desafio do dia, da
// data: a mesma em toda tentativa, e para todo mundo (scr_variacao)
global.runs_zeradas = 0;
global.desafio = false;
global.desafio_dia = "";
function run_zerar() {
    // a arma do Caido se perde na morte, como as tecnicas (scr_armas)
    global.arma = "espada";
    global.vida = VIDA_MAX;
    global.fase_curada = -1;
    global.furia = 0;
    global.tecnicas = [];
    global.tecnica_ultimo = "";
    global.tecnica_ultimo_ms = -2000;
    global.tecnica_inicio = true;
    duelos_zerar();
    global.runs_zeradas += 1;
    if (instance_exists(obj_autotest) && !global.desafio) {
        global.run_semente = 1000 + global.runs_zeradas * 97;
    } else if (global.desafio) {
        global.run_semente = desafio_semente();
    } else {
        global.run_semente = (current_time mod 2147483646) + 1;
    }
    global.tecnica_semente = global.run_semente;
    global.ofertas_feitas = 0;
}
// no codigo solto: a sala aberta direto pela IDE, sem passar pelo menu, tambem funciona
run_zerar();

// Frase da tela de morte: o guerreiro mais fraco aprendendo, sem cutscene. Por inimigo:
// [primeira vez, voltou a morrer ali]. Inimigo novo: acrescentar aqui, com o nome do objeto
global.frases_inimigo = {
    obj_enemy_defensor: ["O escudo cobria a frente. As costas estavam livres.", "De novo o defensor. Depois do golpe ele abre a guarda."],
    obj_perigo_patio: ["O chão avisou. A pólvora não escolhe lado.", "Posso usar as armadilhas. Só não posso ficar nelas."],
    obj_enemy: ["O esqueleto avisou. Eu é que não saí da frente.", "Esse esqueleto de novo... dessa vez eu desvio."],
    obj_enemy_ghoul: ["O ghoul só corre em linha reta. Era só sair do caminho.", "Esse ghoul de novo. Agora eu sei onde ele para."],
    obj_enemy_wight: ["O wight demora, mas quando varre, varre tudo.", "De novo esse wight. Depois da varredura ele fica exposto."],
    obj_enemy_arqueiro: ["A flecha avisou antes. Eu é que fiquei na linha.", "Esse arqueiro de novo. Agora eu corro de lado."],
    obj_enemy_conjurador: ["O círculo estava no chão. Eu é que fiquei em cima dele.", "O conjurador de novo. Da próxima eu vou atrás dele primeiro."],
    obj_explosao: ["Ele explodiu depois de morrer. Eu devia ter saído de perto.", "De novo a explosão. Mata e corre."],
    obj_enemy_chefe: ["O rei morto não tem pressa. Eu tive.", "O Trono de novo. A coluna para a investida."],
    obj_enemy_caido: ["Ele também chegou até aqui. Agora eu sei como ele caiu.", "Esse Caído de novo. Eu já conheço o golpe dele."],
    obj_enemy_horda: ["Eram muitos. Da próxima eu abro caminho com o dash.", "A horda de novo. Parado eu não saio daqui."],
};
global.frases_teimoso = [
    "Mais uma. O mais fraco de todos continua voltando.",
    "Eles não aprendem. Eu sim.",
    "Nenhum guerreiro chegou tão longe morrendo tanto.",
];
// quantas vezes morreu em cada sala, nesta sessao de jogo (zera no menu)
global.mortes_por_sala = {};

// conta esta morte e escolhe a frase, sem sorteio: o robo depende da sequencia
// aleatoria do jogo. _causa: nome do objeto que acertou o ultimo golpe
function frase_de_morte(_causa) {
    var _nome = room_get_name(room);
    var _ali = 1;
    if (variable_struct_exists(global.mortes_por_sala, _nome)) {
        _ali += variable_struct_get(global.mortes_por_sala, _nome);
    }
    variable_struct_set(global.mortes_por_sala, _nome, _ali);
    var _marco = frase_de_marco(global.tentativas);
    if (_marco != "") {
        return _marco;
    }
    var _fase = mapa_indice(room);
    var _inimigo = variable_struct_exists(global.frases_inimigo, _causa);
    if (_ali >= 5) {
        return global.frases_teimoso[_ali mod array_length(global.frases_teimoso)];
    }
    if (_ali >= 3 && _inimigo) {
        return variable_struct_get(global.frases_inimigo, _causa)[1];
    }
    if (_ali == 2 && _fase >= 0) {
        return global.mapa_fases[_fase].frase;
    }
    if (_inimigo) {
        return variable_struct_get(global.frases_inimigo, _causa)[0];
    }
    return "Cada morte ensina.";
}

// Colisao por imagem: a sala abaixo tira as paredes de uma mascara do tamanho dela (preto =
// parede), em vez de obj_wall posicionados a mao. passo: de quantos em quantos pixels da
// imagem ela e lida; contorno mais detalhado que isso vira degrau. Veja ESPECIFICACAO_ARTE
global.mascaras_sala = [
    { sala: Room1, sprite: spr_mascara_ruinas, passo: 8 },
    { sala: Room2, sprite: spr_mascara_patio, passo: 8 },
    { sala: Room3, sprite: spr_mascara_cemiterio, passo: 8 },
    { sala: Room_Tunel, sprite: spr_mascara_tunel, passo: 8 },
    { sala: Room_Trono, sprite: spr_mascara_trono, passo: 8 },
];
// retangulos ja lidos, por sprite: ler pixel e caro, e morrer recria a sala
global.mascaras_lidas = {};

// le a imagem uma vez e junta os pontos pretos em retangulos: primeiro os trechos de cada
// linha, depois o trecho igual ao da linha de cima vira um retangulo so. Menos obj_wall e
// menos conta em todo place_meeting. Devolve [x, y, largura, altura], em pixels da sala
function mascara_ler(_spr, _passo) {
    var _w = sprite_get_width(_spr);
    var _h = sprite_get_height(_spr);
    var _surf = surface_create(_w, _h);
    surface_set_target(_surf);
    draw_clear(c_white);
    draw_sprite(_spr, 0, 0, 0);
    surface_reset_target();
    var _buf = buffer_create(_w * _h * 4, buffer_fixed, 1);
    buffer_get_surface(_buf, _surf, 0);
    surface_free(_surf);

    var _sx = room_width / _w;
    var _sy = room_height / _h;
    var _prontos = [];
    var _abertos = []; // [coluna inicial, coluna final, linha inicial]
    var _colunas = _w div _passo;
    var _linhas = _h div _passo;
    for (var _j = 0; _j <= _linhas; _j++) {
        var _novos = [];
        var _i = 0;
        var _a = 0;
        while (_j < _linhas && _i < _colunas) {
            // o pixel do meio da celula; verde porque a ordem das cores muda entre Windows e navegador
            var _pos = ((_j * _passo + _passo div 2) * _w + _i * _passo + _passo div 2) * 4 + 1;
            if (buffer_peek(_buf, _pos, buffer_u8) >= 128) {
                _i += 1;
                continue;
            }
            var _ini = _i;
            while (_i < _colunas && buffer_peek(_buf, ((_j * _passo + _passo div 2) * _w + _i * _passo + _passo div 2) * 4 + 1, buffer_u8) < 128) {
                _i += 1;
            }
            // mesmo trecho da linha de cima: continua aquele retangulo
            var _linha_ini = _j;
            while (_a < array_length(_abertos) && _abertos[_a][1] <= _ini) {
                array_push(_prontos, _abertos[_a]);
                _abertos[_a][3] = _j;
                _a += 1;
            }
            if (_a < array_length(_abertos) && _abertos[_a][0] == _ini && _abertos[_a][1] == _i) {
                _linha_ini = _abertos[_a][2];
                _a += 1;
            }
            array_push(_novos, [_ini, _i, _linha_ini, 0]);
        }
        while (_a < array_length(_abertos)) {
            _abertos[_a][3] = _j;
            array_push(_prontos, _abertos[_a]);
            _a += 1;
        }
        _abertos = _novos;
    }
    buffer_delete(_buf);

    var _saida = [];
    for (var _r = 0; _r < array_length(_prontos); _r++) {
        var _p = _prontos[_r];
        array_push(_saida, [_p[0] * _passo * _sx, _p[2] * _passo * _sy, (_p[1] - _p[0]) * _passo * _sx, (_p[3] - _p[2]) * _passo * _sy]);
    }
    return _saida;
}

// chamada no Create do obj_player, que nasce primeiro: as paredes ja existem quando o resto
// da sala comecar
function paredes_da_mascara() {
    for (var _m = 0; _m < array_length(global.mascaras_sala); _m++) {
        var _def = global.mascaras_sala[_m];
        if (_def.sala == room) {
            var _nome = sprite_get_name(_def.sprite);
            if (!variable_struct_exists(global.mascaras_lidas, _nome)) {
                variable_struct_set(global.mascaras_lidas, _nome, mascara_ler(_def.sprite, _def.passo));
            }
            var _ret = variable_struct_get(global.mascaras_lidas, _nome);
            for (var _r = 0; _r < array_length(_ret); _r++) {
                var _q = _ret[_r];
                with (instance_create_layer(_q[0], _q[1], "Instances", obj_wall)) {
                    image_xscale = _q[2] / sprite_width;
                    image_yscale = _q[3] / sprite_height;
                }
            }
            return;
        }
    }
}

// posicao da sala no caminho; -1 fora dele (menu)
function mapa_indice(_sala) {
    for (var _i = 0; _i < array_length(global.mapa_fases); _i++) {
        if (global.mapa_fases[_i].sala == _sala) {
            return _i;
        }
    }
    return -1;
}

// ultima sala do caminho: limpar ela encerra a run. room_last nao serve, porque a
// sala de teste da horda fica depois dela na lista de salas
function sala_final() {
    return global.mapa_fases[array_length(global.mapa_fases) - 1].sala;
}

// usado pelos portoes e pelo menu: indo para a frente, mostra o mapa antes de
// trocar de sala; voltando, troca direto
function ir_para_sala(_sala) {
    if (instance_exists(obj_mapa)) {
        exit;
    }
    var _de = mapa_indice(room);
    var _para = mapa_indice(_sala);
    if (_para <= _de) {
        room_goto(_sala);
        exit;
    }
    with (instance_create_depth(0, 0, -10000, obj_mapa)) {
        destino = _sala;
        de = _de;
        para = _para;
    }
}

// ponto da estrada na posicao _pos (0 = primeira fase, 1 = segunda...; pode ser fracionada ou
// negativa). A estrada serpenteia: fase par em cima, impar embaixo, em curva suave entre elas
function mapa_ponto(_x0, _passo, _cy, _amp, _pos) {
    return [_x0 + _pos * _passo, _cy - _amp * cos(pi * _pos)];
}

// desenha o caminho na GUI, centrado em _cy. O marcador (o guerreiro) fica em
// _pos: 0 = primeira fase, 1 = segunda...; entre dois pontos, esta andando.
// -0.6 = ainda antes da primeira fase (saindo do menu). _amp: quanto a estrada sobe e desce.
// _chegada: 0 a 1, desde que o guerreiro pisou na fase nova (anel de luz abrindo); 1 = sem anel
function mapa_desenhar(_cy, _esc, _pos, _alpha, _amp = 30, _chegada = 1) {
    var _w = display_get_gui_width();
    var _tem_final = (global.mapa_final != "");
    var _n = array_length(global.mapa_fases) + (_tem_final ? 1 : 0);
    var _x0 = _w * 0.17;
    var _x1 = _w * 0.83;
    var _passo = (_x1 - _x0) / (_n - 1);
    var _a = _amp * _esc;
    var _vermelho = make_colour_rgb(196, 22, 28);
    var _apagado = make_colour_rgb(110, 96, 98);
    var _fundo_no = make_colour_rgb(16, 10, 12);
    var _pulso = 0.5 + 0.5 * sin(current_time / 180);

    // o painel premium das cartas (scr_interface_tecnicas) atras da estrada
    draw_set_alpha(_alpha);
    painel_premium(_x0 - 84 * _esc, _cy - _a - 96 * _esc, _x1 + 84 * _esc, _cy + _a + 76 * _esc, make_colour_rgb(120, 20, 24), false, 1, _esc);
    draw_set_alpha(_alpha);

    // estrada em curva: sulco escuro por baixo, vermelha ate onde o guerreiro chegou, pontilhada
    // dali em diante. Trechos curtos de reta, com um disco em cada emenda para a curva ficar lisa
    var _fim_t = _n - 1;
    var _ate_t = clamp(_pos, 0, _fim_t);
    var _dt = 0.04;
    draw_set_colour(make_colour_rgb(10, 6, 8));
    for (var _t = 0; _t < _fim_t - 0.0001; _t += _dt) {
        var _p0 = mapa_ponto(_x0, _passo, _cy, _a, _t);
        var _p1 = mapa_ponto(_x0, _passo, _cy, _a, min(_t + _dt, _fim_t));
        draw_line_width(_p0[0], _p0[1] + _esc, _p1[0], _p1[1] + _esc, 11 * _esc);
        draw_circle(_p1[0], _p1[1] + _esc, 5.5 * _esc, false);
    }
    // o leito da estrada, um pouco mais claro que o sulco, para ela aparecer no painel escuro
    draw_set_colour(make_colour_rgb(52, 38, 40));
    for (var _t = 0; _t < _fim_t - 0.0001; _t += _dt) {
        var _p0 = mapa_ponto(_x0, _passo, _cy, _a, _t);
        var _p1 = mapa_ponto(_x0, _passo, _cy, _a, min(_t + _dt, _fim_t));
        draw_line_width(_p0[0], _p0[1], _p1[0], _p1[1], 7 * _esc);
        draw_circle(_p1[0], _p1[1], 3.5 * _esc, false);
    }
    draw_set_colour(_vermelho);
    for (var _t = 0; _t < _ate_t - 0.0001; _t += _dt) {
        var _p0 = mapa_ponto(_x0, _passo, _cy, _a, _t);
        var _p1 = mapa_ponto(_x0, _passo, _cy, _a, min(_t + _dt, _ate_t));
        draw_line_width(_p0[0], _p0[1], _p1[0], _p1[1], 5 * _esc);
        draw_circle(_p1[0], _p1[1], 2.5 * _esc, false);
    }
    draw_set_colour(_apagado);
    for (var _t = ceil(_ate_t / 0.1 + 0.5) * 0.1; _t < _fim_t; _t += 0.1) {
        var _pp = mapa_ponto(_x0, _passo, _cy, _a, _t);
        draw_circle(_pp[0], _pp[1], 1.8 * _esc, false);
    }
    // brasas correndo pelo trecho ja andado (posicoes pelo relogio, sem random)
    if (_ate_t > 0.01) {
        gpu_set_blendmode(bm_add);
        draw_set_colour(make_colour_rgb(255, 150, 70));
        for (var _b = 0; _b < 14; _b++) {
            var _f = ((current_time / 2600) + _b * 0.071) mod 1;
            var _pb = mapa_ponto(_x0, _passo, _cy, _a, _ate_t * _f);
            var _sobe = (3 + 9 * (0.5 + 0.5 * sin(_b * 2.3 + current_time / 400))) * _esc;
            draw_set_alpha(_alpha * (0.25 + 0.5 * (0.5 + 0.5 * sin(_b * 1.7 + current_time / 150))));
            draw_circle(_pb[0], _pb[1] - _sobe, 1.6 * _esc, false);
        }
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(_alpha);
    }

    // as fases: medalhoes redondos. Vermelho e ouro onde ja passou, branco na atual, apagado adiante
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    for (var _i = 0; _i < _n; _i++) {
        var _pn = mapa_ponto(_x0, _passo, _cy, _a, _i);
        var _px = _pn[0];
        var _py = _pn[1];
        var _final = (_tem_final && _i == _n - 1);
        var _ultima = (!_final && _i == array_length(global.mapa_fases) - 1);
        var _chegou = (!_final && _pos >= _i - 0.001);
        var _aqui = (!_final && abs(_pos - _i) < 0.001);
        var _r = (_ultima ? 17 : 14) * _esc + (_aqui ? 2 * _esc : 0);
        if (_aqui) {
            // fase atual: halo pulsando, e o anel de luz abrindo na chegada
            gpu_set_blendmode(bm_add);
            draw_set_colour(make_colour_rgb(255, 120, 80));
            draw_set_alpha(_alpha * (0.14 + 0.18 * _pulso));
            draw_circle(_px, _py, _r + (9 + 6 * _pulso) * _esc, false);
            if (_chegada < 1) {
                draw_set_colour(make_colour_rgb(255, 210, 150));
                for (var _k = 0; _k < 3; _k++) {
                    draw_set_alpha(_alpha * (1 - _chegada) * 0.8);
                    draw_circle(_px, _py, _r + (_chegada * 46 + _k) * _esc, true);
                }
            }
            gpu_set_blendmode(bm_normal);
            draw_set_alpha(_alpha);
        }
        var _aro = _aqui ? c_white : (_chegou ? PREMIUM_OURO : _apagado);
        draw_set_colour(make_colour_rgb(6, 4, 6));
        draw_circle(_px, _py + 2 * _esc, _r + 1.5 * _esc, false);
        draw_set_colour(_aro);
        draw_circle(_px, _py, _r, false);
        draw_set_colour(_chegou ? PREMIUM_OURO_ESCURO : _fundo_no);
        draw_circle(_px, _py, _r - 2.5 * _esc, false);
        draw_set_colour(_chegou ? _vermelho : _fundo_no);
        draw_circle(_px, _py, _r - 4 * _esc, false);
        if (_chegou) {
            // um brilho no alto do medalhao
            gpu_set_blendmode(bm_add);
            draw_set_alpha(_alpha * 0.22);
            draw_set_colour(c_white);
            draw_ellipse(_px - _r * 0.55, _py - _r * 0.68, _px + _r * 0.55, _py - _r * 0.05, false);
            gpu_set_blendmode(bm_normal);
            draw_set_alpha(_alpha);
        }
        if (_ultima) {
            // o Trono: uma coroa em cima do medalhao
            var _cb = _py - _r - 3 * _esc;
            draw_set_colour(_chegou ? PREMIUM_OURO : _apagado);
            for (var _k = -1; _k <= 1; _k++) {
                draw_triangle(_px + (_k * 7 - 4.5) * _esc, _cb, _px + _k * 7 * _esc, _cb - (_k == 0 ? 11 : 8) * _esc, _px + (_k * 7 + 4.5) * _esc, _cb, false);
            }
            draw_line_width(_px - 11.5 * _esc, _cb, _px + 11.5 * _esc, _cb, 2 * _esc);
        }
        draw_set_colour(_final ? _apagado : (_chegou ? c_white : c_gray));
        texto(_px, _py, _final ? "?" : string(_i + 1), _esc * 0.85, _esc * 0.85, 0);
        // nome embaixo; e o Caido daquela fase, quando ja apareceu nesta run, com a cor dele
        var _ny = _py + _r + 14 * _esc;
        if (_final) {
            draw_set_colour(c_gray);
            texto(_px, _ny, global.mapa_final, _esc * 0.8, _esc * 0.8, 0);
            draw_set_colour(_apagado);
            texto(_px, _ny + 18 * _esc, "EM BREVE", _esc * 0.65, _esc * 0.65, 0);
            continue;
        }
        draw_set_colour(_aqui ? c_white : (_chegou ? c_ltgray : c_gray));
        texto(_px, _ny, global.mapa_fases[_i].nome, _esc * 0.8, _esc * 0.8, 0);
        var _nome_sala = room_get_name(global.mapa_fases[_i].sala);
        if (variable_struct_exists(global.duelos_caidos, _nome_sala)) {
            var _cdef = variable_struct_get(global.caidos, variable_struct_get(global.duelos_caidos, _nome_sala));
            draw_set_font(global.fonte_texto);
            var _lgc = string_width(_cdef.nome) * FONTE_ESCALA * _esc * 0.6 / 2;
            draw_set_colour(_cdef.cor);
            draw_circle(_px - _lgc - 7 * _esc, _ny + 19 * _esc, 3.2 * _esc, false);
            texto(_px + 3 * _esc, _ny + 18 * _esc, _cdef.nome, _esc * 0.6, _esc * 0.6, 0);
        }
    }

    // o guerreiro andando pela estrada, de frente para a direita, com uma luz no chao
    var _pm = mapa_ponto(_x0, _passo, _cy, _a, _pos);
    var _andando = (abs(_pos - round(_pos)) > 0.001);
    var _quadro = _andando ? (current_time div 70) mod 8 : 0;
    var _spr = _andando ? spr_heroi_andar : spr_heroi_parado;
    var _chao = _pm[1] - (_andando ? 4 : 18) * _esc;
    gpu_set_blendmode(bm_add);
    draw_set_alpha(_alpha * 0.25);
    draw_set_colour(make_colour_rgb(255, 180, 120));
    draw_ellipse(_pm[0] - 18 * _esc, _chao - 6 * _esc, _pm[0] + 18 * _esc, _chao + 5 * _esc, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(_alpha);
    draw_sprite_ext(_spr, (_andando ? 8 : 4) + _quadro, _pm[0], _chao - 30 * _esc, 1.25 * _esc, 1.25 * _esc, 0, c_white, _alpha);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
