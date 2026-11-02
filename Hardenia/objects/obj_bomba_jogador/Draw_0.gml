// sobe e desce em arco; no chao, pisca mais rapido perto de explodir
var _t = (voo > 0) ? min(1, tempo / voo) : 1;
var _alto = 70 * 4 * _t * (1 - _t);
draw_set_color(c_black);
draw_set_alpha(0.35);
draw_ellipse(x - 12, y + 4, x + 12, y + 12, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_sprite_ext(spr_bomba, (tempo div 4) mod 2, x, y - _alto, 0.75, 0.75, tempo * 8, c_white, 1);
if (tempo > voo) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(spr_bomba, 0, x, y - _alto, 0.75, 0.75, tempo * 8, c_orange, ((tempo div 3) mod 2 == 0) ? 0.7 : 0);
    gpu_set_blendmode(bm_normal);
}
