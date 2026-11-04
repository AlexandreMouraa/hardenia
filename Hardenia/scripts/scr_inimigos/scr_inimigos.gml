// Ataques de inimigo. Um ataque e uma descricao (struct "ataque", no Create do
// inimigo); quando ele comeca, vira uma zona no mundo (zona_criar). O desenho
// (obj_enemy, Draw), o acerto (obj_enemy_attack) e o robo (obj_autotest) usam a
// mesma zona: o que aparece na tela e o que acerta.
//
// Campos do ataque:
//   forma    "quadrado", "circulo", "linha" ou "arco"
//   gatilho  distancia do jogador em que o inimigo comeca o ataque
//   alcance  quadrado e circulo: do inimigo ate o centro
//            linha: comprimento, a partir do inimigo
//            arco: raio, a partir do inimigo
//   tamanho  quadrado: metade do lado
//            circulo: raio
//            linha: metade da largura
//            arco: metade da abertura, em graus
//   aviso    frames de aviso antes do golpe
//   duracao  frames em que a zona fica na tela depois do golpe
//   acerto   frames em que ela machuca, contados do inicio da duracao
//   recarga  frames parado depois do golpe
//   avanco   px por frame que o inimigo anda para a frente enquanto o golpe acerta
//            (bote); 0 = fica parado

// a zona e um poligono: circulo e arco viram varios lados retos, e o acerto testa
// esse mesmo poligono. cx,cy e o meio da forma; ox,oy e de onde o golpe saiu
function zona_criar(_ataque, _x, _y, _dir) {
    var _a = _ataque.alcance;
    var _t = _ataque.tamanho;
    var _cx = _x + lengthdir_x(_a, _dir);
    var _cy = _y + lengthdir_y(_a, _dir);
    var _pontos = [];
    switch (_ataque.forma) {
        case "quadrado":
            _pontos = [[_cx - _t, _cy - _t], [_cx + _t, _cy - _t], [_cx + _t, _cy + _t], [_cx - _t, _cy + _t]];
            break;

        case "circulo":
            for (var _i = 0; _i < 32; _i++) {
                var _ang_c = _i * 360 / 32;
                array_push(_pontos, [_cx + lengthdir_x(_t, _ang_c), _cy + lengthdir_y(_t, _ang_c)]);
            }
            break;

        case "linha":
            var _lx = lengthdir_x(_t, _dir + 90);
            var _ly = lengthdir_y(_t, _dir + 90);
            _pontos = [[_x + _lx, _y + _ly], [_cx + _lx, _cy + _ly], [_cx - _lx, _cy - _ly], [_x - _lx, _y - _ly]];
            _cx = (_x + _cx) / 2;
            _cy = (_y + _cy) / 2;
            break;

        case "arco":
            // o primeiro ponto e o inimigo: zona_desenhar preenche a partir dele
            _pontos = [[_x, _y]];
            for (var _j = 0; _j <= 16; _j++) {
                var _ang_a = _dir - _t + 2 * _t * _j / 16;
                array_push(_pontos, [_x + lengthdir_x(_a, _ang_a), _y + lengthdir_y(_a, _ang_a)]);
            }
            _cx = (_x + _cx) / 2;
            _cy = (_y + _cy) / 2;
            break;
    }
    return { forma: _ataque.forma, pontos: _pontos, ox: _x, oy: _y, cx: _cx, cy: _cy };
}

// leva a zona inteira para sair de _x,_y (a direcao continua a mesma)
function zona_posicionar(_z, _x, _y) {
    var _dx = _x - _z.ox;
    var _dy = _y - _z.oy;
    if (_dx == 0 && _dy == 0) {
        return;
    }
    var _v = _z.pontos;
    for (var _i = 0; _i < array_length(_v); _i++) {
        _v[_i][0] += _dx;
        _v[_i][1] += _dy;
    }
    _z.ox = _x;
    _z.oy = _y;
    _z.cx += _dx;
    _z.cy += _dy;
}

// _fundo: transparencia do preenchimento. _linha: do contorno (0 = sem contorno).
// _escala: tamanho do preenchimento, de 0 a 1, crescendo a partir de onde o golpe sai (o
// circulo cresce do meio). A cor vem do draw_set_color de quem chama
function zona_desenhar(_z, _fundo, _linha, _escala = 1) {
    var _v = _z.pontos;
    var _n = array_length(_v);
    if (_fundo > 0) {
        var _ox = (_z.forma == "circulo") ? _z.cx : _z.ox;
        var _oy = (_z.forma == "circulo") ? _z.cy : _z.oy;
        var _p0x = _ox + (_v[0][0] - _ox) * _escala;
        var _p0y = _oy + (_v[0][1] - _oy) * _escala;
        draw_set_alpha(_fundo);
        draw_primitive_begin(pr_trianglelist);
        for (var _i = 1; _i < _n - 1; _i++) {
            draw_vertex(_p0x, _p0y);
            draw_vertex(_ox + (_v[_i][0] - _ox) * _escala, _oy + (_v[_i][1] - _oy) * _escala);
            draw_vertex(_ox + (_v[_i + 1][0] - _ox) * _escala, _oy + (_v[_i + 1][1] - _oy) * _escala);
        }
        draw_primitive_end();
    }
    if (_linha > 0) {
        draw_set_alpha(_linha);
        for (var _j = 0; _j < _n; _j++) {
            var _prox = _v[(_j + 1) mod _n];
            draw_line_width(_v[_j][0], _v[_j][1], _prox[0], _prox[1], 1);
        }
    }
}

// aviso: contorno fino e um preenchimento que enche a zona ate a hora do golpe. _t de 0 a 1
function zona_aviso_desenhar(_z, _t, _cor) {
    draw_set_color(_cor);
    zona_desenhar(_z, 0.1 + 0.14 * _t, 0.25 + 0.35 * _t, _t);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// golpe: a zona inteira pisca e some. _t de 1 a 0
function zona_golpe_desenhar(_z, _t, _cor) {
    draw_set_color(_cor);
    zona_desenhar(_z, 0.32 * _t, 0);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// o corte de quem bate de perto: arco do tamanho da zona, vermelho, para nao confundir com o
// do jogador. Linha e circulo tem o proprio efeito (rastro do bote, explosao)
function fx_golpe_inimigo(_ataque, _x, _y, _dir) {
    if (_ataque.forma != "arco" && _ataque.forma != "quadrado") {
        return;
    }
    var _arco = (_ataque.forma == "arco");
    var _r = _arco ? _ataque.alcance : _ataque.alcance + _ataque.tamanho;
    with (instance_create_depth(_x, _y, depth - 1, obj_fx)) {
        tipo = "arco";
        dir = _dir;
        raio = _r - 2;
        abertura = _arco ? 2 * _ataque.tamanho : 110;
        espessura = clamp(_r * 0.3, 14, 40);
        cor = make_colour_rgb(200, 30, 30);
        borda = make_colour_rgb(255, 130, 100);
        vida_max = 12;
        vida = vida_max;
    }
}

// ---------- bomba que cai no circulo marcado. Tudo so no desenho: quem acerta e a zona ----------
// _t vai de 0 (aviso comecando) a 1 (hora do golpe). Altura em pixels da camera: comeca fora da
// tela e acelera. Cai no meio da zona exatamente quando o aviso acaba
#macro BOMBA_ALTURA 440

function bomba_altura(_t) {
    return BOMBA_ALTURA * (1 - _t * _t);
}

// a sombra cresce: mostra onde ela vai cair antes de a bomba aparecer na tela
function bomba_sombra_desenhar(_x, _y, _t) {
    var _r = 6 + 20 * _t * _t;
    draw_set_color(c_black);
    draw_set_alpha(0.25 + 0.35 * _t);
    draw_ellipse(_x - _r, _y - _r * 0.45, _x + _r, _y + _r * 0.45, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// roda no Draw End: por cima de todo mundo, porque ela vem do alto. _tempo gira e troca a fagulha
function bomba_desenhar(_x, _y, _t, _tempo) {
    var _esc = 1.25 - 0.25 * _t;
    draw_sprite_ext(spr_bomba, (_tempo div 4) mod 2, _x, _y - bomba_altura(_t), _esc, _esc, _tempo * 5, c_white, 1);
}

// quem jogou a bomba morreu antes de ela cair: o golpe some com ele, e ela apaga no ar
function bomba_apagar(_x, _y, _t) {
    fx_faiscas(_x, _y - bomba_altura(_t), 90, make_colour_rgb(255, 170, 70), 6);
}

// o segmento passa pelo retangulo? (Liang-Barsky: recorta o segmento nos 4 lados)
function segmento_toca_retangulo(_x1, _y1, _x2, _y2, _l, _t, _r, _b) {
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _p = [-_dx, _dx, -_dy, _dy];
    var _q = [_x1 - _l, _r - _x1, _y1 - _t, _b - _y1];
    var _de = 0;
    var _ate = 1;
    for (var _i = 0; _i < 4; _i++) {
        if (_p[_i] == 0) {
            if (_q[_i] < 0) {
                return false;
            }
        } else if (_p[_i] < 0) {
            _de = max(_de, _q[_i] / _p[_i]);
        } else {
            _ate = min(_ate, _q[_i] / _p[_i]);
        }
    }
    return _de <= _ate;
}

// o ponto esta dentro do poligono? (conta quantos lados um raio horizontal cruza)
function ponto_na_zona(_z, _x, _y) {
    var _v = _z.pontos;
    var _n = array_length(_v);
    var _dentro = false;
    for (var _i = 0; _i < _n; _i++) {
        var _a = _v[_i];
        var _b = _v[(_i + 1) mod _n];
        if ((_a[1] > _y) != (_b[1] > _y) && _x < _a[0] + (_y - _a[1]) / (_b[1] - _a[1]) * (_b[0] - _a[0])) {
            _dentro = !_dentro;
        }
    }
    return _dentro;
}

// a zona encosta no retangulo? Ou um lado dela passa por ele, ou nenhum passa e
// o retangulo esta todo dentro (basta testar um canto)
function zona_toca_retangulo(_z, _l, _t, _r, _b) {
    var _v = _z.pontos;
    var _n = array_length(_v);
    for (var _i = 0; _i < _n; _i++) {
        var _prox = _v[(_i + 1) mod _n];
        if (segmento_toca_retangulo(_v[_i][0], _v[_i][1], _prox[0], _prox[1], _l, _t, _r, _b)) {
            return true;
        }
    }
    return ponto_na_zona(_z, _l, _t);
}

// o golpe acerta o jogador? Parede entre o ponto de onde o golpe saiu e o jogador
// protege, mesmo com a zona passando por cima dela
function zona_acerta_jogador(_z) {
    var _p = instance_find(obj_player, 0);
    return zona_toca_retangulo(_z, _p.bbox_left, _p.bbox_top, _p.bbox_right, _p.bbox_bottom)
        && collision_line(_z.ox, _z.oy, _p.x, _p.y, obj_wall, false, true) == noone;
}

// ---------- golpe do jogador acertando um inimigo ----------
// vale para o golpe (obj_attack) e para o que as tecnicas causam. _forte: pausa, tremor e
// empurrao do golpe forte. _quebra: quebra o escudo da elite
function golpe_acertar(_enemy, _dano, _knockback, _forte, _quebra) {
    // apanhar acorda ele e os vizinhos, mesmo sem ter visto o jogador
    with (_enemy) {
        acordar();
    }
    // escudo da elite: o golpe comum so faz barulho. Quem tem o golpe certo quebra e ja tira vida
    if (_enemy.escudo) {
        var _dir_escudo = instance_exists(obj_player) ? point_direction(obj_player.x, obj_player.y, _enemy.x, _enemy.y) : 0;
        som(snd_escudo, _quebra ? 1.2 : 0.8);
        if (!_quebra) {
            impacto(1, 1);
            fx_faiscas(_enemy.x, _enemy.y, _dir_escudo, make_colour_rgb(120, 220, 255), 4);
            return;
        }
        _enemy.escudo = false;
        impacto(4, 4);
        fx_faiscas(_enemy.x, _enemy.y, _dir_escudo, make_colour_rgb(120, 220, 255), 12);
    }
    _dano = tecnicas_no_golpe(_enemy, _dano, _forte);
    furia_ganhar(_forte ? 6 : 3);
    _enemy.hp -= _dano;
    _enemy.hit_flash = 8;
    var _dir_golpe = instance_exists(obj_player) ? point_direction(obj_player.x, obj_player.y, _enemy.x, _enemy.y) : 0;
    som(_enemy.hp <= 0 ? snd_morte_inimigo : snd_acerto);
    // dez vezes o dano: 1 e 2 nao dizem muito na tela. Na horda seria uma chuva de numeros
    if (!_enemy.leve) {
        fx_numero(_enemy.x, _enemy.bbox_top, round(_dano * 10), _forte ? make_colour_rgb(255, 190, 70) : c_white);
    }
    if (_enemy.hp <= 0) {
        inimigo_morrer(_enemy, _dir_golpe, _forte);
    } else if (instance_exists(obj_player)) {
        // quem nao se move leva o golpe, mas nao e empurrado
        var _kb = _enemy.imovel ? 0 : _knockback;
        if (_forte) {
            // fim do combo: pausa maior, empurrao na camera e uma onda em volta de quem levou
            impacto(6, 6);
            chute_camera(_dir_golpe, 9);
            fx_onda(_enemy.x, _enemy.y, 58, make_colour_rgb(255, 180, 90));
            fx_faiscas(_enemy.x, _enemy.y, _dir_golpe, make_colour_rgb(255, 200, 120), 8);
            fx_corte(_enemy.x, _enemy.y, _dir_golpe, make_colour_rgb(255, 170, 80), 50);
        } else {
            impacto(2, 2);
            fx_faiscas(_enemy.x, _enemy.y, _dir_golpe, c_white, 5);
            fx_corte(_enemy.x, _enemy.y, _dir_golpe, make_colour_rgb(180, 205, 240), 38);
        }
        if (_forte) {
            // terceiro golpe: o inimigo desliza para longe e freia (obj_enemy,
            // Step); 0.35 da distancia no primeiro frame, perdendo 35% a cada um
            _enemy.empurrao_x = lengthdir_x(_kb * 0.35, _dir_golpe);
            _enemy.empurrao_y = lengthdir_y(_kb * 0.35, _dir_golpe);
        } else {
            // golpe comum: o empurrao curto de sempre, na hora. Deslizando, o
            // inimigo ficava na beira do alcance e quase nunca atacava (o robo
            // mostrou: 0 golpes de inimigo em 3 runs, contra 10 assim)
            var _kx = lengthdir_x(_kb, _dir_golpe);
            var _ky = lengthdir_y(_kb, _dir_golpe);
            with (_enemy) {
                if (!place_meeting(x + _kx, y, obj_wall)) {
                    x += _kx;
                }
                if (!place_meeting(x, y + _ky, obj_wall)) {
                    y += _ky;
                }
            }
        }
    }
}

// _dir: para onde o golpe empurrou
function inimigo_morrer(_enemy, _dir, _forte) {
    if (_enemy.bomba && _enemy.state == 1) {
        bomba_apagar(_enemy.zona.cx, _enemy.zona.cy, 1 - _enemy.state_timer / _enemy.ataque.aviso);
    }
    if (_enemy.elite == "explosao") {
        instance_create_layer(_enemy.x, _enemy.y, "Instances", obj_explosao);
    }
    // o Caido que cai deixa a tecnica no bau da sala (obj_tecnicas)
    if (_enemy.object_index == obj_enemy_caido) {
        global.caido_vencido = _enemy.caido;
    }
    // a bomba espera um instante: pode pegar outro que sangra, e a corrente cresce sem recursao
    if (_enemy.sangra > 0 && tem_tecnica("sangue_polvora")) {
        bomba_jogador(_enemy.x, _enemy.y, _enemy.x, _enemy.y, 1, 8, 1);
        tecnica_contar("sangue_polvora");
    }
    // golpe que mata: pausa e tremor maiores, faiscas vermelhas. Inimigo de horda
    // morre sem isso: a cada golpe morrem varios, e o jogo ficaria parando
    if (!_enemy.leve) {
        impacto(_forte ? 7 : 5, _forte ? 9 : 6);
        chute_camera(_dir, _forte ? 10 : 6);
        fx_faiscas(_enemy.x, _enemy.y, _dir, c_red, 9);
        fx_corte(_enemy.x, _enemy.y, _dir, make_colour_rgb(255, 120, 90), _forte ? 56 : 46);
        furia_ganhar(3);
        // o bau da sala aparece onde o ultimo caiu
        global.morto_x = _enemy.x;
        global.morto_y = _enemy.y;
    }
    // ultimo da sala: _enemy ainda conta, ele so some no fim desta funcao
    if (!_enemy.leve && instance_number(obj_enemy) == 1) {
        momento_final(_enemy.x, _enemy.y, _enemy.imovel ? 2 : 1);
    }
    with (instance_create_layer(_enemy.x, _enemy.y, "Instances", obj_fx_morte)) {
        sprite_index = _enemy.sprite_index;
        image_index = _enemy.image_index;
    }
    instance_destroy(_enemy);
}

// ---------- comportamento em grupo. Rodam no inimigo que chama ----------

// a mesma visao para todo mundo: alcance e parede no meio
function inimigo_ve_jogador() {
    return point_distance(x, y, obj_player.x, obj_player.y) <= visao
        && collision_line(x, y, obj_player.x, obj_player.y, obj_wall, false, true) == noone;
}

// ---------- caminho em volta da parede ----------
// Um mapa so para todos, em vez de um caminho por inimigo, pensando em horda: a sala
// vira uma grade, e cada celula guarda a quantos passos esta do ultimo lugar onde alguem
// viu o jogador. Quem nao ve o jogador anda para a celula vizinha mais perto dali.
#macro CAMPO_CELULA 32
// meio inimigo: as mascaras vao ate 50 x 63 (ghoul). Menos que isso e ele prende na quina
// de uma celula "livre". Com essa folga, corredor de 96 px ainda tem uma celula livre
#macro CAMPO_FOLGA_X 26
#macro CAMPO_FOLGA_Y 32
// recalcula no maximo a cada 15 frames, e so se o alvo mudou de celula
#macro CAMPO_INTERVALO 15

global.campo = { sala: -1, alvo_x: -1, alvo_y: -1, visto_em: 0, grade: -1, caminho: path_add() };

// mede a sala uma vez: as paredes nao mudam, e reiniciar a sala aproveita a mesma medida
function campo_preparar() {
    if (global.campo.sala == room) {
        return;
    }
    if (global.campo.grade != -1) {
        mp_grid_destroy(global.campo.grade);
    }
    var _w = ceil(room_width / CAMPO_CELULA);
    var _h = ceil(room_height / CAMPO_CELULA);
    var _n = _w * _h;
    var _livre = array_create(_n, false);
    var _grade = mp_grid_create(0, 0, _w, _h, CAMPO_CELULA, CAMPO_CELULA);
    for (var _j = 0; _j < _h; _j++) {
        for (var _i = 0; _i < _w; _i++) {
            var _cx = (_i + 0.5) * CAMPO_CELULA;
            var _cy = (_j + 0.5) * CAMPO_CELULA;
            var _ok = collision_rectangle(_cx - CAMPO_FOLGA_X, _cy - CAMPO_FOLGA_Y, _cx + CAMPO_FOLGA_X, _cy + CAMPO_FOLGA_Y, obj_wall, false, true) == noone;
            _livre[@ _j * _w + _i] = _ok;
            if (!_ok) {
                mp_grid_add_cell(_grade, _i, _j);
            }
        }
    }
    global.campo = {
        sala: room,
        w: _w,
        h: _h,
        livre: _livre,
        dist: array_create(_n, -1),
        fila: array_create(_n, 0),
        alvo_x: -1,
        alvo_y: -1,
        visto_em: 0,
        calculado_cel: -1,
        calculado_em: -CAMPO_INTERVALO,
        grade: _grade,
        caminho: global.campo.caminho,
    };
}

// alguem do grupo viu o jogador em _x,_y
function campo_ver(_x, _y) {
    campo_preparar();
    global.campo.alvo_x = _x;
    global.campo.alvo_y = _y;
    global.campo.visto_em = global.run_frames;
}

// busca em largura a partir do alvo. A celula do alvo vale mesmo sem caber um inimigo:
// o jogador e menor e pode estar encostado na parede
function campo_calcular() {
    var _c = global.campo;
    var _w = _c.w;
    var _alvo = clamp(floor(_c.alvo_y / CAMPO_CELULA), 0, _c.h - 1) * _w + clamp(floor(_c.alvo_x / CAMPO_CELULA), 0, _w - 1);
    if (_alvo == _c.calculado_cel || global.run_frames - _c.calculado_em < CAMPO_INTERVALO) {
        return;
    }
    _c.calculado_cel = _alvo;
    _c.calculado_em = global.run_frames;
    var _dist = _c.dist;
    var _fila = _c.fila;
    var _livre = _c.livre;
    var _n = _w * _c.h;
    for (var _i = 0; _i < _n; _i++) {
        _dist[@ _i] = -1;
    }
    _dist[@ _alvo] = 0;
    _fila[@ 0] = _alvo;
    var _de = 0;
    var _ate = 1;
    while (_de < _ate) {
        var _k = _fila[_de];
        _de += 1;
        var _d = _dist[_k] + 1;
        var _col = _k mod _w;
        if (_col > 0 && _livre[_k - 1] && _dist[_k - 1] < 0) {
            _dist[@ _k - 1] = _d;
            _fila[@ _ate] = _k - 1;
            _ate += 1;
        }
        if (_col < _w - 1 && _livre[_k + 1] && _dist[_k + 1] < 0) {
            _dist[@ _k + 1] = _d;
            _fila[@ _ate] = _k + 1;
            _ate += 1;
        }
        if (_k >= _w && _livre[_k - _w] && _dist[_k - _w] < 0) {
            _dist[@ _k - _w] = _d;
            _fila[@ _ate] = _k - _w;
            _ate += 1;
        }
        if (_k + _w < _n && _livre[_k + _w] && _dist[_k + _w] < 0) {
            _dist[@ _k + _w] = _d;
            _fila[@ _ate] = _k + _w;
            _ate += 1;
        }
    }
}

// direcao para a celula vizinha mais perto do alvo; -1 sem caminho ou ja no alvo. Na
// diagonal, so com os dois lados livres: senao ele corta a quina e trava nela
function campo_rumo() {
    campo_preparar();
    var _c = global.campo;
    if (_c.alvo_x < 0) {
        return -1;
    }
    campo_calcular();
    var _w = _c.w;
    var _h = _c.h;
    var _dist = _c.dist;
    var _i = clamp(floor(x / CAMPO_CELULA), 0, _w - 1);
    var _j = clamp(floor(y / CAMPO_CELULA), 0, _h - 1);
    var _aqui = _dist[_j * _w + _i];
    var _melhor = (_aqui >= 0) ? _aqui : 1000000;
    var _mi = -1;
    var _mj = -1;
    for (var _dj = -1; _dj <= 1; _dj++) {
        for (var _di = -1; _di <= 1; _di++) {
            var _ni = _i + _di;
            var _nj = _j + _dj;
            if ((_di == 0 && _dj == 0) || _ni < 0 || _nj < 0 || _ni >= _w || _nj >= _h) {
                continue;
            }
            var _d = _dist[_nj * _w + _ni];
            if (_d < 0 || _d >= _melhor) {
                continue;
            }
            if (_di != 0 && _dj != 0 && (_dist[_j * _w + _ni] < 0 || _dist[_nj * _w + _i] < 0)) {
                continue;
            }
            _melhor = _d;
            _mi = _ni;
            _mj = _nj;
        }
    }
    if (_mi < 0) {
        return -1;
    }
    campo_passos = _melhor;
    return point_direction(x, y, (_mi + 0.5) * CAMPO_CELULA, (_mj + 0.5) * CAMPO_CELULA);
}

// voltando para casa com parede no meio: pede um caminho uma vez so e segue os pontos.
// Casa inalcancavel: fica morando onde esta, em vez de empurrar a parede para sempre
function casa_rumo() {
    if (casa_passo < 0) {
        if (collision_line(x, y, home_x, home_y, obj_wall, false, true) == noone) {
            return point_direction(x, y, home_x, home_y);
        }
        campo_preparar();
        var _c = global.campo;
        if (!mp_grid_path(_c.grade, _c.caminho, x, y, home_x, home_y, true)) {
            home_x = x;
            home_y = y;
            return point_direction(x, y, home_x, home_y);
        }
        casa_rota = [];
        for (var _i = 0; _i < path_get_number(_c.caminho); _i++) {
            array_push(casa_rota, [path_get_point_x(_c.caminho, _i), path_get_point_y(_c.caminho, _i)]);
        }
        casa_passo = 0;
    }
    while (casa_passo < array_length(casa_rota) && point_distance(x, y, casa_rota[casa_passo][0], casa_rota[casa_passo][1]) < 12) {
        casa_passo += 1;
    }
    if (casa_passo >= array_length(casa_rota)) {
        casa_passo = -1;
        return point_direction(x, y, home_x, home_y);
    }
    return point_direction(x, y, casa_rota[casa_passo][0], casa_rota[casa_passo][1]);
}

// ---------- elites: qualquer tipo com mais vida, uma marca e uma habilidade ----------
// indice: qual inimigo daquele tipo na sala, na ordem em que nascem. Valores para ajustar
// jogando; sala nova: acrescentar aqui
global.elites_sala = [
    { sala: Room_Tunel, objeto: obj_enemy, indice: 0, habilidade: "invocacao" },
    { sala: Room_Tunel, objeto: obj_enemy, indice: 1, habilidade: "explosao" },
    { sala: Room_Tunel, objeto: obj_enemy_wight, indice: 0, habilidade: "escudo" },
    { sala: Room2, objeto: obj_enemy_ghoul, indice: 0, habilidade: "explosao" },
    { sala: Room3, objeto: obj_enemy_wight, indice: 0, habilidade: "escudo" },
    { sala: Room3, objeto: obj_enemy_wight, indice: 2, habilidade: "invocacao" },
];

// as tecnicas e a Furia fortalecem o jogador ao longo da run, entao cada sala endurece: mais
// vida, menos aviso e menos descanso entre um ataque e outro. Medido com -desatento 30, para
// ajustar jogando. O chefe cuida do proprio aviso, e so ganha vida
global.dificuldade_salas = [
    { vida: 0, aviso: 1, recarga: 1 },
    { vida: 1, aviso: 0.9, recarga: 0.85 },
    { vida: 2, aviso: 0.85, recarga: 0.75 },
    { vida: 3, aviso: 0.8, recarga: 0.6 },
];
function dificuldade_aplicar() {
    var _fase = mapa_indice(room);
    if (_fase < 0) {
        return;
    }
    if (_fase < array_length(global.dificuldade_salas)) {
        var _d = global.dificuldade_salas[_fase];
        with (obj_enemy) {
            if (!leve && !imovel) {
                hp += _d.vida;
                ataque.aviso = round(ataque.aviso * _d.aviso);
                ataque.recarga = round(ataque.recarga * _d.recarga);
            }
        }
    }
    with (obj_enemy_chefe) {
        hp_max = 80;
        hp = hp_max;
    }
}

// chamada no primeiro frame da sala (obj_player, Step)
function elites_aplicar() {
    for (var _e = 0; _e < array_length(global.elites_sala); _e++) {
        var _def = global.elites_sala[_e];
        if (_def.sala == room) {
            var _n = 0;
            with (_def.objeto) {
                // with no pai passa pelos filhos tambem: aqui so o tipo exato
                if (object_index == _def.objeto) {
                    if (_n == _def.indice) {
                        elite_tornar(_def.habilidade);
                    }
                    _n += 1;
                }
            }
        }
    }
}

function elite_tornar(_habilidade) {
    elite = _habilidade;
    hp += 2;
    image_xscale *= 1.2;
    image_yscale *= 1.2;
    escudo = (_habilidade == "escudo");
}

// a marca: anel no chao, na cor da habilidade, e o escudo em volta enquanto existir
function elite_desenhar() {
    var _cor = make_colour_rgb(110, 230, 120);
    if (elite == "escudo") {
        _cor = make_colour_rgb(120, 220, 255);
    } else if (elite == "explosao") {
        _cor = make_colour_rgb(255, 150, 40);
    }
    var _pulso = 0.5 + 0.5 * sin(current_time / 200);
    draw_set_color(_cor);
    draw_set_alpha(0.35 + 0.35 * _pulso);
    draw_ellipse(x - 30, y + 14, x + 30, y + 40, false);
    if (escudo) {
        draw_set_alpha(0.5 + 0.3 * _pulso);
        draw_circle(x, y, 44, true);
        draw_circle(x, y, 43, true);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// invocacao: ate 2 fracos vivos ao mesmo tempo, e 6 no total, para a sala poder terminar.
// Lados fixos em volta dele, sem sorteio: o robo depende da sequencia aleatoria
function invocar_passo() {
    invocar_timer -= 1;
    if (invocar_timer > 0) {
        return;
    }
    invocar_timer = 300;
    var _vivos = [];
    for (var _i = 0; _i < array_length(invocados); _i++) {
        if (instance_exists(invocados[_i])) {
            array_push(_vivos, invocados[_i]);
        }
    }
    invocados = _vivos;
    var _vagas = min(2 - array_length(invocados), 6 - invocar_total);
    for (var _k = 0; _k < _vagas; _k++) {
        var _ang = invocar_total * 137;
        var _mx = x + lengthdir_x(80, _ang);
        var _my = y + lengthdir_y(80, _ang);
        invocar_total += 1;
        // nao nasce dentro da parede
        if (collision_circle(_mx, _my, 24, obj_wall, false, true) == noone) {
            var _dono = id;
            with (instance_create_layer(_mx, _my, "Instances", obj_invocacao)) {
                dono = _dono;
            }
        }
    }
    if (_vagas > 0) {
        som(snd_magia, 0.7);
    }
}

// ate onde uma linha reta vai antes de bater na parede, de 16 em 16 px
function linha_ate_parede(_x, _y, _dir, _max) {
    for (var _d = 16; _d < _max; _d += 16) {
        if (collision_point(_x + lengthdir_x(_d, _dir), _y + lengthdir_y(_d, _dir), obj_wall, false, true) != noone) {
            return _d;
        }
    }
    return _max;
}

// anda para _dir, escorregando na parede
function inimigo_andar(_dir, _vel) {
    var _mx = lengthdir_x(_vel, _dir);
    var _my = lengthdir_y(_vel, _dir);
    if (!place_meeting(x + _mx, y, obj_wall)) {
        x += _mx;
    }
    if (!place_meeting(x, y + _my, obj_wall)) {
        y += _my;
    }
}

// vira o sprite para o lado (dos 4) mais perto de _dir
function inimigo_virar(_dir) {
    var _ax = lengthdir_x(1, _dir);
    var _ay = lengthdir_y(1, _dir);
    if (abs(_ax) > abs(_ay)) {
        facing_dir = (_ax < 0) ? 1 : 2;
    } else {
        facing_dir = (_ay < 0) ? 3 : 0;
    }
}

// Cerco: 6 lados em volta do jogador, cada um com um dono. Custa 6 contas a cada
// 90 frames por inimigo: nada de procurar todos contra todos, pensando em horda.
// Dono morto ou que voltou a dormir libera o lado sozinho
global.cerco = array_create(6, noone);

// fica com o lado livre mais longe dos outros, sem andar demais: o peso 0,25 faz o
// segundo do grupo passar para o lado oposto em vez de vir colado no primeiro. Com
// todos ocupados, vai direto de onde estiver
function cerco_escolher() {
    var _onde = point_direction(obj_player.x, obj_player.y, x, y);
    var _n = array_length(global.cerco);
    for (var _i = 0; _i < _n; _i++) {
        var _dono = global.cerco[_i];
        if (_dono == id || !instance_exists(_dono) || !_dono.acordado) {
            global.cerco[_i] = noone;
        }
    }
    var _melhor = -1;
    var _nota = -1000;
    for (var _i = 0; _i < _n; _i++) {
        if (global.cerco[_i] == noone) {
            var _longe = 180;
            for (var _j = 0; _j < _n; _j++) {
                if (global.cerco[_j] != noone) {
                    _longe = min(_longe, abs(angle_difference(_i * 60, _j * 60)));
                }
            }
            var _esta = _longe - 0.25 * abs(angle_difference(_i * 60, _onde));
            if (_esta > _nota) {
                _nota = _esta;
                _melhor = _i;
            }
        }
    }
    if (_melhor >= 0) {
        global.cerco[_melhor] = id;
        cerco_ang = _melhor * 60;
    } else {
        cerco_ang = _onde;
    }
}

// Vez de atacar: no maximo 2 em aviso ou golpe ao mesmo tempo. Com mais de um
// pedaco de vida ainda e dificil ler 4 avisos juntos. Quem morreu ou entrou na
// recarga solta a vez sozinho, entao nao precisa de contador nem de evento de morte
global.vez_atacar = array_create(2, noone);

function vez_solta(_dono) {
    return !instance_exists(_dono) || (_dono.state != 1 && _dono.state != 2);
}

function vez_livre() {
    for (var _i = 0; _i < array_length(global.vez_atacar); _i++) {
        if (vez_solta(global.vez_atacar[_i])) {
            return true;
        }
    }
    return false;
}

function vez_pegar() {
    for (var _i = 0; _i < array_length(global.vez_atacar); _i++) {
        if (vez_solta(global.vez_atacar[_i])) {
            global.vez_atacar[_i] = id;
            return true;
        }
    }
    return false;
}
