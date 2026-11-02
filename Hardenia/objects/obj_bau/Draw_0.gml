// fechado, brilha para chamar: e por ele que o jogador tem de passar
if (!aberto) {
    var _pulso = 0.5 + 0.5 * sin(current_time / 180);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.12 + 0.2 * _pulso);
    draw_set_color(global.caidos.sentinela.cor);
    draw_circle(x, y, 30 + 8 * _pulso, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}
draw_self();
