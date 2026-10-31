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
// A cor vem do draw_set_color de quem chama
function zona_desenhar(_z, _fundo, _linha) {
    var _v = _z.pontos;
    var _n = array_length(_v);
    if (_fundo > 0) {
        draw_set_alpha(_fundo);
        draw_primitive_begin(pr_trianglelist);
        for (var _i = 1; _i < _n - 1; _i++) {
            draw_vertex(_v[0][0], _v[0][1]);
            draw_vertex(_v[_i][0], _v[_i][1]);
            draw_vertex(_v[_i + 1][0], _v[_i + 1][1]);
        }
        draw_primitive_end();
    }
    if (_linha > 0) {
        draw_set_alpha(_linha);
        for (var _j = 0; _j < _n; _j++) {
            var _prox = _v[(_j + 1) mod _n];
            draw_line_width(_v[_j][0], _v[_j][1], _prox[0], _prox[1], 2);
        }
    }
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
