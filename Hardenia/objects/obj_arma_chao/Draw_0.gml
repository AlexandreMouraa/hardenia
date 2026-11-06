var _cor = arma_cor(arma);
// cai do alto ate pousar; depois flutua devagar
var _alto = (pousar > 0) ? 24 * pousar / pousar_max : 2 + 2 * sin(tempo / 20);
// brilho no chao, na cor de quem deixou
draw_set_alpha(0.22 + 0.08 * sin(tempo / 15));
draw_set_color(_cor);
draw_ellipse(x - 16, y - 5, x + 16, y + 7, false);
draw_set_alpha(1);
arma_icone(arma, x, y - 10 - _alto, 12, _cor);
// o nome, so quando da para pegar
if (pousar <= 0 && !espera) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(_cor);
    texto(x, y - 30 - _alto, arma_def(arma).nome, 0.45, 0.45, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
draw_set_color(c_white);
