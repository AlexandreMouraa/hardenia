// O clima de cada sala: escuridao com luz, neve, cinza e fagulhas. Tudo so no desenho e sem sorteio:
// nao muda a run do robo. A escuridao cobre so o chao (obj_ambiente fica entre o chao e os
// personagens): inimigo e zona de golpe continuam claros, e o combate continua justo.
//   escuro: de 0 a 1, longe de qualquer luz
//   cor:    cor da escuridao
//   raio:   luz em volta do jogador, em pixels da sala
//   clima:  "cinza", "neve", "brasa", "poeira" ou ""
//   vinheta: quanto as bordas da tela escurecem
//   luzes:  fogueiras da arte, [x, y] na sala. Saem de onde a arte tem chama
//   fundo:  som de fundo; chao: som do passo (scr_som)
global.ambiente_salas = [
    { sala: Room1, escuro: 0.38, cor: make_colour_rgb(20, 10, 10), raio: 300, clima: "cinza", vinheta: 0.5, fundo: snd_amb_noite, chao: "pedra",
      luzes: [[500, 156], [1429, 467], [632, 925], [826, 923], [116, 348]] },
    { sala: Room_Tunel, escuro: 0.55, cor: c_black, raio: 280, clima: "poeira", vinheta: 0.7, fundo: snd_amb_gotas, chao: "pedra",
      luzes: [[1519, 146], [1819, 146], [309, 166], [629, 166], [849, 506], [1169, 506], [1449, 1006], [1829, 1006], [109, 1016], [369, 1016]] },
    { sala: Room2, escuro: 0.25, cor: make_colour_rgb(10, 14, 30), raio: 320, clima: "poeira", vinheta: 0.5, fundo: snd_amb_noite, chao: "terra",
      luzes: [] },
    { sala: Room3, escuro: 0.35, cor: make_colour_rgb(12, 18, 38), raio: 340, clima: "neve", vinheta: 0.45, fundo: snd_amb_vento, chao: "neve",
      luzes: [[841, 946], [840, 158], [694, 160], [280, 174], [224, 529], [1351, 263], [693, 947], [1249, 222]] },
    { sala: Room_Trono, escuro: 0.5, cor: make_colour_rgb(18, 6, 6), raio: 300, clima: "brasa", vinheta: 0.65, fundo: snd_amb_fogo, chao: "pedra",
      luzes: [[249, 276], [599, 276], [935, 276], [1285, 276], [249, 806], [1285, 806]] },
];
// false: sem escuridao, clima e vinheta, para aparelho fraco
global.op_ambiente = true;

function ambiente_da_sala() {
    for (var _i = 0; _i < array_length(global.ambiente_salas); _i++) {
        if (global.ambiente_salas[_i].sala == room) {
            return global.ambiente_salas[_i];
        }
    }
    return undefined;
}

// quantas particulas e como cada uma anda, em pixels por frame
function clima_def(_clima) {
    switch (_clima) {
        case "cinza": return { n: 50, vx: 0.25, vy: 0.35, balanco: 16, cor: make_colour_rgb(150, 140, 130), alfa: 0.5, soma: false, tam: 1.6 };
        case "neve": return { n: 110, vx: -0.45, vy: 1, balanco: 14, cor: c_white, alfa: 0.65, soma: false, tam: 2 };
        case "brasa": return { n: 50, vx: 0.15, vy: -0.7, balanco: 22, cor: make_colour_rgb(255, 130, 50), alfa: 0.75, soma: true, tam: 1.6 };
        case "poeira": return { n: 34, vx: 0.08, vy: -0.05, balanco: 26, cor: make_colour_rgb(190, 170, 140), alfa: 0.22, soma: false, tam: 1.2 };
    }
    return undefined;
}
