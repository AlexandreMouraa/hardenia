// zona do golpe: contorno durante o aviso, preenchida enquanto o golpe acontece.
// mesmo tamanho da hitbox do obj_enemy_attack (spr_attack, origem no centro).
if (state == 1 || state == 2) {
    var _zx = (state == 2) ? golpe_x : x + lengthdir_x(attack_reach, attack_dir);
    var _zy = (state == 2) ? golpe_y : y + lengthdir_y(attack_reach, attack_dir);
    var _r = sprite_get_width(spr_attack) / 2;
    draw_set_color(c_red);
    if (state == 1) {
        draw_set_alpha(0.15);
        draw_roundrect_ext(_zx - _r, _zy - _r, _zx + _r, _zy + _r, 16, 16, false);
        draw_set_alpha(0.3 + 0.7 * (1 - state_timer / windup_time));
        draw_roundrect_ext(_zx - _r, _zy - _r, _zx + _r, _zy + _r, 16, 16, true);
        draw_roundrect_ext(_zx - _r + 1, _zy - _r + 1, _zx + _r - 1, _zy + _r - 1, 16, 16, true);
    } else {
        draw_set_alpha(0.6 * state_timer / attack_time);
        draw_roundrect_ext(_zx - _r, _zy - _r, _zx + _r, _zy + _r, 16, 16, false);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

draw_self();

// flash branco ao levar dano
if (hit_flash > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, 0.8);
    gpu_set_blendmode(bm_normal);
}

if (state == 1) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_red);
    draw_text_transformed(x, bbox_top - 2, "!", 2, 2, 0);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
