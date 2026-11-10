event_inherited();
// Suporte fragil: usa a silhueta do conjurador, cor e insignia de cura proprias.
walk_sprite = spr_conjurador_andar;
walk_frames = 8;
anim_speed = 6;
sprite_index = walk_sprite;
mask_index = spr_enemy_walk_skeleton;
hp = 3; // cinco no Patio, depois do ajuste de dificuldade da terceira fase
move_speed = 1.15;
zona_visivel = false;
som_golpe = noone;
// Estado de cura separado de state=1: o robo nao foge de uma falsa zona de dano.
cura_conjurando = false;
cura_alvo = noone;
cura_raio = 320;
cura_quantidade = 2; // recupera um golpe forte, com conjuracao interrompivel
cura_aviso = 72; // 1,2 s para identificar a ligacao e interromper
cura_tempo = 0;
cura_recarga_max = 240; // quatro segundos entre curas, alem do aviso
cura_recarga = 90; // entrada com folga para ler os inimigos antes da primeira conjuracao
cura_interrompida = 0;
cura_pulso = 0;
suporte_passo = curandeiro_passo;
ao_sofrer_golpe = function() { cura_interromper(id); };
