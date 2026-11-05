if (global.game_paused || global.hitstop > 0) {
    exit;
}

var _de_x = x;
var _de_y = y;
x += lengthdir_x(velocidade, direcao);
y += lengthdir_y(velocidade, direcao);
vida -= 1;

if (vida <= 0 || collision_point(x, y, obj_wall, false, true) != noone) {
    instance_destroy();
    exit;
}

if (patio_segmento(_de_x, _de_y, x, y)) {
    instance_destroy();
    exit;
}

// o caminho do frame inteiro, nao so o ponto: a 14 px por frame ela pularia um alvo fino
if (instance_exists(obj_player)) {
    var _p = instance_find(obj_player, 0);
    if (_p.invuln_timer <= 0 && !_p.is_dashing && segmento_toca_retangulo(_de_x, _de_y, x, y, _p.bbox_left, _p.bbox_top, _p.bbox_right, _p.bbox_bottom)) {
        _p.morto_por = causa;
        _p.levar_dano(1);
        instance_destroy();
    }
}
