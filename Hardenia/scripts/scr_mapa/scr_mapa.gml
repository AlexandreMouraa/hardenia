// Mapa de progresso: o caminho da run, do comeco ao fim. Aparece ao entrar em
// cada fase nova (obj_mapa) e na pausa. Fase nova: acrescentar aqui, na ordem.
// Nomes sem acento: a fonte do jogo nao tem esses caracteres
global.mapa_fases = [
    { sala: Room1, nome: "RUINAS", frase: "As ruinas guardam os ossos de quem veio antes de mim." },
    { sala: Room_Tunel, nome: "CATACUMBAS", frase: "Aqui embaixo ninguem vem me buscar. Nem eles esperam que eu volte." },
    { sala: Room2, nome: "PATIO DO CASTELO", frase: "No patio, quem fica parado nao chega ao castelo." },
    { sala: Room3, nome: "CEMITERIO GELADO", frase: "O cemiterio tem lugar para mais um. Ainda nao." },
    { sala: Room_Trono, nome: "O TRONO", frase: "O trono esta logo ali. Ele tambem morreu um dia." },
];
// ponto trancado no fim do caminho, para um lugar que ainda nao existe no jogo. "" = nenhum
global.mapa_final = "";

// golpes que o jogador aguenta (decisao de 30/10: com 1, horda seria morte certa;
// ajustar jogando)
#macro VIDA_MAX 5

// a vida passa de uma sala para a outra (o obj_player nasce de novo em cada uma).
// fase_curada: ate onde limpar a fase ja devolveu vida nesta run
// tecnicas: scr_tecnicas. No jogo a semente vem do relogio: cada run oferece outras. No robo,
// da contagem de runs: muda a cada run, e a rodada inteira se repete igual
global.runs_zeradas = 0;
function run_zerar() {
    global.vida = VIDA_MAX;
    global.fase_curada = -1;
    global.tecnicas = [];
    global.tecnica_inicio = true;
    global.runs_zeradas += 1;
    global.tecnica_semente = instance_exists(obj_autotest) ? 1000 + global.runs_zeradas * 97 : (current_time mod 2147483646) + 1;
}
// no codigo solto: a sala aberta direto pela IDE, sem passar pelo menu, tambem funciona
run_zerar();

// Frase da tela de morte: o guerreiro mais fraco aprendendo, sem cutscene. Por inimigo:
// [primeira vez, voltou a morrer ali]. Inimigo novo: acrescentar aqui, com o nome do objeto
global.frases_inimigo = {
    obj_enemy: ["O esqueleto avisou. Eu e que nao sai da frente.", "Esse esqueleto de novo... dessa vez eu desvio."],
    obj_enemy_ghoul: ["O ghoul so corre em linha reta. Era so sair do caminho.", "Esse ghoul de novo. Agora eu sei onde ele para."],
    obj_enemy_wight: ["O wight demora, mas quando varre, varre tudo.", "De novo esse wight. Depois da varredura ele fica exposto."],
    obj_enemy_arqueiro: ["A flecha avisou antes. Eu e que fiquei na linha.", "Esse arqueiro de novo. Agora eu corro de lado."],
    obj_enemy_conjurador: ["O circulo estava no chao. Eu e que fiquei em cima dele.", "O conjurador de novo. Da proxima eu vou atras dele primeiro."],
    obj_explosao: ["Ele explodiu depois de morrer. Eu devia ter saido de perto.", "De novo a explosao. Mata e corre."],
    obj_enemy_chefe: ["O rei morto nao tem pressa. Eu tive.", "O Trono de novo. A coluna para a investida."],
    obj_enemy_horda: ["Eram muitos. Da proxima eu abro caminho com o dash.", "A horda de novo. Parado eu nao saio daqui."],
};
global.frases_teimoso = [
    "Mais uma. O mais fraco de todos continua voltando.",
    "Eles nao aprendem. Eu sim.",
    "Nenhum guerreiro chegou tao longe morrendo tanto.",
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
    { sala: Room1, sprite: spr_mascara_fase01, passo: 4 },
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

// desenha o caminho na GUI, centrado em _cy. O marcador (o guerreiro) fica em
// _pos: 0 = primeira fase, 1 = segunda...; entre dois pontos, esta andando.
// -0.6 = ainda antes da primeira fase (saindo do menu)
function mapa_desenhar(_cy, _esc, _pos, _alpha) {
    var _w = display_get_gui_width();
    var _tem_final = (global.mapa_final != "");
    var _n = array_length(global.mapa_fases) + (_tem_final ? 1 : 0);
    var _x0 = _w * 0.16;
    var _x1 = _w * 0.84;
    var _passo = (_x1 - _x0) / (_n - 1);
    var _vermelho = make_colour_rgb(196, 22, 28);
    var _apagado = make_colour_rgb(70, 60, 60);
    var _pulso = 0.5 + 0.5 * sin(current_time / 180);

    draw_set_alpha(_alpha);
    // estrada: pintada ate onde o guerreiro chegou, tracejada dali em diante
    var _ate = _x0 + clamp(_pos, 0, _n - 1) * _passo;
    draw_line_width_colour(_x0, _cy, _ate, _cy, 4 * _esc, _vermelho, _vermelho);
    for (var _x = _ate; _x < _x1; _x += 14 * _esc) {
        draw_line_width_colour(_x, _cy, min(_x + 7 * _esc, _x1), _cy, 2 * _esc, _apagado, _apagado);
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    for (var _i = 0; _i < _n; _i++) {
        var _px = _x0 + _i * _passo;
        var _final = (_tem_final && _i == _n - 1);
        var _chegou = (_pos >= _i - 0.001);
        var _aqui = (abs(_pos - _i) < 0.001);
        var _r = (_final ? 13 : 10) * _esc;
        if (_final) {
            // final trancado: losango apagado
            draw_primitive_begin(pr_trianglefan);
            draw_vertex_colour(_px, _cy - _r, c_black, _alpha);
            draw_vertex_colour(_px + _r, _cy, c_black, _alpha);
            draw_vertex_colour(_px, _cy + _r, c_black, _alpha);
            draw_vertex_colour(_px - _r, _cy, c_black, _alpha);
            draw_primitive_end();
            draw_set_colour(_apagado);
            draw_line_width(_px, _cy - _r, _px + _r, _cy, 2 * _esc);
            draw_line_width(_px + _r, _cy, _px, _cy + _r, 2 * _esc);
            draw_line_width(_px, _cy + _r, _px - _r, _cy, 2 * _esc);
            draw_line_width(_px - _r, _cy, _px, _cy - _r, 2 * _esc);
            draw_set_colour(c_gray);
            draw_text_transformed(_px, _cy + 22 * _esc, global.mapa_final, _esc * 0.8, _esc * 0.8, 0);
            draw_set_colour(_apagado);
            draw_text_transformed(_px, _cy + 40 * _esc, "EM BREVE", _esc * 0.65, _esc * 0.65, 0);
            continue;
        }
        if (_aqui) {
            // fase atual: anel pulsando
            draw_set_colour(c_white);
            draw_set_alpha(_alpha * (0.3 + 0.5 * _pulso));
            draw_circle(_px, _cy, _r + (4 + 4 * _pulso) * _esc, true);
            draw_set_alpha(_alpha);
        }
        draw_set_colour(_chegou ? _vermelho : c_black);
        draw_circle(_px, _cy, _r, false);
        draw_set_colour(_chegou ? c_white : _apagado);
        draw_circle(_px, _cy, _r, true);
        draw_set_colour(_aqui ? c_white : (_chegou ? c_ltgray : c_gray));
        draw_text_transformed(_px, _cy + 22 * _esc, string(_i + 1) + ". " + global.mapa_fases[_i].nome, _esc * 0.8, _esc * 0.8, 0);
    }

    // o guerreiro andando pela estrada, de frente para a direita
    var _mx = _x0 + _pos * _passo;
    var _andando = (abs(_pos - round(_pos)) > 0.001);
    var _quadro = _andando ? (current_time div 120) mod 4 : 0;
    var _spr = _andando ? spr_player_walk : spr_player_idle;
    draw_sprite_ext(_spr, 1 * 4 + _quadro, _mx, _cy - 42 * _esc, 1.6 * _esc, 1.6 * _esc, 0, c_white, _alpha);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
