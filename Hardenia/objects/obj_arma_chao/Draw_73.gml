// o nome, so quando da para pegar. No Draw End, por cima de tudo: a arma fica na profundidade 55,
// abaixo dos personagens, e cai a 56 px do bau; no Draw o bau e o heroi tampavam o nome
if (pousar <= 0 && !espera) {
    var _alto = 2 + 2 * sin(tempo / 20);
    var _nome = arma_def(arma).nome;
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    // sombra de 1 px, para ler em cima do bau e do chao claro da neve
    draw_set_color(c_black);
    texto(x + 1, y - 29 - _alto, _nome, 0.45, 0.45, 0);
    draw_set_color(arma_cor(arma));
    texto(x, y - 30 - _alto, _nome, 0.45, 0.45, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
