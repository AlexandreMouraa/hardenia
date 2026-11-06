event_inherited();
var _aberto = state == 3 || guarda_quebrada > 0;
var _cor = _aberto ? make_colour_rgb(245, 209, 100) : make_colour_rgb(128, 184, 201);
draw_set_color(_cor);
if (_aberto) {
    // Losango e postura aberta comunicam vulnerabilidade sem depender so da cor.
    draw_triangle(x, bbox_top - 15, x - 5, bbox_top - 10, x, bbox_top - 5, true);
    draw_triangle(x, bbox_top - 15, x + 5, bbox_top - 10, x, bbox_top - 5, true);
} else {
    var _sx = x + lengthdir_x(21, guarda_dir);
    var _sy = y + lengthdir_y(21, guarda_dir);
    var _dx = lengthdir_x(15, guarda_dir + 90);
    var _dy = lengthdir_y(15, guarda_dir + 90);
    draw_line_width(_sx - _dx + 2, _sy - _dy + 3, _sx + _dx + 2, _sy + _dy + 3, 9);
    draw_set_color(guarda_flash > 0 ? c_white : make_colour_rgb(204, 225, 230));
    draw_line_width(_sx - _dx, _sy - _dy, _sx + _dx, _sy + _dy, 5);
}
draw_set_color(c_white);
