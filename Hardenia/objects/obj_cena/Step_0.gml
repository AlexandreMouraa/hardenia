global.hitstop = 1;
if (global.game_paused) {
    exit;
}
tempo += 1;
var _pular = tempo > pode_pular && !instance_exists(obj_autotest) && aperto_de_passar();
if (tempo >= duracao || _pular) {
    instance_destroy();
}
