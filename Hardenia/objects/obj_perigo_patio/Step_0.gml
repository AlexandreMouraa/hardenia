if (patio_parado()) exit;
if (tipo == "armadilha" && estado == 0) {
    // So dispara por proximidade. Ha um segundo inteiro para sair antes dos espinhos.
    var _pisou = point_distance(x, y, obj_player.x, obj_player.y) < raio;
    with (obj_enemy) {
        if (point_distance(x, y, other.x, other.y) < other.raio) _pisou = true;
    }
    if (_pisou) {
        estado = 1;
        tempo = aviso;
        sfx(snd_escudo, 1, false, 0.35);
    }
}
if (estado == 0 || (tipo == "barril" && estado == 3)) exit;
tempo -= 1;
if (tempo > 0) exit;
if (estado == 1) {
    estado = 2;
    tempo = 18; // janela visual; o dano acontece uma vez, no mesmo quadro do disparo
    patio_atingir(id);
    if (tipo == "barril") {
        sfx(snd_explosao, 1, false, 0.8);
        fx_explosao(x, y, raio);
        impacto(3, 5);
    } else {
        sfx(snd_inimigo_golpe, 1, false, 0.7);
        fx_onda(x, y, raio, make_colour_rgb(255, 190, 80));
    }
} else if (estado == 2) {
    estado = 3;
    tempo = 180; // tres segundos para reposicionar antes de a armadilha rearmar
} else {
    estado = 0;
}
