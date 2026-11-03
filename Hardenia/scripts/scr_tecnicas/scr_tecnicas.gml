// Tecnicas dos Caidos: o que o guerreiro aprende com quem morreu antes dele. Ele continua sem
// poderes, so aprendeu. Valem ate a proxima morte: a run seguinte comeca sem nenhuma, e nada
// passa de uma run para a outra. Sao uma ao comecar a run e uma por sala limpa, no bau que o
// ultimo inimigo deixa (obj_bau). A tela de escolha e o obj_tecnicas.
// Tecnica nova: acrescentar aqui e tratar o efeito (para ver onde, busque a chave no projeto).
// Textos sem acento: a fonte do jogo nao tem esses caracteres
global.caidos = {
    carrasco: { nome: "O CARRASCO", cor: make_colour_rgb(225, 70, 70) },
    batedor: { nome: "O BATEDOR", cor: make_colour_rgb(95, 205, 235) },
    sapador: { nome: "O SAPADOR", cor: make_colour_rgb(255, 155, 55) },
    sentinela: { nome: "A SENTINELA", cor: make_colour_rgb(240, 210, 110) },
};
global.tecnicas_lista = [
    { chave: "sangria", caido: "carrasco", nome: "SANGRIA", texto: "Quem leva um golpe sangra, e perde vida por mais 3 segundos." },
    { chave: "execucao", caido: "carrasco", nome: "EXECUCAO", texto: "Golpe forte mata quem ficaria com pouca vida. No chefe, dobra o dano quando ele esta no fim." },
    { chave: "passo_cortante", caido: "batedor", nome: "PASSO CORTANTE", texto: "O dash corta todo inimigo que ele atravessa." },
    { chave: "folego", caido: "batedor", nome: "FOLEGO", texto: "Uma carga de dash a mais, e as cargas voltam mais rapido." },
    { chave: "bomba_combo", caido: "sapador", nome: "BOMBA DE MAO", texto: "Golpe forte tambem arremessa uma bomba no alvo." },
    { chave: "polvora", caido: "sapador", nome: "RASTRO DE POLVORA", texto: "O giro deixa quatro bombas em volta, que explodem logo depois." },
    { chave: "ultimo_instante", caido: "sentinela", nome: "ULTIMO INSTANTE", texto: "Dash na hora do golpe inimigo: o tempo desacelera e o proximo golpe dobra." },
    { chave: "retribuicao", caido: "sentinela", nome: "RETRIBUICAO", texto: "Ao levar um golpe, uma onda fere e empurra todos em volta." },
];
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

// ate 3 que ele ainda nao tem, de Caidos diferentes quando da
function tecnicas_sortear() {
    var _resto = [];
    for (var _i = 0; _i < array_length(global.tecnicas_lista); _i++) {
        if (!tem_tecnica(global.tecnicas_lista[_i].chave)) {
            array_push(_resto, global.tecnicas_lista[_i]);
        }
    }
    for (var _i = array_length(_resto) - 1; _i > 0; _i--) {
        var _j = tecnica_dado(_i + 1);
        var _troca = _resto[_i];
        _resto[_i] = _resto[_j];
        _resto[_j] = _troca;
    }
    var _oferta = [];
    var _vistos = {};
    for (var _i = 0; _i < array_length(_resto) && array_length(_oferta) < 3; _i++) {
        if (!variable_struct_exists(_vistos, _resto[_i].caido)) {
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
        } else if (_enemy.hp - _dano <= 2) {
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
