// zona do golpe, fraca no chao: enche ate a hora do golpe e pisca quando ele acontece. E a
// mesma zona que o obj_enemy_attack testa no acerto
if (zona_visivel) {
    if (state == 1) {
        zona_aviso_desenhar(zona, 1 - state_timer / ataque.aviso, make_colour_rgb(200, 40, 40));
        if (bomba) {
            bomba_sombra_desenhar(zona.cx, zona.cy, 1 - state_timer / ataque.aviso);
        }
    } else if (state == 2 && ataque.duracao - state_timer < ataque.acerto) {
        zona_golpe_desenhar(zona, 1 - (ataque.duracao - state_timer) / ataque.acerto, make_colour_rgb(220, 50, 40));
    }
}

if (elite != "") {
    elite_desenhar();
}

// pose do golpe, so no desenho: a mascara e a zona continuam no lugar. O corpo vai para tras
// durante o aviso, treme no fim e bate para a frente. Quem tem folha de ataque ja tem a pose
var _dx = 0;
var _dy = 0;
var _giro = 0;
var _brasa = 0;
if (state == 1 || state == 2) {
    var _lado = (lengthdir_x(1, attack_dir) >= 0) ? -1 : 1;
    if (state == 1) {
        var _t = 1 - state_timer / ataque.aviso;
        _brasa = 0.1 + 0.6 * _t * _t;
        if (ataque_sprite == noone) {
            var _recuo = -9 * sin(_t * pi / 2);
            _dx = lengthdir_x(_recuo, attack_dir);
            _dy = lengthdir_y(_recuo, attack_dir);
            _giro = -_lado * 10 * _t;
            if (_t > 0.7) {
                _dx += 1.5 * sin(state_timer * 1.9);
            }
        }
    } else if (ataque_sprite == noone && ataque.avanco == 0) {
        var _g = min(1, (ataque.duracao - state_timer) / 8);
        var _ida = 13 * sin(_g * pi);
        _dx = lengthdir_x(_ida, attack_dir);
        _dy = lengthdir_y(_ida, attack_dir);
        _giro = _lado * 14 * (1 - _g);
    }
}
draw_sprite_ext(sprite_index, image_index, x + _dx, y + _dy, image_xscale, image_yscale, image_angle + _giro, image_blend, image_alpha);

if (_brasa > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x + _dx, y + _dy, image_xscale, image_yscale, image_angle + _giro, make_colour_rgb(255, 50, 30), _brasa);
    gpu_set_blendmode(bm_normal);
}

// flash branco ao levar dano
if (hit_flash > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x + _dx, y + _dy, image_xscale, image_yscale, image_angle + _giro, c_white, 0.8);
    gpu_set_blendmode(bm_normal);
}

if (ao_desenhar != undefined) {
    ao_desenhar();
}

// acabou de notar o jogador
if (alerta > 0) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(make_colour_rgb(255, 210, 90));
    draw_set_alpha(min(1, alerta / 10));
    draw_text_transformed(x, bbox_top - 2 - (30 - alerta) * 0.3, "!", 2, 2, 0);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
