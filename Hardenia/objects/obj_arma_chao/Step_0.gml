if (global.game_paused || global.hitstop > 0) {
    exit;
}
tempo += 1;
if (pousar > 0) {
    pousar -= 1;
    exit;
}
// com a escolha, as cartas, o mapa ou uma cena na tela, espera
if (!instance_exists(obj_player) || instance_exists(obj_tecnicas) || instance_exists(obj_cena) || instance_exists(obj_mapa)) {
    exit;
}
var _p = instance_find(obj_player, 0);
if (_p.is_dead || _p.venceu) {
    exit;
}
var _d = point_distance(x, y, _p.x, _p.y);
if (espera) {
    // 64 px: o dobro do alcance de pegar, para nao abrir de novo com um passo
    if (_d > 64) {
        espera = false;
    }
    exit;
}
// so com a sala limpa: no meio da luta a escolha atrapalharia
if (_d < 32 && instance_number(obj_enemy) == 0) {
    instance_create_depth(0, 0, -2000, obj_arma_escolha, { chao: id });
}
