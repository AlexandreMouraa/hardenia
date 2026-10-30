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
