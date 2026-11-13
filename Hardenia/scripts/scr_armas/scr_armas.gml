// Armas dos Caidos (issue #95). O Caido vencido larga a arma no chao (obj_arma_chao); o jogador chega
// perto e escolhe trocar pela que tem na mao (obj_arma_escolha). A arma que sai da mao fica no chao, e
// da para voltar atras. Perde na morte, como as tecnicas (run_zerar): nada passa de uma run para outra.
// O Sapador nao larga arma: ele ja ensina as bombas.
//
// O desenho do heroi (40 x 48, do Woooly) tem a espada na mao. A arma aparece pelo arco do golpe (cor,
// abertura e raio), pelo alcance, pelo som (tom) e pelo nome no HUD.
//
// Cada arma tem os numeros do golpe comum e do golpe forte (o ultimo do combo e o carregado):
//   alcance: distancia do centro da area do golpe ao jogador; escala: tamanho da area (spr_attack, 64 px)
//   dano, empurra: dano e empurrao; recarga: frames ate o proximo golpe
//   janela: frames para emendar o proximo golpe do combo; combo: golpes ate o forte
//   quebra: todo golpe quebra o escudo da elite (sem a arma, so o carregado, a estocada e o giro)
//   arco, raio: abertura (graus) e raio (px) do corte desenhado; tom: tom do som do golpe
//   forte: a forma do golpe forte (obj_player, golpear). "arco": a area de sempre, na frente.
//     "impacto": acerta em volta do ponto do golpe, 72 px de raio, de uma vez. "estocada": linha de
//     150 px que atravessa a fila. "duplo": dois golpes, o segundo 6 quadros depois e mais a frente
//   furia, furia_texto: o nome e o que faz o golpe da Furia cheia (obj_player, giro_furioso). A turma
//     pediu armas mais diferentes entre si e os lideres, uma Furia para cada arma (13/11/2026)
// A espada e o golpe de sempre: os mesmos numeros de antes das armas, para o robo dar o mesmo resumo
// enquanto ninguem pega outra arma.
global.armas = {
    espada: {
        nome: "ESPADA", caido: "", texto: "Equilibrada: o golpe de sempre.",
        alcance: 32, escala: 1, dano: 1, empurra: 12, recarga: 20, janela: 34, combo: 3,
        alcance_forte: 36, escala_forte: 1.25, dano_forte: 2, empurra_forte: 28, recarga_forte: 36,
        quebra: false, arco: 150, raio: 62, arco_forte: 230, raio_forte: 74, tom: 1,
        forte: "arco", furia: "GIRO FURIOSO", furia_texto: "Giro largo em volta: 3 de dano em todos.",
    },
    // lento e largo: pega quem esta em volta e quebra escudo em todo golpe. Mais lento que a espada
    // (28 contra 20 frames), por isso o forte vale 3, e ele cai no chao em area
    machado: {
        nome: "MACHADO DO CARRASCO", caido: "carrasco", texto: "Lento e largo. Golpe forte: impacto no chão.",
        alcance: 36, escala: 1.35, dano: 1, empurra: 18, recarga: 28, janela: 40, combo: 3,
        alcance_forte: 40, escala_forte: 1.6, dano_forte: 3, empurra_forte: 36, recarga_forte: 46,
        quebra: true, arco: 200, raio: 70, arco_forte: 280, raio_forte: 84, tom: 0.8,
        forte: "impacto", furia: "TERREMOTO", furia_texto: "Pancada no chão: 4 de dano e empurrão enorme em volta.",
    },
    // rapidas e curtas: o combo tem 4 golpes, e o quarto e o forte, em dois cortes com avanco
    adagas: {
        nome: "ADAGAS DO BATEDOR", caido: "batedor", texto: "Rápidas e curtas. Golpe forte: dois cortes.",
        alcance: 26, escala: 0.8, dano: 1, empurra: 8, recarga: 13, janela: 26, combo: 4,
        alcance_forte: 30, escala_forte: 1, dano_forte: 2, empurra_forte: 22, recarga_forte: 28,
        quebra: false, arco: 110, raio: 50, arco_forte: 180, raio_forte: 60, tom: 1.25,
        forte: "duplo", furia: "TEMPESTADE", furia_texto: "Três cortes em volta, 1 de dano cada, e o dash recarregado.",
    },
    // alcance longo e golpe estreito: acerta de longe, mas so o que esta na frente. O forte atravessa a fila
    alabarda: {
        nome: "ALABARDA DA SENTINELA", caido: "sentinela", texto: "Alcance longo. Golpe forte: atravessa a fila.",
        alcance: 50, escala: 0.9, dano: 1, empurra: 16, recarga: 24, janela: 36, combo: 3,
        alcance_forte: 58, escala_forte: 1.1, dano_forte: 2, empurra_forte: 30, recarga_forte: 38,
        quebra: false, arco: 70, raio: 86, arco_forte: 100, raio_forte: 98, tom: 0.9,
        forte: "estocada", furia: "INVESTIDA", furia_texto: "Avanço de 240 px: 3 de dano em quem estiver no caminho.",
    },
};
global.arma = "espada";

function arma_def(_chave = global.arma) {
    return variable_struct_get(global.armas, _chave);
}

// a arma que cada Caido deixa; "" para quem nao deixa
function arma_do_caido(_caido) {
    var _chaves = variable_struct_get_names(global.armas);
    for (var _i = 0; _i < array_length(_chaves); _i++) {
        if (variable_struct_get(global.armas, _chaves[_i]).caido == _caido) {
            return _chaves[_i];
        }
    }
    return "";
}

// cor da arma: a do Caido que a deixou; a espada fica com as cores de sempre (obj_player, golpear)
function arma_cor(_chave = global.arma) {
    var _def = arma_def(_chave);
    if (_def.caido == "") {
        return make_colour_rgb(190, 210, 240);
    }
    return variable_struct_get(global.caidos, _def.caido).cor;
}

// o Caido caiu: a arma dele fica no chao, ao lado de onde ele caiu. Nao em cima: ali nasce o bau
// (obj_player, Step), e o robo mostrou a arma escondida embaixo dele. 56 px para o lado de la do
// jogador, sem parede no lugar nem no caminho; sem lugar livre, fica onde ele caiu
function arma_largar(_caido, _x, _y) {
    var _chave = arma_do_caido(_caido);
    if (_chave == "") {
        return;
    }
    var _ax = _x;
    var _ay = _y;
    var _dir = instance_exists(obj_player) ? point_direction(obj_player.x, obj_player.y, _x, _y) : 0;
    var _desvios = [0, 45, -45, 90, -90, 135, -135, 180];
    for (var _i = 0; _i < array_length(_desvios); _i++) {
        var _cx = _x + lengthdir_x(56, _dir + _desvios[_i]);
        var _cy = _y + lengthdir_y(56, _dir + _desvios[_i]);
        if (collision_circle(_cx, _cy, 20, obj_wall, false, true) == noone
            && collision_line(_x, _y, _cx, _cy, obj_wall, false, true) == noone) {
            _ax = _cx;
            _ay = _cy;
            break;
        }
    }
    with (instance_create_layer(_ax, _ay, "Instances", obj_arma_chao)) {
        arma = _chave;
    }
}

// troca a arma da mao pela do chao: a que sai fica no lugar dela
function arma_trocar(_chao) {
    var _antiga = global.arma;
    global.arma = _chao.arma;
    _chao.arma = _antiga;
    _chao.espera = true;
    sfx(snd_confirm, 1, false, 1, 0, arma_def().tom);
}

// icone da arma, desenhado com linhas (nao ha sprite de arma): no chao, no HUD e na escolha.
// _t: meio tamanho, em px
function arma_icone(_chave, _x, _y, _t, _cor) {
    var _w = max(1, _t / 6);
    // contorno escuro por baixo, para a arma ler em cima de qualquer chao
    for (var _passo = 0; _passo < 2; _passo++) {
        var _c = (_passo == 0) ? c_black : _cor;
        var _g = (_passo == 0) ? _w + 2 : _w;
        draw_set_color(_c);
        switch (_chave) {
            case "machado":
                // cabo na diagonal e a lamina em meia-lua no alto
                draw_line_width(_x - _t * 0.8, _y + _t * 0.9, _x + _t * 0.5, _y - _t * 0.6, _g);
                draw_triangle(_x + _t * 0.1, _y - _t * 0.9, _x + _t * 0.95, _y - _t * 0.05, _x + _t * 0.15, _y - _t * 0.1, false);
                break;
            case "adagas":
                // duas laminas curtas cruzadas
                draw_line_width(_x - _t * 0.7, _y + _t * 0.7, _x + _t * 0.6, _y - _t * 0.6, _g);
                draw_line_width(_x + _t * 0.7, _y + _t * 0.7, _x - _t * 0.6, _y - _t * 0.6, _g);
                draw_line_width(_x - _t * 0.75, _y + _t * 0.35, _x - _t * 0.35, _y + _t * 0.75, _g);
                draw_line_width(_x + _t * 0.75, _y + _t * 0.35, _x + _t * 0.35, _y + _t * 0.75, _g);
                break;
            case "alabarda":
                // haste comprida, ponta e lamina pequena perto da ponta
                draw_line_width(_x, _y + _t, _x, _y - _t * 0.6, _g);
                draw_triangle(_x - _t * 0.18, _y - _t * 0.6, _x + _t * 0.18, _y - _t * 0.6, _x, _y - _t * 1.1, false);
                draw_triangle(_x, _y - _t * 0.55, _x + _t * 0.6, _y - _t * 0.75, _x + _t * 0.55, _y - _t * 0.2, false);
                break;
            default:
                // espada: lamina na diagonal e a guarda atravessada
                draw_line_width(_x - _t * 0.55, _y + _t * 0.55, _x + _t * 0.8, _y - _t * 0.8, _g);
                draw_line_width(_x - _t * 0.6, _y + _t * 0.1, _x - _t * 0.1, _y + _t * 0.6, _g);
                draw_line_width(_x - _t * 0.55, _y + _t * 0.55, _x - _t * 0.85, _y + _t * 0.85, _g);
                break;
        }
    }
    draw_set_color(c_white);
}
