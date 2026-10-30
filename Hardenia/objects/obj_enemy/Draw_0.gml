// zona do golpe: contorno durante o aviso, preenchida enquanto o golpe acontece.
// a mesma zona que o obj_enemy_attack testa no acerto
if (state == 1 || state == 2) {
    draw_set_color(c_red);
    if (state == 1) {
        zona_desenhar(zona, 0.15, 0.3 + 0.7 * (1 - state_timer / ataque.aviso));
    } else {
        zona_desenhar(zona, 0.6 * state_timer / ataque.duracao, 0);
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
