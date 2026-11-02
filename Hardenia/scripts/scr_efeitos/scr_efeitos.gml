// Efeitos de impacto (game feel): micro-pausa, tremor de camera e faiscas.
// Tudo desenhado em codigo, sem sprite novo. O codigo solto roda ao abrir o jogo.

// frames em que o mundo congela depois de um golpe (jogador, inimigos e golpes
// param juntos, entao nao muda a justica do combate)
global.hitstop = 0;
// amplitude do tremor da camera, em pixels; decai sozinho (obj_player, End Step)
global.tremor = 0;
// camera lenta: frames que ainda faltam (obj_player, Step)
global.lento = 0;
// clarao na tela inteira, de 0 a 1; apaga sozinho (obj_player, Step e Draw GUI)
global.flash = 0;
// empurrao da camera na direcao do golpe, em pixels; volta sozinho (obj_player, End Step)
global.chute_x = 0;
global.chute_y = 0;

// efeito sonoro com o tom variando um pouco, sem random (o robo depende do RNG). No
// mesmo instante toca um so: uma horda morrendo de uma vez viraria um estouro, e no
// navegador cada som pesa. current_time e do relogio, nao entra na conta do jogo
global.som_contador = 0;
global.som_ultimo = {};
function som(_som, _ganho = 1) {
    var _nome = audio_get_name(_som);
    if (variable_struct_exists(global.som_ultimo, _nome) && current_time - variable_struct_get(global.som_ultimo, _nome) < 50) {
        exit;
    }
    variable_struct_set(global.som_ultimo, _nome, current_time);
    global.som_contador += 1;
    audio_play_sound(_som, 1, false, _ganho, 0, 1 + 0.06 * sin(global.som_contador * 2.4));
}

function impacto(_hitstop, _tremor) {
    global.hitstop = max(global.hitstop, _hitstop);
    global.tremor = max(global.tremor, _tremor);
}

function chute_camera(_dir, _forca) {
    global.chute_x = lengthdir_x(_forca, _dir);
    global.chute_y = lengthdir_y(_forca, _dir);
}

// o golpe que limpou a sala: tempo lento, zoom e clarao. _peso 1 na sala comum, 2 no chefe
function momento_final(_x, _y, _peso) {
    global.lento = max(global.lento, 40 * _peso);
    global.flash = max(global.flash, 0.3 * _peso);
    fx_onda(_x, _y, 150 * _peso, make_colour_rgb(255, 225, 180));
    audio_play_sound(snd_golpe_forte, 1, false, 1, 0, 0.55);
}

// numero do dano, subindo e sumindo. O lado alterna para dois seguidos nao ficarem um em
// cima do outro (contador, sem random)
global.numero_lado = 1;
function fx_numero(_x, _y, _valor, _cor) {
    global.numero_lado *= -1;
    var _lado = global.numero_lado;
    with (instance_create_depth(_x + 14 * _lado, _y - 24, -1001, obj_fx)) {
        tipo = "numero";
        texto = string(_valor);
        cor = _cor;
        vida_max = 34;
        vida = vida_max;
    }
}

// onda que abre ate _raio e some: fim do combo, e o golpe que limpa a sala
function fx_onda(_x, _y, _raio, _cor) {
    with (instance_create_depth(_x, _y, -999, obj_fx)) {
        tipo = "onda";
        raio = _raio;
        cor = _cor;
        vida_max = 16;
        vida = vida_max;
    }
}

// faiscas saindo de (x, y); _dir e para onde o golpe empurrou
function fx_faiscas(_x, _y, _dir, _cor, _qtd) {
    with (instance_create_depth(_x, _y, -1000, obj_fx)) {
        tipo = "faisca";
        cor = _cor;
        vida_max = 14;
        vida = vida_max;
        // angulos fixos por instancia: espalhados em leque para o lado do golpe
        angulos = [];
        for (var _i = 0; _i < _qtd; _i++) {
            angulos[_i] = _dir - 70 + 140 * (_i + 0.5) / _qtd + 12 * sin(_i * 2.7);
        }
    }
}

// risco de luz atravessando quem levou o golpe. _dir e o rumo do golpe: o risco fica de
// atravessado. O lado alterna para dois golpes seguidos nao riscarem igual (contador, sem random)
global.corte_lado = 1;
function fx_corte(_x, _y, _dir, _cor, _meia) {
    global.corte_lado *= -1;
    with (instance_create_depth(_x, _y, -1000, obj_fx)) {
        tipo = "corte";
        dir = _dir + 65 * global.corte_lado;
        cor = _cor;
        raio = _meia;
        espessura = 5;
        vida_max = 8;
        vida = vida_max;
    }
}

// explosao: clarao no chao, anel ate a borda da zona (_raio), faiscas e fumaca que fica depois.
// So tremor, sem micro-pausa: quem muda o ritmo do jogo nao e efeito
function fx_explosao(_x, _y, _raio) {
    impacto(0, 7);
    with (instance_create_depth(_x, _y, 50, obj_fx)) {
        tipo = "explosao";
        raio = _raio;
        cor = make_colour_rgb(255, 130, 40);
        vida_max = 26;
        vida = vida_max;
        angulos = [];
        distancias = [];
        for (var _i = 0; _i < 7; _i++) {
            angulos[_i] = _i * 360 / 7 + 11 * sin(_i * 2.7);
            distancias[_i] = _raio * (0.35 + 0.3 * (0.5 + 0.5 * sin(_i * 1.9 + 1)));
        }
    }
    fx_faiscas(_x, _y, 90, make_colour_rgb(255, 200, 110), 10);
    fx_faiscas(_x, _y, 270, make_colour_rgb(255, 150, 60), 10);
}

// arrancada do dash: anel no chao e poeira saindo para tras. _dir e para onde
// o dash vai. Angulos e distancias fixos (sem random: o robo depende do RNG).
// Profundidade 50: entre o fundo (100) e os personagens (0)
function fx_dash_arrancada(_x, _y, _dir) {
    with (instance_create_depth(_x, _y + 14, 50, obj_fx)) {
        tipo = "anel";
        cor = make_colour_rgb(255, 150, 140);
        vida_max = 12;
        vida = vida_max;
    }
    with (instance_create_depth(_x, _y + 14, 50, obj_fx)) {
        tipo = "poeira";
        cor = make_colour_rgb(195, 175, 160);
        vida_max = 20;
        vida = vida_max;
        angulos = [];
        distancias = [];
        var _qtd = 7;
        for (var _i = 0; _i < _qtd; _i++) {
            angulos[_i] = _dir + 180 - 55 + 110 * (_i + 0.5) / _qtd + 9 * sin(_i * 2.7);
            distancias[_i] = 14 + 10 * (0.5 + 0.5 * sin(_i * 1.9 + 1));
        }
    }
}

// risco de velocidade do dash, de (x1, y1) a (x2, y2): duas linhas finas na
// altura dos ombros, que somem rapido. Logo atras dos personagens
function fx_risco(_x1, _y1, _x2, _y2, _cor) {
    if (point_distance(_x1, _y1, _x2, _y2) < 1) {
        exit;
    }
    with (instance_create_depth(_x1, _y1, 1, obj_fx)) {
        tipo = "risco";
        cor = _cor;
        x2 = _x2;
        y2 = _y2;
        vida_max = 8;
        vida = vida_max;
    }
}
