// agora ela e o unico aviso no ar: maior que o sprite, com um rastro curto de luz
var _tx = lengthdir_x(46, direcao);
var _ty = lengthdir_y(46, direcao);
var _lx = lengthdir_x(2, direcao + 90);
var _ly = lengthdir_y(2, direcao + 90);
var _cor = make_colour_rgb(255, 225, 190);
gpu_set_blendmode(bm_add);
draw_primitive_begin(pr_trianglelist);
draw_vertex_colour(x - _tx, y - _ty, _cor, 0);
draw_vertex_colour(x + _lx, y + _ly, _cor, 0.7);
draw_vertex_colour(x - _lx, y - _ly, _cor, 0.7);
draw_primitive_end();
gpu_set_blendmode(bm_normal);
draw_sprite_ext(sprite_index, 0, x, y, 1.6, 1.6, direcao, c_white, 1);
