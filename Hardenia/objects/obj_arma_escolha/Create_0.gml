// Escolha da arma do chao (scr_armas): ficar com a da mao ou trocar pela do Caido. E filha do
// obj_tecnicas para o jogo tratar como a tela de cartas: o mundo para, o golpe nao sai, a pausa
// nao abre e as dicas somem. A limpeza (CleanUp) e herdada. chao: quem abriu (obj_arma_chao),
// passado na criacao
oferta = [{ chave: global.arma }, { chave: chao.arma }];
// comeca em "trocar": quem chegou perto quer ver a arma nova
cursor = 1;
escolhido = -1;
tempo = 0;
saindo = 0;
mouse_antes_x = -1;
mouse_antes_y = -1;
global.hitstop = 1;
window_set_cursor(cr_default);

escolher = function(_i) {
    if (escolhido >= 0) {
        return;
    }
    escolhido = _i;
    if (_i == 1 && instance_exists(chao)) {
        arma_trocar(chao);
    } else {
        if (instance_exists(chao)) {
            chao.espera = true;
        }
        sfx(snd_confirm, 1, false);
    }
    // alguns frames para ver a escolha, e para o mesmo aperto nao virar um golpe no jogo
    saindo = 16;
};

// [esquerda, cima, direita, baixo], na tela: duas cartas lado a lado
carta = function(_i) {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _esc = max(1, _h / 540);
    var _cw = 210 * _esc;
    var _ch = 190 * _esc;
    var _vao = 24 * _esc;
    var _x0 = _w / 2 - (2 * _cw + _vao) / 2;
    var _y0 = _h / 2 - _ch / 2 + 10 * _esc;
    return [_x0 + _i * (_cw + _vao), _y0, _x0 + _i * (_cw + _vao) + _cw, _y0 + _ch];
};
