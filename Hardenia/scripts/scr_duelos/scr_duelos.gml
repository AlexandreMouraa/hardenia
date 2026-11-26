// Os grandes inimigos: o chefe e os Caidos. Eles usam o mesmo rodizio de ataques, sempre com
// aviso e zona marcada, e a mesma barra de vida no alto da tela.
//
// Cada ataque do rodizio: { sprite, quadros, ataque: { tipo e os campos de scr_inimigos } }
//   tipo "arco" e "investida": golpes comuns. Na investida a linha para na parede
//   tipo "bombas": marca o jogador e uma bomba cai ali; extras: quantas mais em volta dele
//   tipo "estouro": circulo em volta de quem ataca, para quem ficou colado
//   tipo "leque": a linha e mais duas por lado (extras); so se sai delas de lado

// escolhe o proximo ataque. Aviso e recarga encurtam com a furia
function rodizio_trocar() {
    var _a = ataques[ataque_vez];
    ataque_sprite = _a.sprite;
    ataque_frames = _a.quadros;
    ataque = {
        tipo: _a.ataque.tipo,
        forma: _a.ataque.forma,
        gatilho: _a.ataque.gatilho,
        alcance: _a.ataque.alcance,
        alcance_max: _a.ataque.alcance,
        tamanho: _a.ataque.tamanho,
        aviso: round(_a.ataque.aviso * furia),
        duracao: _a.ataque.duracao,
        acerto: _a.ataque.acerto,
        recarga: round(_a.ataque.recarga * furia),
        avanco: _a.ataque.avanco,
        extras: variable_struct_exists(_a.ataque, "extras") ? _a.ataque.extras : 0,
    };
    zona_fixa = (ataque.forma == "circulo");
    bomba = (ataque.tipo == "bombas");
    ataque_vez = (ataque_vez + 1) mod array_length(ataques);
}

// na hora de mirar, com attack_dir ja definido
function rodizio_mirar() {
    var _causa = object_get_name(object_index);
    switch (ataque.tipo) {
        case "investida":
            ataque.alcance = linha_ate_parede(x, y, attack_dir, ataque.alcance_max);
            break;

        case "bombas":
            ataque.alcance = point_distance(x, y, obj_player.x, obj_player.y);
            som(snd_bomba_cai);
            // em volta do jogador, em lados fixos
            for (var _i = 0; _i < ataque.extras; _i++) {
                var _ang = attack_dir + 60 + _i * 360 / ataque.extras;
                var _cx = obj_player.x + lengthdir_x(170, _ang);
                var _cy = obj_player.y + lengthdir_y(170, _ang);
                if (collision_point(_cx, _cy, obj_wall, false, true) == noone) {
                    var _aviso = ataque.aviso;
                    with (instance_create_layer(_cx, _cy, "Instances", obj_explosao)) {
                        causa = _causa;
                        aviso = _aviso;
                        tempo = _aviso;
                        bomba = true;
                    }
                }
            }
            break;

        case "leque":
            ataque.alcance = linha_ate_parede(x, y, attack_dir, ataque.alcance_max);
            for (var _lado = -1; _lado <= 1; _lado += 2) {
                for (var _k = 1; _k <= ataque.extras; _k++) {
                    var _dir = attack_dir + _lado * _k * 30;
                    var _z = zona_criar({ forma: "linha", alcance: linha_ate_parede(x, y, _dir, ataque.alcance_max), tamanho: ataque.tamanho }, x, y, _dir);
                    var _aviso_l = ataque.aviso;
                    with (instance_create_layer(x, y, "Instances", obj_explosao)) {
                        causa = _causa;
                        zona = _z;
                        aviso = _aviso_l;
                        tempo = _aviso_l;
                        explode = false;
                        cor = make_colour_rgb(200, 40, 40);
                    }
                }
            }
            break;
    }
}

// o que sai quando o aviso acaba, antes do golpe comum (disparar_golpe)
function rodizio_disparar() {
    switch (ataque.tipo) {
        case "bombas":
            // a bomba cai do alto: a coluna nao protege
            zona.ox = zona.cx;
            zona.oy = zona.cy;
            fx_explosao(zona.cx, zona.cy, ataque.tamanho);
            som(snd_explosao);
            break;

        case "estouro":
            fx_explosao(x, y, ataque.tamanho);
            som(snd_explosao);
            break;

        default:
            sfx(snd_golpe_forte, 1, false, 1, 0, 0.7);
            break;
    }
}

// barra de vida no alto da tela: _marcas sao as fracoes da vida onde ele muda
function barra_chefe(_nome, _hp, _hp_max, _cor, _marcas, _fala, _fala_alfa) {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _esc = max(1, _h / 540);
    var _lg = 380 * _esc;
    var _x = (_w - _lg) / 2;
    var _y = 44 * _esc;
    var _alt = 12 * _esc;
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(_x - 2, _y - 2, _x + _lg + 2, _y + _alt + 2, false);
    draw_set_alpha(1);
    draw_set_color(_cor);
    draw_rectangle(_x, _y, _x + _lg * clamp(_hp / _hp_max, 0, 1), _y + _alt, false);
    draw_set_color(c_white);
    for (var _i = 0; _i < array_length(_marcas); _i++) {
        draw_line(_x + _lg * _marcas[_i], _y - 2, _x + _lg * _marcas[_i], _y + _alt + 2);
    }
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    titulo(_w / 2, _y + _alt - 2 * _esc, _nome, _esc * 1.1);
    if (_fala_alfa > 0) {
        draw_set_alpha(_fala_alfa);
        draw_set_color(c_ltgray);
        texto(_w / 2, _y + _alt + 28 * _esc, _fala, _esc * 0.9, _esc * 0.9, 0);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
    draw_set_halign(fa_left);
}

// ---------- duelos: quando a sala fica limpa, um Caido aparece ----------
// Um em cada mapa antes do Trono: os quatro da run saem do sorteio, sem repetir (issue #94). vida e
// furia: para ajustar jogando. furia acima de 1 da mais aviso e mais recarga.
// Ruinas: o mais facil, porque e onde se aprende e o jogador so tem a tecnica do comeco.
// Catacumbas e Cemiterio: os valores de quando eram os dois unicos duelos (com tudo igual nas
// Catacumbas, o robo desatento (50%) morria 13 vezes ali). Patio: no meio dos dois
global.duelos = [
    { sala: Room1, vida: 18, furia: 1.5 },
    { sala: Room_Tunel, vida: 26, furia: 1.25 },
    { sala: Room2, vida: 32, furia: 1.1 },
    { sala: Room3, vida: 40, furia: 1 },
];
global.caidos_chaves = ["carrasco", "batedor", "sapador", "sentinela"];
global.caidos_ordem = [];
global.duelos_feitos = 0;
// salas que ja tiveram duelo nesta run
global.duelos_salas = [];
// quem acabou de cair: o proximo bau traz o que ele deixou
global.caido_vencido = "";
// quem ja apareceu nesta sessao: da segunda vez a fala e outra (zera no menu)
global.caidos_vistos = {};

function duelos_zerar() {
    global.caidos_ordem = [];
    global.duelos_feitos = 0;
    global.duelos_salas = [];
    global.caido_vencido = "";
}

function duelo_da_sala() {
    for (var _i = 0; _i < array_length(global.duelos); _i++) {
        if (global.duelos[_i].sala == room) {
            return global.duelos[_i];
        }
    }
    return undefined;
}

function duelo_pendente() {
    return duelo_da_sala() != undefined && !array_contains(global.duelos_salas, room);
}

// a ordem dos Caidos desta run. O robo gira a lista, para ver os quatro em 3 runs
function caidos_sortear() {
    var _lista = [];
    array_copy(_lista, 0, global.caidos_chaves, 0, array_length(global.caidos_chaves));
    if (instance_exists(obj_autotest)) {
        var _n = array_length(_lista);
        for (var _i = 0; _i < _n; _i++) {
            _lista[_i] = global.caidos_chaves[(_i + global.runs_zeradas) mod _n];
        }
        return _lista;
    }
    global.tecnica_semente = ((global.run_semente * 31) mod 2147483646) + 1;
    tecnica_dado(2);
    for (var _i = array_length(_lista) - 1; _i > 0; _i--) {
        var _j = tecnica_dado(_i + 1);
        var _troca = _lista[_i];
        _lista[_i] = _lista[_j];
        _lista[_j] = _troca;
    }
    return _lista;
}

// perto, mas nao em cima do jogador: com folga de parede e sem parede no meio
function duelo_lugar(_x, _y) {
    var _raios = [260, 200, 150, 100];
    for (var _r = 0; _r < array_length(_raios); _r++) {
        for (var _a = 0; _a < 360; _a += 30) {
            var _px = _x + lengthdir_x(_raios[_r], _a);
            var _py = _y + lengthdir_y(_raios[_r], _a);
            if (_px > 60 && _py > 60 && _px < room_width - 60 && _py < room_height - 60
                && collision_circle(_px, _py, 44, obj_wall, false, true) == noone
                && collision_line(_x, _y, _px, _py, obj_wall, false, true) == noone) {
                return [_px, _py];
            }
        }
    }
    return [_x, _y];
}

// roda no jogador, com a sala limpa. Devolve true enquanto ainda tem duelo nesta sala: o bau e o
// portao esperam. Espera a camera lenta do ultimo golpe acabar
function duelo_tentar() {
    if (!duelo_pendente()) {
        return false;
    }
    if (global.lento > 0) {
        return true;
    }
    if (array_length(global.caidos_ordem) == 0) {
        global.caidos_ordem = caidos_sortear();
    }
    var _chave = global.caidos_ordem[global.duelos_feitos mod array_length(global.caidos_ordem)];
    var _def = variable_struct_get(global.caidos, _chave);
    var _duelo = duelo_da_sala();
    // um respiro antes da luta: a cura de limpar a sala vem agora, e nao depois dela
    if (hp > 0 && hp < hp_max) {
        hp += 1;
        global.vida = hp;
        hud_cura = hud_cura_max;
    }
    duelo_curou = true;
    array_push(global.duelos_salas, room);
    global.duelos_feitos += 1;
    var _lugar = duelo_lugar(x, y);
    with (instance_create_layer(_lugar[0], _lugar[1], "Instances", obj_enemy_caido)) {
        preparar(_chave, _duelo.vida, _duelo.furia);
    }
    fx_onda(_lugar[0], _lugar[1], 120, _def.cor);
    fx_faiscas(_lugar[0], _lugar[1], 90, _def.cor, 12);
    sfx(snd_sino, 3, false, 0.8);
    musica(snd_musica_duelo, 400);
    var _visto = variable_struct_exists(global.caidos_vistos, _chave);
    variable_struct_set(global.caidos_vistos, _chave, true);
    cena_abrir(_lugar[0], _lugar[1], _def.titulo, _visto ? _def.de_novo : _def.fala, _def.cor, _visto ? 110 : 190);
    return true;
}

// apresenta quem entrou: a camera vai ate ele, com o mundo parado (obj_cena)
function cena_abrir(_x, _y, _nome, _frase, _cor, _duracao) {
    with (instance_create_depth(0, 0, -3000, obj_cena)) {
        alvo_x = _x;
        alvo_y = _y;
        nome = _nome;
        frase = _frase;
        cor = _cor;
        duracao = _duracao;
    }
}
