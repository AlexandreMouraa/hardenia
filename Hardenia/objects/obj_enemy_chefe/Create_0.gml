event_inherited();
// O Trono: o rei morto, no fim da run. Tres fases, cada uma com o proprio rodizio de ataques
// (scr_duelos), sempre com aviso e zona marcada. Valores para ajustar jogando. Sprite do LPC,
// com o dobro do tamanho
walk_sprite = spr_chefe_andar;
walk_frames = 8;
anim_speed = 7;
sprite_index = walk_sprite;
// os ataques trocam de pose; a mascara fica a do andar, para nao mudar de tamanho no meio
mask_index = spr_chefe_andar;
hp_max = 40;
hp = hp_max;
move_speed = 1.3;
imovel = true;
depois_golpe = "parado";
som_golpe = noone;
// a sala inteira e dele
visao = 2000;
raio_alerta = 0;
acordado = true;
// passou da primeira fase
metade = false;
fase = 1;
// a fala de quando muda de fase, embaixo da barra
fala = "";
fala_tempo = 0;

// aviso e recarga encurtam a cada fase
furia = 1;
var _golpe = spr_chefe_golpe;
var _magia = spr_chefe_magia;
// varredura: arco largo de perto
var _varredura = { sprite: _golpe, quadros: 6, ataque: { tipo: "arco", forma: "arco", gatilho: 170, alcance: 190, tamanho: 70, aviso: 55, duracao: 20, acerto: 10, recarga: 50, avanco: 0 } };
// investida: linha atravessando a sala. 24 frames de 20 px = 480, dentro da linha de 520;
// as colunas param, entao elas sao o abrigo
var _investida = { sprite: _golpe, quadros: 6, ataque: { tipo: "investida", forma: "linha", gatilho: 420, alcance: 520, tamanho: 34, aviso: 50, duracao: 40, acerto: 24, recarga: 80, avanco: 20 } };
// estouro: para quem ficou colado nele
var _estouro = { sprite: _magia, quadros: 7, ataque: { tipo: "estouro", forma: "circulo", gatilho: 230, alcance: 0, tamanho: 170, aviso: 60, duracao: 16, acerto: 6, recarga: 70, avanco: 0 } };
// leque: tres linhas saindo dele. So se sai de lado, e as colunas ainda protegem
var _leque = { sprite: _golpe, quadros: 6, ataque: { tipo: "leque", forma: "linha", gatilho: 600, alcance: 560, tamanho: 26, aviso: 58, duracao: 20, acerto: 8, recarga: 70, avanco: 0, extras: 1 } };
fases = [
    [
        _varredura,
        _investida,
        { sprite: _magia, quadros: 7, ataque: { tipo: "bombas", forma: "circulo", gatilho: 600, alcance: 0, tamanho: 80, aviso: 65, duracao: 16, acerto: 6, recarga: 70, avanco: 0, extras: 2 } },
    ],
    [
        _varredura,
        _estouro,
        _investida,
        { sprite: _magia, quadros: 7, ataque: { tipo: "bombas", forma: "circulo", gatilho: 600, alcance: 0, tamanho: 80, aviso: 65, duracao: 16, acerto: 6, recarga: 70, avanco: 0, extras: 4 } },
    ],
    [
        _leque,
        _varredura,
        _estouro,
        { sprite: _magia, quadros: 7, ataque: { tipo: "bombas", forma: "circulo", gatilho: 600, alcance: 0, tamanho: 80, aviso: 65, duracao: 16, acerto: 6, recarga: 60, avanco: 0, extras: 6 } },
        _investida,
    ],
];
ataques = fases[0];
ataque_vez = 0;
rodizio_trocar();
ao_voltar = rodizio_trocar;
ao_mirar = rodizio_mirar;
disparar_golpe = disparar;
disparar = function() {
    rodizio_disparar();
    disparar_golpe();
};

// o golpe que estiver no meio termina; a janela de bater nele vem antes do rodizio novo
mudar_fase = function(_fase) {
    fase = _fase;
    metade = true;
    furia = (_fase == 2) ? 0.85 : 0.7;
    move_speed = (_fase == 2) ? 1.6 : 2;
    ataques = fases[_fase - 1];
    ataque_vez = 0;
    fala = (_fase == 2) ? global.fala_rei_fase2 : global.fala_rei_fase3;
    fala_tempo = 200;
    if (_fase == 2) {
        elite = "invocacao";
        invocar_timer = 60;
    }
    if (state == 0 || state == 3) {
        state = 3;
        state_timer = 70;
    }
    impacto(8, 12);
    global.lento = max(global.lento, 30);
    som(snd_explosao);
    fx_onda(x, y, 240, make_colour_rgb(255, 60, 60));
    with (instance_create_depth(x, y, 50, obj_fx)) {
        tipo = "anel";
        cor = make_colour_rgb(255, 60, 60);
        vida_max = 20;
        vida = vida_max;
    }
};
