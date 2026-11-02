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
        // varre a abertura na primeira metade da vida, depois so apaga; mais grosso
        // no meio do arco e mais forte na ponta, como o rastro de uma lamina
        var _varrido = abertura * min(1, (1 - _t) * 2 + 0.25);
        var _ini = dir + abertura / 2 * sentido;
        gpu_set_blendmode(bm_add);
        // duas tiras: a de dentro some no centro, a de fora e a lamina
        for (var _tira = 0; _tira < 2; _tira++) {
            draw_primitive_begin(pr_trianglestrip);
            for (var _a = 0; _a <= _varrido; _a += 7) {
                var _ang = _ini - _a * sentido;
                var _esp = 2 + espessura * sin(pi * _a / abertura);
                var _brilho = min(1, intensidade * _t) * (0.3 + 0.7 * _a / max(1, _varrido));
                var _meio = raio - _esp * 0.35;
                if (_tira == 0) {
                    draw_vertex_colour(x + lengthdir_x(raio - _esp, _ang), y + lengthdir_y(raio - _esp, _ang), cor, 0);
                    draw_vertex_colour(x + lengthdir_x(_meio, _ang), y + lengthdir_y(_meio, _ang), cor, _brilho);
                } else {
                    draw_vertex_colour(x + lengthdir_x(_meio, _ang), y + lengthdir_y(_meio, _ang), cor, _brilho);
                    draw_vertex_colour(x + lengthdir_x(raio + 2, _ang), y + lengthdir_y(raio + 2, _ang), borda, _brilho);
                }
            }
            draw_primitive_end();
        }
        gpu_set_blendmode(bm_normal);
        break;

    case "numero":
        // aparece grande, encolhe logo e sobe freando; contorno preto para ler em qualquer chao
        var _idade = 1 - _t;
        var _esc = 1.3 + 0.9 * max(0, 1 - _idade * 6);
        var _ny = y - 34 * (1 - power(1 - _idade, 2));
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_alpha(min(1, _t * 3));
        draw_set_colour(c_black);
        draw_text_transformed(x - 2, _ny, texto, _esc, _esc, 0);
        draw_text_transformed(x + 2, _ny, texto, _esc, _esc, 0);
        draw_text_transformed(x, _ny - 2, texto, _esc, _esc, 0);
        draw_text_transformed(x, _ny + 2, texto, _esc, _esc, 0);
        draw_set_colour(cor);
        draw_text_transformed(x, _ny, texto, _esc, _esc, 0);
        draw_set_alpha(1);
        draw_set_colour(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        break;

    case "onda":
        var _ro = raio * (1 - _t * _t * _t);
        var _eo = 2 + 12 * _t;
        gpu_set_blendmode(bm_add);
        draw_primitive_begin(pr_trianglestrip);
        for (var _a = 0; _a <= 360; _a += 12) {
            draw_vertex_colour(x + lengthdir_x(max(0, _ro - _eo), _a), y + lengthdir_y(max(0, _ro - _eo), _a), cor, 0);
            draw_vertex_colour(x + lengthdir_x(_ro, _a), y + lengthdir_y(_ro, _a), cor, 0.8 * _t);
        }
        draw_primitive_end();
        gpu_set_blendmode(bm_normal);
        break;

    case "corte":
        // risco fino que cresce rapido e apaga: mostra quem levou o golpe
        var _meia = raio * min(1, (1 - _t) * 3 + 0.3);
        var _larg = espessura * _t;
        var _cx = lengthdir_x(_meia, dir);
        var _cy = lengthdir_y(_meia, dir);
        var _lx = lengthdir_x(_larg, dir + 90);
        var _ly = lengthdir_y(_larg, dir + 90);
        gpu_set_blendmode(bm_add);
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(x - _cx, y - _cy, cor, 0);
        draw_vertex_colour(x + _lx, y + _ly, c_white, _t);
        draw_vertex_colour(x - _lx, y - _ly, c_white, _t);
        draw_vertex_colour(x + _cx, y + _cy, cor, 0);
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

    case "explosao":
        // abre rapido; o clarao apaga logo, a fumaca fica mais um pouco
        var _abre = 1 - _t * _t * _t;
        gpu_set_blendmode(bm_add);
        draw_set_colour(cor);
        draw_set_alpha(0.7 * _t * _t);
        draw_circle(x, y, raio * (0.35 + 0.65 * _abre), false);
        draw_set_colour(make_colour_rgb(255, 235, 190));
        draw_set_alpha(_t * _t * _t);
        draw_circle(x, y, raio * 0.45 * _abre, false);
        var _r2 = raio * _abre;
        var _esp2 = 2 + 10 * _t;
        draw_primitive_begin(pr_trianglestrip);
        for (var _a = 0; _a <= 360; _a += 15) {
            draw_vertex_colour(x + lengthdir_x(_r2 - _esp2, _a), y + lengthdir_y(_r2 - _esp2, _a), cor, 0);
            draw_vertex_colour(x + lengthdir_x(_r2, _a), y + lengthdir_y(_r2, _a), cor, 0.9 * _t);
        }
        draw_primitive_end();
        gpu_set_blendmode(bm_normal);
        draw_set_colour(make_colour_rgb(38, 32, 32));
        draw_set_alpha(0.5 * _t);
        for (var _i = 0; _i < array_length(angulos); _i++) {
            var _d = distancias[_i] * _abre;
            draw_circle(x + lengthdir_x(_d, angulos[_i]), y + lengthdir_y(_d, angulos[_i]), 7 + 15 * (1 - _t), false);
        }
        draw_set_alpha(1);
        draw_set_colour(c_white);
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
