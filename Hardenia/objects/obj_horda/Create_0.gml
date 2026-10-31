// Prototipo de horda (#25). So existe na Room_Horda, fora do caminho da run: tres ondas
// de inimigos fracos chegando de fora da camera, e um modo que mede quantos o aparelho
// aguenta, sem precisar de teclado (para medir num iPad)

// primeira leitura: da para enfrentar, e a terceira onda ja enche a tela. Ajustar jogando
ondas = [25, 50, 100];
// teto de inimigos vivos nas ondas. Provisorio: a issue pede que saia da medida num iPad,
// e ela ainda nao foi feita. O PC aguenta bem mais (1.580 a 1.960), entao 150 e so a maior
// onda com folga, para o aparelho fraco nao sofrer. A medida (L) ignora o teto
horda_teto = 150;
onda = -1;
faltam = 0;
espera = 120;
fim = false;
tempo = 0;
borda = 0; // proximo ponto da borda; sem random, para o robo repetir igual

// medida: quando parar, e o melhor numero ate agora
medindo = false;
medida_fim = false;
medida_limite = 0;
medida_ruim = 0;
medida_teto = 3000;

// um inimigo em volta da camera, nunca em cima do jogador. A razao aurea espalha os
// pontos pela borda sem repetir; ponto em parede ou fora da sala tenta o proximo
criar_um = function() {
    var _cam = view_camera[0];
    var _m = 48;
    var _x0 = camera_get_view_x(_cam) - _m;
    var _y0 = camera_get_view_y(_cam) - _m;
    var _lx = camera_get_view_width(_cam) + 2 * _m;
    var _ly = camera_get_view_height(_cam) + 2 * _m;
    repeat (12) {
        borda += 1;
        var _t = frac(borda * 0.618034) * 2 * (_lx + _ly);
        var _px = _x0;
        var _py = _y0;
        if (_t < _lx) {
            _px += _t;
        } else if (_t < _lx + _ly) {
            _px += _lx;
            _py += _t - _lx;
        } else if (_t < 2 * _lx + _ly) {
            _px += _t - _lx - _ly;
            _py += _ly;
        } else {
            _py += _t - 2 * _lx - _ly;
        }
        if (_px > 0 && _py > 0 && _px < room_width && _py < room_height
            && collision_rectangle(_px - 16, _py - 16, _px + 16, _py + 16, obj_wall, false, true) == noone) {
            instance_create_layer(_px, _py, "Instances", obj_enemy_horda);
            return true;
        }
    }
    return false;
};

// area do botao de medir, na tela (GUI)
botao_medir = function() {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _esc = max(1, _h / 540);
    return [_w / 2 - 170 * _esc, _h - 44 * _esc, _w / 2 + 170 * _esc, _h - 10 * _esc];
};

medir = function() {
    medindo = true;
    tempo = 0;
    instance_destroy(obj_enemy_horda);
};
