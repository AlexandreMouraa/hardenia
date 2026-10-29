if (global.game_paused) {
    exit;
}

vida -= 1;
image_alpha = vida / vida_max;
y -= 0.5;
if (vida <= 0) {
    instance_destroy();
}
