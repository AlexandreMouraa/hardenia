// Escuridao, sombras e clima da sala (scr_ambiente). Criado pelo obj_player, entre o chao (100) e
// os personagens (0): o que este objeto desenha no Draw fica embaixo de todo mundo
def = ambiente_da_sala();
clima = (def != undefined) ? clima_def(def.clima) : undefined;
// metade do tamanho da camera: luz e borrada de qualquer jeito, e pesa menos
superficie = -1;
