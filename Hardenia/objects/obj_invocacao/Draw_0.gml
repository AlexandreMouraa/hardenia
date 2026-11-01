var _t = 1 - tempo / aviso;
draw_set_color(make_colour_rgb(110, 230, 120));
draw_set_alpha(0.25 + 0.55 * _t);
draw_circle(x, y, 26, true);
draw_circle(x, y, 26 * _t, false);
draw_set_alpha(1);
draw_set_color(c_white);
