// como o aviso do inimigo: enche a zona ate a hora, depois pisca e some
var _cor = make_colour_rgb(255, 120, 20);
if (estado == 1) {
    zona_aviso_desenhar(zona, 1 - tempo / aviso, _cor);
} else {
    zona_golpe_desenhar(zona, tempo / duracao, _cor);
}
