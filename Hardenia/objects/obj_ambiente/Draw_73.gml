if (!global.op_ambiente || def == undefined) {
    exit;
}
var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam);
var _ch = camera_get_view_height(_cam);

// clima: a posicao sai do relogio e do numero da particula, sem guardar nada e sem sorteio. Ela
// fica presa ao mundo, e a conta so da a volta na camera, para nunca faltar particula na tela
if (clima != undefined) {
    var _t = current_time / 16.667;
    if (clima.soma) {
        gpu_set_blendmode(bm_add);
    }
    draw_set_color(clima.cor);
    for (var _i = 0; _i < clima.n; _i++) {
        var _f1 = frac(_i * 0.618034);
        var _f2 = frac(_i * 0.754877);
        var _f3 = frac(_i * 0.569840);
        var _vel = 0.6 + 0.8 * _f3;
        var _px = _f1 * 4096 + _t * clima.vx * _vel + clima.balanco * sin(_t * 0.02 + _i);
        var _py = _f2 * 4096 + _t * clima.vy * _vel;
        var _dx = _px - _cx;
        var _dy = _py - _cy;
        _dx = _dx - _cw * floor(_dx / _cw);
        _dy = _dy - _ch * floor(_dy / _ch);
        var _r = clima.tam * (0.6 + 0.8 * _f1);
        draw_set_alpha(clima.alfa * (0.4 + 0.6 * _f2));
        draw_rectangle(_cx + _dx, _cy + _dy, _cx + _dx + _r, _cy + _dy + _r, false);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

gpu_set_tex_filter(true);
draw_sprite_stretched_ext(spr_vinheta, 0, _cx, _cy, _cw, _ch, c_white, def.vinheta);
gpu_set_tex_filter(false);
