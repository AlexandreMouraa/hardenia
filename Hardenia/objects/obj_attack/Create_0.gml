lifetime = 8;
damage = 1;
knockback = 12;
forte = false; // terceiro golpe do combo (obj_player, golpear)
especial = false; // giro: acerta todos em volta de uma vez (obj_player, girar)
quebra_escudo = false; // golpe carregado, especial e estocada quebram o escudo da elite
atraso = 0; // quadros parado antes de valer: o segundo corte das adagas (scr_armas, "duplo")
visible = false;

// tira vida de um inimigo, com efeito e empurrao (scr_inimigos)
acertar = function(_enemy) {
    golpe_acertar(_enemy, damage, knockback, forte, quebra_escudo);
};
