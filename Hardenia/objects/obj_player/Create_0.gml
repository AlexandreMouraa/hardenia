move_speed = 3;

dash_speed = 7.8;
dash_duration = 10;
dash_cooldown_max = 30;
dash_timer = 0;
dash_cooldown = 0;
is_dashing = false;

dash_charges_max = 2;
dash_charges = dash_charges_max;

face_h = 0;
face_v = 1;

hp = 1;
hp_max = 1;
invuln_timer = 0;

attack_cooldown = 0;
attack_cooldown_max = 20;

is_dead = false;
death_timer = 0;
death_timer_max = 90;

venceu = false;

// escurecido que some ao entrar na sala (troca de sala e reinicio apos morrer)
fade = 1;

// se a sala for aberta direto pela IDE, sem passar pelo menu
if (!variable_global_exists("tentativas")) {
    global.tentativas = 1;
}

facing_dir = 3; // 0 = esquerda, 1 = direita, 2 = cima, 3 = baixo

idle_frames = 4;
walk_frames = 4;
slash_frames = 6;

anim_timer = 0;
anim_speed = 6;
anim_frame = 0;

is_attacking = false;
attack_anim_timer = 0;
attack_anim_duration = 12;

sprite_index = spr_player_idle;
// mascara fixa: sem ela a colisao muda de tamanho a cada animacao e prende na parede
mask_index = spr_player_idle;
image_speed = 0;
image_index = facing_dir * idle_frames;

global.game_paused = false;