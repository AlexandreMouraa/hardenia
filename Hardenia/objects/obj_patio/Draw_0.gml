// Cache local recriado quando a GPU perde a surface. Nenhuma leitura de pixel por quadro.
if (!surface_exists(chao)) {
    chao = surface_create(room_width, room_height);
    if (!surface_exists(chao)) exit;
    surface_set_target(chao);
    draw_clear(make_colour_rgb(29, 37, 43));
    // Lajes largas, contraste baixo e detalhes deterministas deixam os avisos legiveis.
    for (var _fila = 0; _fila < room_height div 32; _fila++) {
        for (var _col = -1; _col < room_width div 64; _col++) {
            var _px = _col * 64 + (_fila mod 2) * 32;
            var _py = _fila * 32;
            var _v = (_col * 17 + _fila * 31 + 90) mod 9;
            draw_set_color(make_colour_rgb(43 + _v, 52 + _v, 57 + _v));
            draw_rectangle(_px + 1, _py + 1, _px + 62, _py + 30, false);
            draw_set_color(make_colour_rgb(58 + _v, 66 + _v, 70 + _v));
            draw_line(_px + 2, _py + 2, _px + 60, _py + 2);
            if (_v == 2) {
                draw_set_color(make_colour_rgb(30, 40, 43));
                draw_line(_px + 18, _py + 3, _px + 24, _py + 13);
                draw_line(_px + 24, _py + 13, _px + 20, _py + 22);
            }
        }
    }
    // Faixas de cobre conduzem aos portoes. Emblema militar gasto no centro.
    draw_set_color(make_colour_rgb(117, 101, 68));
    draw_line_width(716, 40, 716, room_height - 40, 2);
    draw_line_width(820, 40, 820, room_height - 40, 2);
    draw_set_color(make_colour_rgb(76, 87, 91));
    draw_circle(768, 512, 134, true);
    draw_circle(768, 512, 126, true);
    draw_triangle(768, 412, 700, 552, 836, 552, true);
    draw_triangle(768, 612, 700, 472, 836, 472, true);
    // A mesma geometria de colisao desenha colunas e muretas: arte e parede concordam.
    with (obj_wall) {
        draw_set_color(make_colour_rgb(20, 27, 31));
        draw_rectangle(bbox_left + 12, bbox_top + 12, bbox_right + 12, bbox_bottom + 12, false);
        draw_set_color(make_colour_rgb(69, 78, 85));
        draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
        draw_set_color(make_colour_rgb(104, 113, 116));
        draw_rectangle(bbox_left + 3, bbox_top + 3, bbox_right - 3, bbox_top + 8, false);
        draw_set_color(make_colour_rgb(40, 47, 54));
        draw_rectangle(bbox_left, bbox_bottom - 8, bbox_right, bbox_bottom, false);
        for (var _sy = bbox_top + 32; _sy < bbox_bottom - 8; _sy += 32) {
            draw_line(bbox_left + 2, _sy, bbox_right - 2, _sy);
        }
    }
    // Estandartes rasgados marcam os lados; nao parecem objetos de colisao.
    for (var _lado = 0; _lado < 2; _lado++) {
        var _bx = _lado == 0 ? 80 : 1456;
        draw_set_color(make_colour_rgb(108, 72, 48));
        draw_line_width(_bx, 170, _bx, 300, 5);
        draw_set_color(make_colour_rgb(103, 48, 40));
        draw_triangle(_bx, 180, _bx + (_lado == 0 ? 60 : -60), 180, _bx, 260, false);
        draw_set_color(make_colour_rgb(169, 133, 74));
        draw_line_width(_bx, 180, _bx + (_lado == 0 ? 60 : -60), 180, 3);
    }
    surface_reset_target();
    draw_set_color(c_white);
}
draw_surface(chao, 0, 0);
