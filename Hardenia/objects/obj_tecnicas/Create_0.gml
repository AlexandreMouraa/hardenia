// Tela de escolha de tecnica (scr_tecnicas): tres cartas, fica com uma. Enquanto ela esta aberta
// o mundo para pela mesma micro-pausa dos golpes, e o tempo da run nao conta
oferta = tecnicas_sortear();
// depois de um duelo, a tela diz quem deixou
caido_def = (global.caido_vencido != "") ? variable_struct_get(global.caidos, global.caido_vencido) : undefined;
global.caido_vencido = "";
cursor = (array_length(oferta) > 1) ? 1 : 0;
escolhido = -1;
tempo = 0;
saindo = 0;
mouse_antes_x = -1;
mouse_antes_y = -1;
global.hitstop = 1;
window_set_cursor(cr_default);
if (array_length(oferta) == 0) {
    instance_destroy();
}

escolher = function(_i) {
    if (escolhido >= 0) {
        return;
    }
    escolhido = _i;
    tecnica_ganhar(oferta[_i].chave);
    audio_play_sound(snd_confirm, 1, false);
    // alguns frames para ver a escolha, e para o mesmo aperto nao virar um golpe no jogo
    saindo = 16;
};

// [esquerda, cima, direita, baixo], na tela
carta = function(_i) {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _esc = max(1, _h / 540);
    var _cw = 180 * _esc;
    var _ch = 190 * _esc;
    var _vao = 16 * _esc;
    var _n = array_length(oferta);
    var _x0 = _w / 2 - (_n * _cw + (_n - 1) * _vao) / 2;
    var _y0 = _h / 2 - _ch / 2 + 10 * _esc;
    return [_x0 + _i * (_cw + _vao), _y0, _x0 + _i * (_cw + _vao) + _cw, _y0 + _ch];
};
