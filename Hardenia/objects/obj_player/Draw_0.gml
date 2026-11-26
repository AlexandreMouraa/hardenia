// segurando o especial com a Furia cheia: um anel fecha em volta do corpo
if (especial_carga > 0) {
    var _fecha = especial_carga / especial_carga_max;
    draw_set_color(make_colour_rgb(255, 120, 60));
    draw_set_alpha(0.3 + 0.6 * _fecha);
    draw_circle(x, y, 70 - 40 * _fecha, true);
    draw_circle(x, y, 69 - 40 * _fecha, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
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
// o corpo vai junto com o golpe e volta, so no desenho
var _dx = 0;
var _dy = 0;
if (is_attacking) {
    var _ida = sin(pi * (1 - attack_anim_timer / attack_anim_duration)) * (golpe_atual == 3 ? 6 : 4);
    _dx = lengthdir_x(_ida, ataque_dir);
    _dy = lengthdir_y(_ida, ataque_dir);
}
draw_sprite_ext(sprite_index, image_index, x + _dx, y + _dy, _sx, _sy, 0, image_blend, image_alpha);
if (brilho > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x + _dx, y + _dy, _sx, _sy, 0, c_white, brilho * image_alpha);
    gpu_set_blendmode(bm_normal);
}

// robo com -diag: a caixa que leva golpe e o arco que o golpe cobre, para conferir nos prints
if (instance_exists(obj_autotest) && obj_autotest.diag) {
    draw_set_color(c_lime);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    with (obj_attack) {
        draw_set_color(c_yellow);
        if (setor) {
            var _a0 = dir - abertura / 2;
            var _ax = ox;
            var _ay = oy;
            for (var _k = 0; _k <= 12; _k++) {
                var _bx = ox + lengthdir_x(raio, _a0 + abertura * _k / 12);
                var _by = oy + lengthdir_y(raio, _a0 + abertura * _k / 12);
                draw_line(_ax, _ay, _bx, _by);
                _ax = _bx;
                _ay = _by;
            }
            draw_line(_ax, _ay, ox, oy);
        } else {
            draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
        }
    }
    draw_set_color(c_white);
}
