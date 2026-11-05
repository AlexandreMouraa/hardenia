// O que muda de uma run para a outra, alem das tecnicas: quem espera em cada sala. E o desafio do
// dia: a mesma run para todo mundo, com ranking proprio no site.
//
// Arranjos de cada sala. O primeiro e o da propria sala (vazio: nao mexe). Os outros: [objeto, x, y].
// Os mesmos tipos em outros lugares, ou uma troca que muda o jeito de lutar. Sala com elite
// (elites_sala, em scr_inimigos) tem de manter os tipos que ela usa. O robo passa por todos e
// reprova inimigo em parede ou sem caminho
global.arranjos = [
    { sala: Room1, lista: [
        [],
        [[obj_enemy, 240, 240], [obj_enemy, 330, 370], [obj_enemy, 1248, 288], [obj_enemy, 1160, 340]],
        [[obj_enemy, 560, 360], [obj_enemy, 930, 330], [obj_enemy, 750, 240], [obj_enemy, 240, 768]],
    ] },
    { sala: Room_Tunel, lista: [
        [],
        [[obj_enemy, 400, 300], [obj_enemy_conjurador, 540, 260], [obj_enemy_arqueiro, 500, 420], [obj_enemy_arqueiro, 900, 640], [obj_enemy_wight, 1120, 640], [obj_enemy, 1010, 800], [obj_enemy_ghoul, 1600, 300], [obj_enemy_wight, 1760, 340], [obj_enemy, 1680, 220], [obj_enemy, 700, 1170], [obj_enemy_conjurador, 1540, 1120], [obj_enemy_arqueiro, 1740, 1120]],
        [[obj_enemy_wight, 400, 300], [obj_enemy, 540, 260], [obj_enemy, 500, 420], [obj_enemy, 900, 640], [obj_enemy_arqueiro, 1120, 640], [obj_enemy_conjurador, 1010, 800], [obj_enemy_arqueiro, 1600, 300], [obj_enemy, 1760, 340], [obj_enemy_conjurador, 1680, 220], [obj_enemy_ghoul, 700, 1170], [obj_enemy_arqueiro, 1540, 1120], [obj_enemy_wight, 1740, 1120]],
    ] },
    { sala: Room2, lista: [
        [],
        [[obj_enemy_defensor, 400, 350], [obj_enemy_curandeiro, 400, 510], [obj_enemy_ghoul, 400, 674], [obj_enemy_arqueiro, 1136, 674]],
        [[obj_enemy_arqueiro, 400, 350], [obj_enemy_ghoul, 1136, 350], [obj_enemy_defensor, 400, 674], [obj_enemy_ghoul, 1136, 674], [obj_enemy_curandeiro, 1136, 480], [obj_enemy, 768, 880]],
    ] },
    { sala: Room3, lista: [
        [],
        [[obj_enemy_wight, 400, 350], [obj_enemy_wight, 1136, 350], [obj_enemy_wight, 400, 674], [obj_enemy_conjurador, 768, 760], [obj_enemy_arqueiro, 1136, 674]],
        [[obj_enemy_wight, 400, 674], [obj_enemy_wight, 1136, 674], [obj_enemy_wight, 768, 700], [obj_enemy_ghoul, 400, 350], [obj_enemy_ghoul, 1136, 350]],
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
