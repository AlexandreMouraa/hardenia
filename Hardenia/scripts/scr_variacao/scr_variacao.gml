// O que muda de uma run para a outra, alem das tecnicas: quem espera em cada sala. E o desafio do
// dia: a mesma run para todo mundo, com ranking proprio no site.
//
// Arranjos de cada sala. O primeiro e o da propria sala (vazio: nao mexe). Os outros: [objeto, x, y].
// Os mesmos tipos em outros lugares, ou uma troca que muda o jeito de lutar. Sala com elite
// (elites_sala, em scr_inimigos) tem de manter os tipos que ela usa. O robo passa por todos e
// reprova inimigo em parede ou sem caminho
global.arranjos = [
    // Ruinas: o original e 1, 2 e 2 (primeira camara, segunda, praca). Os outros mudam quem
    // espera na primeira camara, onde se aprende
    { sala: Room1, lista: [
        [],
        [[obj_enemy, 560, 740], [obj_enemy, 760, 880], [obj_enemy, 1250, 470], [obj_enemy, 1580, 1090], [obj_enemy, 1700, 1040]],
        [[obj_enemy, 680, 760], [obj_enemy, 1180, 540], [obj_enemy, 1330, 380], [obj_enemy, 1560, 1060], [obj_enemy, 1640, 960], [obj_enemy, 1760, 1130]],
    ] },
    { sala: Room_Tunel, lista: [
        [],
        [[obj_enemy, 400, 300], [obj_enemy_conjurador, 540, 260], [obj_enemy_arqueiro, 500, 420], [obj_enemy_arqueiro, 900, 640], [obj_enemy_wight, 1120, 640], [obj_enemy, 1010, 800], [obj_enemy_ghoul, 1600, 300], [obj_enemy_wight, 1760, 340], [obj_enemy, 1680, 220], [obj_enemy, 700, 1170], [obj_enemy_conjurador, 1540, 1120], [obj_enemy_arqueiro, 1740, 1120]],
        [[obj_enemy_wight, 400, 300], [obj_enemy, 540, 260], [obj_enemy, 500, 420], [obj_enemy, 900, 640], [obj_enemy_arqueiro, 1120, 640], [obj_enemy_conjurador, 1010, 800], [obj_enemy_arqueiro, 1600, 300], [obj_enemy, 1760, 340], [obj_enemy_conjurador, 1680, 220], [obj_enemy_ghoul, 700, 1170], [obj_enemy_arqueiro, 1540, 1120], [obj_enemy_wight, 1740, 1120]],
    ] },
    // Patio: dois no patio central e um em cada ala, do outro lado das pontes. Com arqueiro
    // na ala, atravessar a ponte custa; o ultimo guarda o patio da saida. O defensor e o curandeiro
    // (PR #90) ficam sempre perto de um aliado: o curandeiro sozinho numa ala nao teria quem curar
    { sala: Room2, lista: [
        [],
        [[obj_enemy_defensor, 870, 780], [obj_enemy_curandeiro, 1130, 820], [obj_enemy_ghoul, 360, 1000], [obj_enemy_arqueiro, 1640, 1000]],
        [[obj_enemy_defensor, 870, 780], [obj_enemy_ghoul, 1130, 820], [obj_enemy_arqueiro, 360, 980], [obj_enemy_ghoul, 1640, 980], [obj_enemy_curandeiro, 820, 1240], [obj_enemy, 1180, 1240]],
    ] },
    // Cemiterio: um wight em cada campo de lapides e dois na praca da estatua. O primeiro e o
    // terceiro wight sao as elites (escudo e invocacao). Com o arqueiro no patio da saida, o
    // atalho apertado fica na mira dele
    { sala: Room3, lista: [
        [],
        [[obj_enemy_wight, 400, 500], [obj_enemy_wight, 860, 800], [obj_enemy_wight, 1610, 815], [obj_enemy_conjurador, 1140, 760], [obj_enemy_arqueiro, 1000, 1330]],
        [[obj_enemy_wight, 400, 500], [obj_enemy_wight, 860, 800], [obj_enemy_wight, 1610, 815], [obj_enemy_ghoul, 1140, 800], [obj_enemy_ghoul, 1600, 950]],
    ] },
];

// sorteio proprio, a partir da semente da run: quem joga o desafio ve o mesmo que os outros, mesmo
// escolhendo outras cartas. Quem esta comecando ve as Ruinas como elas sao
function arranjo_indice(_fase, _n) {
    if (instance_exists(obj_autotest)) {
        return global.runs_zeradas mod _n;
    }
    if (_fase == 0 && global.tentativas == 1 && !global.desafio) {
        return 0;
    }
    return (((global.run_semente + _fase * 104729) * 16807) mod 2147483647) mod _n;
}

// chamada no primeiro frame da sala (obj_player, Step), antes das elites
function arranjo_aplicar() {
    for (var _a = 0; _a < array_length(global.arranjos); _a++) {
        var _def = global.arranjos[_a];
        if (_def.sala == room) {
            var _lista = _def.lista[arranjo_indice(mapa_indice(room), array_length(_def.lista))];
            if (array_length(_lista) > 0) {
                instance_destroy(obj_enemy);
                for (var _i = 0; _i < array_length(_lista); _i++) {
                    instance_create_layer(_lista[_i][1], _lista[_i][2], "Instances", _lista[_i][0]);
                }
            }
            return;
        }
    }
}

// ---------- ondas: limpar a sala traz a leva seguinte ----------
// Os lideres pediram uma run de uns 15 minutos (12/11/2026); a vencedora levava de 2,6 a 6. Em vez
// de mapas novos, cada sala tem 2 ou 3 levas, tiradas dos arranjos dela (os mesmos lugares, outra
// leva). O bau, o portao e o Caido vem depois da ultima. O Trono fica com uma so
global.ondas_sala = [
    { sala: Room1, n: 2 },
    { sala: Room_Tunel, n: 3 },
    { sala: Room2, n: 3 },
    { sala: Room3, n: 3 },
];
global.onda = 1;          // a leva atual desta sala
global.onda_espera = 0;   // frames desde que a leva acabou; a proxima vem com 50 (um respiro)
global.onda_aviso = 0;    // frames do aviso "ONDA 2 DE 3" na tela
global.ondas_feitas = 0;  // levas chamadas nesta sessao (o robo registra)

function ondas_total(_sala = room) {
    for (var _i = 0; _i < array_length(global.ondas_sala); _i++) {
        if (global.ondas_sala[_i].sala == _sala) {
            return global.ondas_sala[_i].n;
        }
    }
    return 1;
}

function onda_pendente() {
    return global.onda < ondas_total();
}

// a proxima leva: o arranjo seguinte ao da sala (pulando o vazio, que e a propria sala), nos
// lugares dele, ja acordada e atras do jogador
function onda_proxima() {
    global.onda += 1;
    global.ondas_feitas += 1;
    global.onda_aviso = 90;
    global.onda_espera = 0;
    for (var _a = 0; _a < array_length(global.arranjos); _a++) {
        var _def = global.arranjos[_a];
        if (_def.sala != room) {
            continue;
        }
        var _n = array_length(_def.lista);
        var _base = arranjo_indice(mapa_indice(room), _n);
        var _lista = [];
        for (var _k = 1; _k <= _n && array_length(_lista) == 0; _k++) {
            _lista = _def.lista[(_base + (global.onda - 1) * _k) mod _n];
        }
        for (var _i = 0; _i < array_length(_lista); _i++) {
            var _e = instance_create_layer(_lista[_i][1], _lista[_i][2], "Instances", _lista[_i][0]);
            fx_onda(_lista[_i][1], _lista[_i][2], 70, make_colour_rgb(200, 40, 40));
            with (_e) {
                if (instance_exists(obj_player)) {
                    acordado = true;
                    alerta = 30;
                    memoria_x = obj_player.x;
                    memoria_y = obj_player.y;
                    procura = procura_max;
                }
            }
        }
        break;
    }
    sfx(snd_sino, 1, false, 0.9);
}

// ---------- desafio do dia ----------
// o dia e o de Greenwich: o mesmo para todo mundo, em qualquer fuso
function desafio_hoje() {
    var _fuso = date_get_timezone();
    date_set_timezone(timezone_utc);
    var _d = date_current_datetime();
    var _s = string(date_get_year(_d)) + "-" + string_replace_all(string_format(date_get_month(_d), 2, 0), " ", "0") + "-" + string_replace_all(string_format(date_get_day(_d), 2, 0), " ", "0");
    date_set_timezone(_fuso);
    return _s;
}

function desafio_semente() {
    var _partes = string_split(global.desafio_dia, "-");
    var _dias = real(_partes[0]) * 372 + real(_partes[1]) * 31 + real(_partes[2]);
    return ((_dias * 48271) mod 2147483646) + 1;
}
