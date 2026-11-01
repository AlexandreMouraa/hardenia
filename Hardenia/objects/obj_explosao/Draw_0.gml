// como o aviso do inimigo: contorno que acende, depois a zona preenchida
draw_set_color(make_colour_rgb(255, 120, 20));
if (estado == 1) {
    zona_desenhar(zona, 0.15, 0.3 + 0.7 * (1 - tempo / aviso));
} else {
    zona_desenhar(zona, 0.6 * tempo / duracao, 0);
}
draw_set_alpha(1);
draw_set_color(c_white);
