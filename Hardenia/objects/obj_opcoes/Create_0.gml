// Opcoes, como jogar e creditos: a mesma tela por cima do menu ou da pausa. modo: quem cria escolhe
modo = "opcoes";
cursor = 0;
tempo = 0;
mudou = false;
// [nome, leitura do valor, passo (-1 ou 1)]
itens = [
    {
        nome: "Música",
        tipo: "barra",
        ler: function() { return global.vol_musica; },
        mudar: function(_d) { global.vol_musica = clamp(round((global.vol_musica + _d * 0.1) * 10) / 10, 0, 1); volumes_aplicar(); },
    },
    {
        nome: "Efeitos",
        tipo: "barra",
        ler: function() { return global.vol_efeitos; },
        mudar: function(_d) { global.vol_efeitos = clamp(round((global.vol_efeitos + _d * 0.1) * 10) / 10, 0, 1); volumes_aplicar(); sfx(snd_confirm, 1, false); },
    },
    {
        nome: "Tremor da tela",
        tipo: "texto",
        ler: function() { return (global.op_tremor >= 1) ? "Normal" : ((global.op_tremor > 0) ? "Reduzido" : "Desligado"); },
        mudar: function(_d) { global.op_tremor = (global.op_tremor >= 1) ? 0.5 : ((global.op_tremor > 0) ? 0 : 1); },
    },
    {
        nome: "Clarões",
        tipo: "texto",
        ler: function() { return global.op_flash ? "Ligados" : "Desligados"; },
        mudar: function(_d) { global.op_flash = !global.op_flash; },
    },
    {
        nome: "Ambiente",
        tipo: "texto",
        ler: function() { return global.op_ambiente ? "Completo" : "Leve (aparelho fraco)"; },
        mudar: function(_d) { global.op_ambiente = !global.op_ambiente; },
    },
    {
        nome: "Dicas",
        tipo: "texto",
        ler: function() { return global.op_dicas ? "Ligadas" : "Desligadas"; },
        mudar: function(_d) {
            global.op_dicas = !global.op_dicas;
            // ligar de novo mostra todas outra vez: outra pessoa pode estar jogando
            if (global.op_dicas) {
                global.salvo.dicas = {};
            }
        },
    },
    {
        nome: "Tela cheia",
        tipo: "texto",
        ler: function() { return window_get_fullscreen() ? "Sim" : "Não"; },
        mudar: function(_d) { window_set_fullscreen(!window_get_fullscreen()); },
    },
    {
        nome: "Voltar",
        tipo: "sair",
        ler: function() { return ""; },
        mudar: function(_d) {},
    },
];
// [esquerda, cima, direita, baixo] do item, na tela
item_ret = function(_i) {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _esc = max(1, _h / 540);
    var _y = _h / 2 - 118 * _esc + _i * 30 * _esc;
    return [_w / 2 - 220 * _esc, _y, _w / 2 + 220 * _esc, _y + 26 * _esc];
};
fechar = function() {
    if (mudou) {
        salvo_gravar();
    }
    instance_destroy();
};
