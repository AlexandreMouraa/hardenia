// Tela de transicao entre fases (criada por ir_para_sala, em scr_mapa): o
// guerreiro anda no mapa ate a proxima fase e o jogo troca de sala. Enquanto
// ela esta aberta o jogador nao se mexe e o tempo da run nao conta
destino = Room1;
de = -1;
para = 0;
tempo = 0;
duracao = 150;      // 2,5 s; Enter, espaco, J ou clique pulam depois de pode_pular
pode_pular = 25;
saindo = false;
// golpe de inimigo que ainda estava no ar nao acerta durante a transicao
instance_destroy(obj_enemy_attack);
instance_destroy(obj_flecha);
instance_destroy(obj_explosao);
