// Tecnicas dos Caidos: o que o guerreiro aprende com quem morreu antes dele. Ele continua sem
// poderes, so aprendeu. Valem ate a proxima morte: a run seguinte comeca sem nenhuma, e nada
// passa de uma run para a outra. Sao uma ao comecar a run e uma por sala limpa, no bau que o
// ultimo inimigo deixa (obj_bau). A tela de escolha e o obj_tecnicas.
// Tecnica nova: acrescentar aqui e tratar o efeito (para ver onde, busque a chave no projeto).
// Combinacao: tem "requer", e so aparece para quem ja tem uma de cada grupo. Vem na primeira
// carta, porque e a recompensa por ter juntado duas tecnicas.
global.caidos = {
    carrasco: {
        nome: "O CARRASCO", titulo: "O Carrasco", cor: make_colour_rgb(225, 70, 70),
        fala: "Cortei cem cabeças por este reino. A sua não faz diferença.",
        de_novo: "Você de novo. Ainda com a cabeça no lugar?",
        adeus: "Enfim, o machado pesa menos.",
    },
    batedor: {
        nome: "O BATEDOR", titulo: "O Batedor", cor: make_colour_rgb(95, 205, 235),
        fala: "Fui o primeiro a chegar. Por isso fui o primeiro a cair.",
        de_novo: "De novo? Você é lento, mas é teimoso.",
        adeus: "Corre. Eu já não preciso.",
    },
    sapador: {
        nome: "O SAPADOR", titulo: "O Sapador", cor: make_colour_rgb(255, 155, 55),
        fala: "Este castelo ia cair com uma mecha só. A mecha era eu.",
        de_novo: "Cuidado onde pisa. Da última vez você não teve.",
        adeus: "Não olhe para trás. Vai explodir.",
    },
    sentinela: {
        nome: "A SENTINELA", titulo: "A Sentinela", cor: make_colour_rgb(240, 210, 110),
        fala: "Jurei guardar este caminho. Ninguém me disse que era para sempre.",
        de_novo: "Ainda de pé. Eu também, infelizmente.",
        adeus: "Pode passar.",
    },
};
global.fala_rei = "Mais um. O reino ainda tem guerreiros para me mandar?";
global.fala_rei_de_novo = "Você de novo. Eu também voltei, um dia.";
global.fala_rei_fase2 = "Levantem-se.";
global.fala_rei_fase3 = "Eu também fui o último.";
global.tecnicas_lista = [
    { chave: "sangria", caido: "carrasco", nome: "SANGRIA", texto: "Quem leva um golpe sangra, e perde vida por mais 3 segundos." },
    { chave: "execucao", caido: "carrasco", nome: "EXECUÇÃO", texto: "Golpe forte mata quem ficaria com pouca vida. No chefe, dobra o dano quando ele está no fim." },
    { chave: "passo_cortante", caido: "batedor", nome: "PASSO CORTANTE", texto: "O dash corta todo inimigo que ele atravessa." },
    { chave: "folego", caido: "batedor", nome: "FÔLEGO", texto: "Uma carga de dash a mais, e as cargas voltam mais rápido." },
    { chave: "bomba_combo", caido: "sapador", nome: "BOMBA DE MÃO", texto: "Golpe forte também arremessa uma bomba no alvo." },
    { chave: "polvora", caido: "sapador", nome: "RASTRO DE PÓLVORA", texto: "O giro deixa quatro bombas em volta, que explodem logo depois." },
    { chave: "ultimo_instante", caido: "sentinela", nome: "ÚLTIMO INSTANTE", texto: "Dash na hora do golpe inimigo: o tempo desacelera e o próximo golpe dobra." },
    { chave: "retribuicao", caido: "sentinela", nome: "RETRIBUIÇÃO", texto: "Ao levar um golpe, uma onda fere e empurra todos em volta." },
    { chave: "hora_certa", caido: "sentinela", nome: "HORA CERTA", texto: "Golpe em inimigo apagado, logo depois do ataque dele, vale o dobro." },
    { chave: "sangue_polvora", caido: "carrasco", caido2: "sapador", nome: "SANGUE E PÓLVORA", texto: "Quem morre sangrando explode e fere quem está perto.", requer: [["sangria"], ["bomba_combo", "polvora"]] },
    { chave: "rastilho", caido: "batedor", caido2: "sapador", nome: "RASTILHO", texto: "Cada dash deixa uma bomba no lugar de onde saiu.", requer: [["passo_cortante", "folego"], ["bomba_combo", "polvora"]] },
    { chave: "sentenca", caido: "carrasco", caido2: "sentinela", nome: "SENTENÇA", texto: "Todo golpe em quem está sangrando tira 1 a mais.", requer: [["sangria"], ["ultimo_instante", "retribuicao", "hora_certa"]] },
    { chave: "contra_passo", caido: "batedor", caido2: "sentinela", nome: "CONTRA-PASSO", texto: "Desviar no último instante devolve a carga do dash e enche um quarto da Fúria.", requer: [["ultimo_instante"], ["passo_cortante", "folego"]] },
];
// Furia: acertar enche a barra, que passa de uma sala para a outra e zera com a morte. Cheia,
// continuar segurando o especial solta o Giro Furioso, mesmo com o giro em recarga
#macro FURIA_MAX 100
function furia_ganhar(_quanto) {
    global.furia = min(FURIA_MAX, global.furia + _quanto);
}
// giros furiosos nesta sessao (o robo registra)
global.giros_furiosos = 0;

// quantas vezes cada tecnica fez efeito, nesta sessao (o robo registra)
global.tecnica_usos = {};

function tem_tecnica(_chave) {
    return array_contains(global.tecnicas, _chave);
}

function tecnica_contar(_chave) {
    var _n = variable_struct_exists(global.tecnica_usos, _chave) ? variable_struct_get(global.tecnica_usos, _chave) : 0;
    variable_struct_set(global.tecnica_usos, _chave, _n + 1);
}

function tecnica_def(_chave) {
    for (var _i = 0; _i < array_length(global.tecnicas_lista); _i++) {
        if (global.tecnicas_lista[_i].chave == _chave) {
            return global.tecnicas_lista[_i];
        }
    }
    return undefined;
}

// sorteio com gerador proprio: a sequencia aleatoria do jogo fica como esta, e o robo depende
// dela. A semente sai em run_zerar (scr_mapa)
function tecnica_dado(_n) {
    global.tecnica_semente = (global.tecnica_semente * 16807) mod 2147483647;
    return global.tecnica_semente mod _n;
}

function tecnicas_restantes() {
    return array_length(global.tecnicas_lista) - array_length(global.tecnicas);
}

// a combinacao pede uma tecnica de cada grupo
function combinacao_liberada(_def) {
    for (var _g = 0; _g < array_length(_def.requer); _g++) {
        var _tem = false;
        for (var _k = 0; _k < array_length(_def.requer[_g]); _k++) {
            _tem = _tem || tem_tecnica(_def.requer[_g][_k]);
        }
        if (!_tem) {
            return false;
        }
    }
    return true;
}

// ate 3 que ele ainda nao tem, de Caidos diferentes quando da. Uma combinacao liberada vem
// primeiro, no maximo uma por vez. Depois de um duelo, o que aquele Caido deixou vem antes do resto
function tecnicas_sortear() {
    var _resto = [];
    var _combinacoes = [];
    for (var _i = 0; _i < array_length(global.tecnicas_lista); _i++) {
        var _d = global.tecnicas_lista[_i];
        if (tem_tecnica(_d.chave)) {
            continue;
        }
        if (!variable_struct_exists(_d, "requer")) {
            array_push(_resto, _d);
        } else if (combinacao_liberada(_d)) {
            array_push(_combinacoes, _d);
        }
    }
    for (var _i = array_length(_resto) - 1; _i > 0; _i--) {
        var _j = tecnica_dado(_i + 1);
        var _troca = _resto[_i];
        _resto[_i] = _resto[_j];
        _resto[_j] = _troca;
    }
    var _oferta = [];
    if (array_length(_combinacoes) > 0) {
        array_push(_oferta, _combinacoes[tecnica_dado(array_length(_combinacoes))]);
    }
    if (global.caido_vencido != "") {
        for (var _i = 0; _i < array_length(_resto) && array_length(_oferta) < 3; _i++) {
            if (_resto[_i].caido == global.caido_vencido) {
                array_push(_oferta, _resto[_i]);
            }
        }
    }
    var _vistos = {};
    for (var _i = 0; _i < array_length(_resto) && array_length(_oferta) < 3; _i++) {
        if (!array_contains(_oferta, _resto[_i]) && !variable_struct_exists(_vistos, _resto[_i].caido)) {
            variable_struct_set(_vistos, _resto[_i].caido, true);
            array_push(_oferta, _resto[_i]);
        }
    }
    for (var _i = 0; _i < array_length(_resto) && array_length(_oferta) < 3; _i++) {
        if (!array_contains(_oferta, _resto[_i])) {
            array_push(_oferta, _resto[_i]);
        }
    }
    return _oferta;
}

function tecnica_ganhar(_chave) {
    array_push(global.tecnicas, _chave);
    with (obj_player) {
        tecnicas_aplicar();
    }
}

// o portao espera o bau: sem isso daria para sair sem nem ver a escolha
function portao_aberto() {
    if (instance_number(obj_enemy) > 0 || instance_exists(obj_tecnicas)) {
        return false;
    }
    var _fechado = false;
    with (obj_bau) {
        if (!aberto) {
            _fechado = true;
        }
    }
    return !_fechado;
}

// ---------- efeitos ----------

// o que as tecnicas mudam no golpe que acabou de acertar. Devolve o dano
function tecnicas_no_golpe(_enemy, _dano, _forte) {
    if (_enemy.state == 3 && tem_tecnica("hora_certa")) {
        _dano *= 2;
        tecnica_contar("hora_certa");
    }
    // antes de marcar a sangria: vale para quem ja estava sangrando
    if (_enemy.sangra > 0 && tem_tecnica("sentenca")) {
        _dano += 1;
        tecnica_contar("sentenca");
    }
    if (tem_tecnica("sangria")) {
        _enemy.sangra = 3;
        _enemy.sangra_timer = 60;
    }
    if (_forte && tem_tecnica("execucao")) {
        if (_enemy.imovel) {
            // chefe: nao morre de uma vez. So no ultimo quarto da vida o golpe dobra
            if (_enemy.hp <= _enemy.hp_max / 4) {
                _dano *= 2;
                tecnica_contar("execucao");
            }
        } else if (_enemy.hp - _dano <= 1) {
            _dano = _enemy.hp;
            tecnica_contar("execucao");
        }
    }
    return _dano;
}

// um tique de sangria. Roda no inimigo. Devolve se ele morreu
function sangria_tique() {
    hp -= 0.4;
    hit_flash = 4;
    fx_faiscas(x, y, 270, make_colour_rgb(200, 30, 40), 4);
    if (!leve) {
        fx_numero(x, bbox_top, 4, make_colour_rgb(235, 80, 80));
    }
    tecnica_contar("sangria");
    if (hp <= 0) {
        inimigo_morrer(id, 270, false);
        return true;
    }
    return false;
}

// o jogador comecou um dash agora, e o golpe ja ia acertar?
function perigo_iminente() {
    var _perigo = false;
    with (obj_enemy) {
        if (state == 1 && state_timer <= 22 && zona_acerta_jogador(zona)) {
            _perigo = true;
        }
    }
    with (obj_explosao) {
        if (estado == 1 && tempo <= 22 && zona_acerta_jogador(zona)) {
            _perigo = true;
        }
    }
    var _p = instance_find(obj_player, 0);
    with (obj_flecha) {
        if (segmento_toca_retangulo(x, y, x + lengthdir_x(velocidade * 16, direcao), y + lengthdir_y(velocidade * 16, direcao), _p.bbox_left, _p.bbox_top, _p.bbox_right, _p.bbox_bottom)) {
            _perigo = true;
        }
    }
    return _perigo;
}

// quem esta em volta de (_x, _y) leva um golpe
function golpe_em_volta(_x, _y, _raio, _dano, _knockback, _forte, _quebra) {
    var _lista = ds_list_create();
    var _n = collision_circle_list(_x, _y, _raio, obj_enemy, false, true, _lista, false);
    for (var _i = 0; _i < _n; _i++) {
        var _e = _lista[| _i];
        if (collision_line(_x, _y, _e.x, _e.y, obj_wall, false, true) == noone) {
            golpe_acertar(_e, _dano, _knockback, _forte, _quebra);
        }
    }
    ds_list_destroy(_lista);
    return _n;
}

// bomba do Sapador: _voo frames no ar ate (_px, _py); depois espera _espera frames no chao
function bomba_jogador(_x, _y, _px, _py, _voo, _espera, _dano) {
    with (instance_create_layer(_x, _y, "Instances", obj_bomba_jogador)) {
        de_x = _x;
        de_y = _y;
        para_x = _px;
        para_y = _py;
        voo = _voo;
        espera = _espera;
        dano = _dano;
    }
}
