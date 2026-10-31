event_inherited();
// inimigo de horda (#25): fraco, em grande numero, sem aviso nem golpe. Machuca ao
// encostar: dezenas de zonas vermelhas virariam ruido. Decisao inicial da issue, para
// rever se ficar injusto jogando. Ate haver arte, e um esqueleto menor e azulado
sprite_index = walk_sprite;
hp = 1;
move_speed = 1.8;
image_xscale = 0.7;
image_yscale = 0.7;
image_blend = make_colour_rgb(150, 190, 255);
leve = true;
// o golpe nao acorda ninguem: a horda ja vem de uma vez
acordar = function() {};
// separacao a cada 6 frames, cada um no seu: testar todos contra todos em todo frame
// pesaria com centenas
separar_timer = 1 + instance_number(obj_enemy_horda) mod 6;
// sem parede no meio vai reto: o mapa de direcoes (campo_rumo) so anda de celula em celula
reto = true;
