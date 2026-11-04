// barra de vida do chefe, no alto da tela. Os riscos marcam onde ele muda
barra_chefe("O Rei Morto", hp, hp_max, (fase == 1) ? make_colour_rgb(170, 20, 30) : ((fase == 2) ? make_colour_rgb(205, 40, 30) : make_colour_rgb(240, 80, 30)), [1 / 3, 2 / 3], fala, min(1, fala_tempo / 30));
