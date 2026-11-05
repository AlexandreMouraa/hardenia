event_inherited();
var _cor = make_colour_rgb(120, 235, 176);
// Insignia sempre visivel; forma de cruz distingue suporte dos avisos de perigo.
draw_set_color(cura_interrompida > 0 ? c_white : _cor);
var _cx = x;
var _cy = bbox_top - 14;
draw_rectangle(_cx - 2, _cy - 7, _cx + 2, _cy + 7, false);
draw_rectangle(_cx - 7, _cy - 2, _cx + 7, _cy + 2, false);
if (cura_conjurando && instance_exists(cura_alvo)) {
    var _p = 1 - cura_tempo / cura_aviso;
    draw_set_alpha(0.45 + 0.4 * _p);
    draw_line_width(x, y - 12, cura_alvo.x, cura_alvo.y - 12, 2);
    draw_circle(x, y, 22 + 5 * _p, true);
    draw_circle(cura_alvo.x, cura_alvo.y, 28, true);
    draw_set_alpha(1);
    draw_set_color(make_colour_rgb(26, 48, 39));
    draw_rectangle(x - 22, _cy - 16, x + 22, _cy - 12, false);
    draw_set_color(_cor);
    draw_rectangle(x - 22, _cy - 16, x - 22 + 44 * _p, _cy - 12, false);
}
if (cura_interrompida > 0) {
    draw_set_color(c_white);
    draw_line_width(x - 10, _cy - 10, x + 10, _cy + 10, 2);
}
if (cura_pulso > 0) {
    draw_set_color(_cor);
    draw_set_alpha(cura_pulso / 24);
    draw_circle(x, y, 24 + (24 - cura_pulso) * 2, true);
}
draw_set_alpha(1);
draw_set_color(c_white);
