event_inherited();

if (global.game_paused || global.hitstop > 0) {
    exit;
}

fala_tempo = max(0, fala_tempo - 1);

// muda a cada terco da vida
if (fase == 1 && hp <= hp_max * 2 / 3) {
    mudar_fase(2);
} else if (fase == 2 && hp <= hp_max / 3) {
    mudar_fase(3);
}
