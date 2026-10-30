var _t = vida / vida_max; // 1 ao nascer, 0 ao sumir

switch (tipo) {
    case "rastro":
        // somado ao fundo: o rastro acende no escuro; encolhe um pouco ao sumir
        var _esc = 0.85 + 0.15 * _t;
        gpu_set_blendmode(bm_add);
        draw_sprite_ext(sprite_index, image_index, x, y, _esc, _esc, 0, cor, 0.75 * _t);
        gpu_set_blendmode(bm_normal);
        break;

    case "risco":
        var _ang = point_direction(x, y, x2, y2) + 90;
        var _ox = lengthdir_x(9, _ang);
        var _oy = lengthdir_y(9, _ang);
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.4 * _t);
        draw_line_width_colour(x + _ox, y + _oy, x2 + _ox, y2 + _oy, 1, cor, cor);
        draw_line_width_colour(x - _ox, y - _oy, x2 - _ox, y2 - _oy, 1, cor, cor);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
        break;

    case "anel":
        // anel achatado (chao visto de cima) que abre e some
        var _r = 8 + 22 * (1 - _t * _t);
        var _esp = 1 + 3 * _t;
        gpu_set_blendmode(bm_add);
        draw_primitive_begin(pr_trianglestrip);
        for (var _a = 0; _a <= 360; _a += 15) {
            draw_vertex_colour(x + lengthdir_x(_r - _esp, _a), y + lengthdir_y(_r - _esp, _a) * 0.45, cor, 0);
            draw_vertex_colour(x + lengthdir_x(_r, _a), y + lengthdir_y(_r, _a) * 0.45, cor, 0.8 * _t);
        }
        draw_primitive_end();
        gpu_set_blendmode(bm_normal);
        break;

    case "poeira":
        // nuvenzinhas que saem rapido, freiam, crescem e somem
        var _ida = 1 - power(_t, 3);
        draw_set_colour(cor);
        draw_set_alpha(0.6 * _t);
        for (var _i = 0; _i < array_length(angulos); _i++) {
            var _d = distancias[_i] * _ida;
            draw_circle(x + lengthdir_x(_d, angulos[_i]), y + lengthdir_y(_d, angulos[_i]) * 0.6, 3 + 5 * (1 - _t), false);
        }
        draw_set_alpha(1);
        draw_set_colour(c_white);
        break;

    case "arco":
        // varre a abertura na primeira metade da vida, depois so apaga;
        // mais grosso no meio do arco, como o rastro de uma lamina
        var _varrido = abertura * min(1, (1 - _t) * 2 + 0.25);
        var _ini = dir + abertura / 2 * sentido;
        gpu_set_blendmode(bm_add);
        draw_primitive_begin(pr_trianglestrip);
        for (var _a = 0; _a <= _varrido; _a += 7) {
            var _ang = _ini - _a * sentido;
            var _esp = 2 + espessura * sin(pi * _a / abertura);
            var _brilho = min(1, intensidade * _t);
            draw_vertex_colour(x + lengthdir_x(raio - _esp, _ang), y + lengthdir_y(raio - _esp, _ang), cor, _brilho);
            draw_vertex_colour(x + lengthdir_x(raio + 2, _ang), y + lengthdir_y(raio + 2, _ang), c_white, _brilho);
        }
        draw_primitive_end();
        gpu_set_blendmode(bm_normal);
        break;

    case "estocada":
        // ponta fina saindo do corpo ate o fim do alcance do golpe (raio)
        var _lx = lengthdir_x(espessura, dir + 90);
        var _ly = lengthdir_y(espessura, dir + 90);
        gpu_set_blendmode(bm_add);
        draw_primitive_begin(pr_trianglelist);
        draw_vertex_colour(x + _lx, y + _ly, cor, _t);
        draw_vertex_colour(x - _lx, y - _ly, cor, _t);
        draw_vertex_colour(x + lengthdir_x(raio, dir), y + lengthdir_y(raio, dir), c_white, _t);
        draw_primitive_end();
        gpu_set_blendmode(bm_normal);
        break;

    case "faisca":
        var _perto = 4 + 26 * (1 - _t);
        var _longe = _perto + 4 + 10 * _t;
        draw_set_colour(cor);
        draw_set_alpha(_t);
        for (var _i = 0; _i < array_length(angulos); _i++) {
            var _a = angulos[_i];
            draw_line_width(x + lengthdir_x(_perto, _a), y + lengthdir_y(_perto, _a),
                x + lengthdir_x(_longe, _a), y + lengthdir_y(_longe, _a), 2);
        }
        draw_set_alpha(1);
        draw_set_colour(c_white);
        break;
}
