var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _esc = max(1, _h / 540);
var _inimigos = instance_number(obj_enemy);
// pisca sem nunca sumir: no minimo 40% visivel
var _piscar = 0.4 + 0.6 * (0.5 + 0.5 * sin(current_time / 200));

// HUD: tentativa e cargas de dash
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text_transformed(16 * _esc, 12 * _esc, "TENTATIVA " + string(global.tentativas), _esc, _esc, 0);

for (var _i = 0; _i < dash_charges_max; _i++) {
    var _px = 16 * _esc + _i * 16 * _esc;
    var _py = 36 * _esc;
    draw_set_color(_i < dash_charges ? c_white : c_dkgray);
    draw_rectangle(_px, _py, _px + 12 * _esc, _py + 6 * _esc, false);
}
draw_set_color(c_ltgray);
draw_text_transformed(16 * _esc + dash_charges_max * 16 * _esc + 4 * _esc, 33 * _esc, "DASH", _esc * 0.7, _esc * 0.7, 0);

// HUD: fase atual, contando as salas depois do menu na ordem do projeto
var _fase = 0;
var _total = 0;
var _r = room_next(room_first);
while (_r != -1) {
    _total += 1;
    if (_r == room) {
        _fase = _total;
    }
    _r = room_next(_r);
}
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text_transformed(_w / 2, 12 * _esc, "FASE " + string(_fase) + " / " + string(_total), _esc, _esc, 0);
draw_set_halign(fa_left);

// HUD: inimigos restantes ou portao aberto
draw_set_halign(fa_right);
if (_inimigos > 0) {
    draw_set_color(c_white);
    draw_text_transformed(_w - 16 * _esc, 12 * _esc, "INIMIGOS: " + string(_inimigos), _esc, _esc, 0);
} else if (room != room_last) {
    draw_set_color(c_yellow);
    draw_set_alpha(_piscar);
    draw_text_transformed(_w - 16 * _esc, 12 * _esc, "PORTAO ABERTO", _esc, _esc, 0);
    draw_set_alpha(1);
}

// seta na borda da tela apontando para o portao aberto quando ele esta fora
// da camera
if (_inimigos == 0 && room != room_last && !is_dead && !venceu) {
    var _saida = noone;
    with (obj_exit_to_room1) {
        if (room_next(room) == Room1) {
            _saida = id;
        }
    }
    with (obj_exit_to_room2) {
        if (room_next(room) == Room2) {
            _saida = id;
        }
    }
    with (obj_exit_to_room3) {
        if (room_next(room) == Room3) {
            _saida = id;
        }
    }
    if (_saida != noone) {
        var _cam = view_camera[0];
        var _cx = camera_get_view_x(_cam);
        var _cy = camera_get_view_y(_cam);
        var _cw = camera_get_view_width(_cam);
        var _ch = camera_get_view_height(_cam);
        var _sx = ((_saida.bbox_left + _saida.bbox_right) / 2 - _cx) / _cw * _w;
        var _sy = ((_saida.bbox_top + _saida.bbox_bottom) / 2 - _cy) / _ch * _h;
        if (_sx < 0 || _sx > _w || _sy < 0 || _sy > _h) {
            var _dir = point_direction(_w / 2, _h / 2, _sx, _sy);
            var _ax = clamp(_sx, 40 * _esc, _w - 40 * _esc);
            var _ay = clamp(_sy, 40 * _esc, _h - 40 * _esc);
            var _t = 16 * _esc;
            draw_set_color(c_yellow);
            draw_set_alpha(_piscar);
            draw_triangle(_ax + lengthdir_x(_t, _dir), _ay + lengthdir_y(_t, _dir),
                _ax + lengthdir_x(_t, _dir + 140), _ay + lengthdir_y(_t, _dir + 140),
                _ax + lengthdir_x(_t, _dir - 140), _ay + lengthdir_y(_t, _dir - 140), false);
            draw_set_alpha(1);
        }
    }
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// dica do objetivo nos primeiros segundos da primeira sala, so na 1a tentativa
if (room == room_next(room_first) && global.tentativas == 1 && tempo_na_sala < 300 && !is_dead) {
    draw_set_alpha(min(1, (300 - tempo_na_sala) / 60));
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h * 0.2, "DERROTE TODOS OS INIMIGOS PARA ABRIR O PORTAO", _esc, _esc, 0);
    draw_set_color(c_ltgray);
    draw_text_transformed(_w / 2, _h * 0.2 + 24 * _esc, "Saia da area vermelha antes do golpe.   ESC: pausa e controles", _esc * 0.8, _esc * 0.8, 0);
    draw_set_alpha(1);
}

if (is_dead) {
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    draw_set_color(c_red);
    draw_text_transformed(_w / 2, _h / 2 - 20 * _esc, "VOCE MORREU", _esc * 3, _esc * 3, 0);
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h / 2 + 24 * _esc, "Cada morte ensina.", _esc, _esc, 0);
} else if (venceu) {
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    draw_set_color(c_red);
    draw_text_transformed(_w / 2, _h / 2 - 40 * _esc, "VITORIA", _esc * 3, _esc * 3, 0);
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h / 2 + 8 * _esc, "O ultimo guerreiro venceu em " + string(global.tentativas) + " tentativa(s).", _esc, _esc, 0);
    draw_set_alpha(_piscar);
    draw_text_transformed(_w / 2, _h / 2 + 40 * _esc, "PRESSIONE ENTER PARA VOLTAR AO MENU", _esc, _esc, 0);
    draw_set_alpha(1);
}

if (global.game_paused) {
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(_piscar);
    draw_set_color(c_white);
    draw_text_transformed(_w / 2, _h / 2 - 40 * _esc, "PAUSADO", _esc * 2, _esc * 2, 0);
    draw_set_alpha(1);
    draw_text_transformed(_w / 2, _h / 2, "WASD / SETAS: mover    J: atacar    ESPACO: dash", _esc, _esc, 0);
    draw_text_transformed(_w / 2, _h / 2 + 32 * _esc, "ESC: CONTINUAR    M: VOLTAR AO MENU", _esc, _esc, 0);
}

if (fade > 0) {
    draw_set_alpha(fade);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    fade = max(0, fade - 0.05);
}

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
