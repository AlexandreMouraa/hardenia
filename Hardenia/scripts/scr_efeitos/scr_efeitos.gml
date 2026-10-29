// Efeitos de impacto (game feel): micro-pausa, tremor de camera e faiscas.
// Tudo desenhado em codigo, sem sprite novo. O codigo solto roda ao abrir o jogo.

// frames em que o mundo congela depois de um golpe (jogador, inimigos e golpes
// param juntos, entao nao muda a justica do combate)
global.hitstop = 0;
// amplitude do tremor da camera, em pixels; decai sozinho (obj_player, End Step)
global.tremor = 0;

function impacto(_hitstop, _tremor) {
    global.hitstop = max(global.hitstop, _hitstop);
    global.tremor = max(global.tremor, _tremor);
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
