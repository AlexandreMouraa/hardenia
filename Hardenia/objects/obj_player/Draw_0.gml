// seta junto do corpo apontando para onde o golpe vai, quando a mira e o mouse
if (global.mira_mouse && !is_dead && !venceu && mostra_mira()) {
    var _m = mira_alvo();
    var _a = point_direction(x, y, _m[0], _m[1]);
    var _bx = x + lengthdir_x(27, _a);
    var _by = y + lengthdir_y(27, _a);
    draw_set_alpha(0.55);
    draw_triangle_colour(x + lengthdir_x(35, _a), y + lengthdir_y(35, _a),
        _bx + lengthdir_x(5, _a + 90), _by + lengthdir_y(5, _a + 90),
        _bx + lengthdir_x(5, _a - 90), _by + lengthdir_y(5, _a - 90),
        c_red, c_red, c_red, false);
    draw_set_alpha(1);
}

// estica na direcao do dash e achata um pouco ao frear. So no desenho: a
// mascara de colisao continua a mesma. Brilho branco ao arrancar e quando a
// carga do dash volta
var _e = 0;
if (is_dashing) {
    _e = 0.22 * dash_timer / dash_duration;
} else if (dash_freio > 0) {
    _e = -0.12 * dash_freio / dash_freio_max;
}
var _ao_longo = 1 + _e;
var _de_lado = 1 - 0.6 * _e;
var _hx = dash_dir_x * dash_dir_x; // 1 no dash na horizontal, 0 na vertical, 0.5 na diagonal
var _sx = lerp(_de_lado, _ao_longo, _hx);
var _sy = lerp(_ao_longo, _de_lado, _hx);
draw_sprite_ext(sprite_index, image_index, x, y, _sx, _sy, 0, image_blend, image_alpha);
if (brilho > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, _sx, _sy, 0, c_white, brilho * image_alpha);
    gpu_set_blendmode(bm_normal);
}
