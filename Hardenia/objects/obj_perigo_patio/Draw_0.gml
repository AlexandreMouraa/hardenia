var _cor = make_colour_rgb(255, 180, 72);
if (estado == 1) {
    zona_aviso_desenhar(zona, 1 - tempo / aviso, _cor);
    // Linha tracejada distingue perigo ambiental dos arcos vermelhos dos inimigos.
    draw_set_color(_cor);
    for (var _a = 0; _a < 360; _a += 30) {
        draw_line_width(x + lengthdir_x(raio, _a), y + lengthdir_y(raio, _a),
            x + lengthdir_x(raio, _a + 12), y + lengthdir_y(raio, _a + 12), 2);
    }
}
if (tipo == "barril") {
    draw_set_color(make_colour_rgb(20, 24, 27));
    draw_ellipse(x - 21, y - 6, x + 23, y + 18, false);
    if (estado < 2) {
        draw_set_color(make_colour_rgb(106, 65, 35));
        draw_roundrect(x - 15, y - 23, x + 15, y + 11, false);
        draw_set_color(make_colour_rgb(166, 108, 53));
        draw_rectangle(x - 10, y - 21, x - 6, y + 9, false);
        draw_set_color(make_colour_rgb(43, 49, 53));
        draw_rectangle(x - 16, y - 17, x + 16, y - 12, false);
        draw_rectangle(x - 16, y + 2, x + 16, y + 7, false);
        draw_set_color(_cor);
        draw_triangle(x, y - 10, x - 5, y, x + 5, y, true);
        if (estado == 1) {
            draw_line_width(x + 2, y - 24, x + 8, y - 30, 2);
            draw_circle(x + 8, y - 30, 3 + 2 * sin(tempo), false);
        }
    } else {
        draw_set_color(make_colour_rgb(74, 54, 38));
        draw_line_width(x - 14, y - 6, x + 10, y + 7, 4);
        draw_line_width(x + 11, y - 9, x - 6, y + 9, 3);
    }
} else {
    draw_set_color(make_colour_rgb(37, 44, 48));
    draw_circle(x, y, raio, false);
    draw_set_color(estado == 3 ? c_gray : _cor);
    draw_circle(x, y, raio, true);
    for (var _i = -1; _i <= 1; _i++) {
        for (var _j = -1; _j <= 1; _j++) {
            var _px = x + _i * 15;
            var _py = y + _j * 15;
            if (estado == 2) draw_triangle(_px - 5, _py + 4, _px + 5, _py + 4, _px, _py - 15, false);
            else draw_line_width(_px - 4, _py, _px + 4, _py, 2);
        }
    }
}
draw_set_alpha(1);
draw_set_color(c_white);
