// continua animando durante a micro-pausa do impacto: as faiscas voam com o mundo parado
if (global.game_paused) {
    exit;
}

vida -= 1;
if (vida <= 0) {
    instance_destroy();
}
