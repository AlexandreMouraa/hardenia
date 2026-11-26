lifetime = 8;
damage = 1;
knockback = 12;
forte = false; // terceiro golpe do combo (obj_player, golpear)
especial = false; // giro: acerta todos em volta de uma vez (obj_player, girar)
quebra_escudo = false; // golpe carregado, especial e estocada quebram o escudo da elite
atraso = 0; // quadros parado antes de valer: o segundo corte das adagas (scr_armas, "duplo")
// setor: o golpe comum e o forte acertam no arco desenhado (centro no guerreiro, raio, abertura e
// direcao, setor_toca_retangulo), e nao mais num quadrado invisivel na frente dele. A turma sentia
// golpe que nao pegava quem estava dentro do corte (issue #108). A estocada e o giro seguem no quadrado
setor = false;
ox = 0;
oy = 0;
raio = 0;
abertura = 0;
dir = 0;
visible = false;

// tira vida de um inimigo, com efeito e empurrao (scr_inimigos)
acertar = function(_enemy) {
    golpe_acertar(_enemy, damage, knockback, forte, quebra_escudo);
};
