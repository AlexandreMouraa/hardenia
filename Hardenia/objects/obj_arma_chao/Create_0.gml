// A arma que um Caido largou (scr_armas). Chegando perto, com a sala limpa, abre a escolha
// (obj_arma_escolha). Recusou ou trocou: so abre de novo depois de se afastar, para nao prender o
// jogador em cima dela
arma = "espada";
espera = false;
// cai do alto antes de poder pegar: a morte do Caido ainda esta na tela (0,75 s)
pousar = 45;
pousar_max = pousar;
// contador do brilho e da flutuacao; sem random (o robo depende da sequencia aleatoria do jogo)
tempo = 0;
// entre o chao e os personagens, como as marcas (60) e a luz do ambiente (75)
depth = 55;
