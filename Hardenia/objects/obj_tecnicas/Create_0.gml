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
    sfx(snd_confirm, 1, false);
    // alguns frames para ver a escolha, e para o mesmo aperto nao virar um golpe no jogo
    saindo = 16;
};

// [esquerda, cima, direita, baixo], na tela
carta = function(_i) {
    var _u = tecnicas_ui();
    var _n = array_length(oferta);
    var _x = (960 - (_n * 272 + (_n - 1) * 20)) / 2 + _i * 292;
    return tecnica_ret(_u, _x, 117, 272, 336);
};
