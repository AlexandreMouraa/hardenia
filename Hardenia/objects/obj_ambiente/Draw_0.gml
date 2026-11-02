if (!global.op_ambiente) {
    exit;
}
var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam);
var _ch = camera_get_view_height(_cam);

if (def != undefined) {
    var _sw = 576;
    var _sh = 324;
    if (!surface_exists(superficie)) {
        superficie = surface_create(_sw, _sh);
    }
    var _ex = _sw / _cw;
    var _ey = _sh / _ch;
    // cada fase do chefe escurece mais a sala
    var _escuro = def.escuro;
    with (obj_enemy_chefe) {
        _escuro += 0.12 * (fase - 1);
    }
    surface_set_target(superficie);
    draw_clear_alpha(def.cor, min(0.85, _escuro));
    // apaga a escuridao onde tem luz: tira o alfa, em vez de somar cor
    gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);
    var _t = current_time / 1000;
    for (var _i = 0; _i < array_length(def.luzes); _i++) {
        var _l = def.luzes[_i];
        var _r = (170 + 12 * sin(_t * (5 + _i) + _i)) / 64;
        draw_sprite_ext(spr_luz, 0, (_l[0] - _cx) * _ex, (_l[1] - _cy) * _ey, _r * _ex, _r * _ey, 0, c_white, 0.9);
    }
    if (instance_exists(obj_player)) {
        var _rj = def.raio / 64;
        draw_sprite_ext(spr_luz, 0, (obj_player.x - _cx) * _ex, (obj_player.y - _cy) * _ey, _rj * _ex, _rj * _ey, 0, c_white, 1);
    }
    with (obj_bau) {
        if (!aberto) {
            draw_sprite_ext(spr_luz, 0, (x - _cx) * _ex, (y - _cy) * _ey, 2.4 * _ex, 2.4 * _ey, 0, c_white, 1);
        }
    }
    gpu_set_blendmode(bm_normal);
    surface_reset_target();
    gpu_set_tex_filter(true);
    draw_surface_stretched(superficie, _cx, _cy, _cw, _ch);
    gpu_set_tex_filter(false);
}

// sombra no chao: pregam os personagens no lugar. Inimigo de horda fica sem, pelo numero deles
with (obj_enemy) {
    if (!leve) {
        var _ls = (bbox_right - bbox_left) / 64;
        draw_sprite_ext(spr_luz, 0, x, bbox_bottom - 2, _ls, _ls * 0.34, 0, c_black, 0.55);
    }
}
with (obj_player) {
    draw_sprite_ext(spr_luz, 0, x, bbox_bottom - 1, 0.42, 0.16, 0, c_black, 0.55);
}
