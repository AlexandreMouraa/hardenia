event_inherited();

if (global.game_paused || global.hitstop > 0) {
    exit;
}

// o escudo da Sentinela volta depois de 7 s: da tempo de bater, e depois tem de quebrar de novo
if (elite == "escudo" && !escudo) {
    escudo_volta += 1;
    if (escudo_volta >= 420) {
        escudo_volta = 0;
        escudo = true;
        som(snd_escudo, 1);
    }
}
fala_tempo = max(0, fala_tempo - 1);
