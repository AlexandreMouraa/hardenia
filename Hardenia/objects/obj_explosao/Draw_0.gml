// como o aviso do inimigo: enche a zona ate a hora, depois pisca e some
if (estado == 1) {
    zona_aviso_desenhar(zona, 1 - tempo / aviso, cor);
    if (bomba) {
        bomba_sombra_desenhar(x, y, 1 - tempo / aviso);
    }
} else {
    zona_golpe_desenhar(zona, tempo / duracao, cor);
}
