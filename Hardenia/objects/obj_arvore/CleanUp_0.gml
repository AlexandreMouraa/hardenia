// Fecha apenas a consulta; a pausa ou escolha de baixo continuam abertas.
window_set_cursor(global.game_paused || instance_exists(obj_tecnicas) ? cr_default : cr_none);

global.consulta_bloqueio = 8;
with (obj_tecnicas) tempo = 0;
