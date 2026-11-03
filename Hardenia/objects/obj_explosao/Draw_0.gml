// como o aviso do inimigo: enche a zona ate a hora, depois pisca e some
var _cor = make_colour_rgb(255, 120, 20);
if (estado == 1) {
    zona_aviso_desenhar(zona, 1 - tempo / aviso, _cor);
    if (bomba) {
        bomba_sombra_desenhar(x, y, 1 - tempo / aviso);
    }
} else {
    zona_golpe_desenhar(zona, tempo / duracao, _cor);
}
