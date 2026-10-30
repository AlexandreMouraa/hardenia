if (global.game_paused) {
    if (keyboard_check_pressed(ord("M"))) {
        global.game_paused = false;
        room_goto(Room_Menu);
    }
    exit;
}

// mapa da proxima fase aberto (obj_mapa): parado, e o tempo nao conta
if (instance_exists(obj_mapa)) {
    exit;
}

// tempo da run: morte e reinicio contam, pausa nao
if (!venceu) {
    global.run_frames += 1;
}

// clique: ataque mirando no mouse (o J, em KeyPress_74, mira para onde anda).
// Lido antes da micro-pausa, como o dash: clicar durante ela fica guardado
var _clique = instance_exists(obj_autotest) ? obj_autotest.bot_clique : mouse_check_button_pressed(mb_left);
if (_clique && !is_dead && !venceu) {
    global.mira_mouse = true;
    ataque_buffer = ataque_buffer_max;
    carga_armada = true;
}

// golpe especial (girar, no Create). Pausa e mapa ja sairam la em cima
var _especial = instance_exists(obj_autotest) ? obj_autotest.bot_especial : (mouse_check_button_pressed(mb_right) || keyboard_check_pressed(ord("K")));
if (_especial && !is_dead && !venceu) {
    if (especial_recarga > 0) {
        especial_negado = 14;
    } else {
        especial_buffer = ataque_buffer_max;
    }
}

// dash apertado fica guardado alguns frames (dash_buffer). Lido antes da
// micro-pausa: apertar durante ela tambem vale
var _dash_apertado = instance_exists(obj_autotest) ? obj_autotest.bot_dash : keyboard_check_pressed(vk_space);
if (_dash_apertado) {
    dash_buffer = dash_buffer_max;
}

// micro-pausa do impacto: o mundo congela uns frames (inimigos e golpes param
// junto, ver scr_efeitos)
if (global.hitstop > 0) {
    global.hitstop -= 1;
    exit;
}

if (is_dead) {
    death_timer -= 1;
    if (death_timer <= 0) {
        global.tentativas += 1;
        room_restart();
    }
    exit;
}

// ultima sala limpa = fim da run
if (!venceu && room == room_last && instance_number(obj_enemy) == 0) {
    venceu = true;
    cancelar_carga();
    brilho = 0;
    sprite_index = spr_player_idle;
    image_index = facing_dir * idle_frames;
    image_alpha = 1;
    window_set_cursor(cr_default);
    if (rede_ativa()) {
        vitoria_estado = "nome";
        keyboard_string = "";
    }
}

// sala limpa: quantas tentativas cada sala custou (estatisticas do site)
if (!sala_limpa_enviada && instance_number(obj_enemy) == 0) {
    sala_limpa_enviada = true;
    rede_evento("sala", { tentativa: global.tentativas, tempo_ms: frames_para_ms(tempo_na_sala) });
}

var _h = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
var _v = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));
var _enter_apertado = keyboard_check_pressed(vk_enter);

// no modo -autotest quem "aperta" e o robo (obj_autotest), pelas mesmas variaveis
if (instance_exists(obj_autotest)) {
    _h = obj_autotest.bot_h;
    _v = obj_autotest.bot_v;
    _enter_apertado = obj_autotest.bot_enter;
}

if (venceu) {
    if (vitoria_estado == "nome") {
        vitoria_nome = nome_filtrado(keyboard_string);
        keyboard_string = vitoria_nome;
        if (_enter_apertado) {
            var _nome = string_trim(vitoria_nome);
            if (_nome == "") {
                // sem nome: pula o ranking
                room_goto(Room_Menu);
            } else {
                req_vitoria = rede_post("/api/vitoria", {
                    nome: _nome,
                    tentativas: global.tentativas,
                    tempo_ms: frames_para_ms(global.run_frames),
                });
                vitoria_estado = "enviando";
                vitoria_espera = 0;
            }
        }
    } else if (vitoria_estado == "enviando") {
        // a resposta chega no Async HTTP; sem resposta em 10 s, desiste
        vitoria_espera += 1;
        if (vitoria_espera > game_get_speed(gamespeed_fps) * 10) {
            vitoria_estado = "falhou";
        }
    } else if (_enter_apertado) {
        room_goto(Room_Menu);
    }
    exit;
}

if (!is_dashing) {
    if (_h != 0 || _v != 0) {
        face_h = _h;
        face_v = _v;
    }
    // durante o golpe o boneco continua virado para o lado do golpe (golpear)
    if (!is_attacking) {
        if (_h != 0) {
            facing_dir = (_h < 0) ? 0 : 1;
        } else if (_v != 0) {
            facing_dir = (_v < 0) ? 2 : 3;
        }
    }
}

if (dash_charges < dash_charges_max) {
    if (dash_cooldown > 0) {
        dash_cooldown -= 1;
    }
    if (dash_cooldown <= 0) {
        dash_charges += 1;
        dash_cooldown = (dash_charges < dash_charges_max) ? dash_cooldown_max : 0;
        // carga de volta: brilho rapido no personagem e na barrinha
        hud_recarga[dash_charges - 1] = 12;
        brilho = max(brilho, 0.45);
    }
}
for (var _i = 0; _i < dash_charges_max; _i++) {
    hud_recarga[_i] = max(0, hud_recarga[_i] - 1);
}
dash_negado = max(0, dash_negado - 1);
dash_freio = max(0, dash_freio - 1);
brilho = max(0, brilho - 0.12);

if (attack_cooldown > 0) {
    attack_cooldown -= 1;
}
if (combo_janela > 0) {
    combo_janela -= 1;
    if (combo_janela <= 0) {
        combo_passo = 0;
    }
}
if (ataque_buffer > 0 && attack_cooldown <= 0) {
    ataque_buffer = 0;
    if (is_dashing || dash_freio > 0) {
        estocar();
    } else {
        golpear();
    }
}
ataque_buffer = max(0, ataque_buffer - 1);

// golpe carregado (ver Create). So enche depois da animacao do golpe normal, para
// um toque um pouco mais longo nao deixar o jogador lento
if (carga_armada) {
    if (!ataque_segurado()) {
        var _cheia = (carga >= carga_max);
        cancelar_carga();
        if (_cheia) {
            golpear(true);
        }
    } else if (is_dashing) {
        // o dash cancela; para carregar de novo, solta e aperta
        cancelar_carga();
    } else if (!is_attacking && carga < carga_max) {
        carga += 1;
    }
}
// brilho enchendo com a carga; cheia, pisca (contador, sem random)
if (carga >= carga_max) {
    brilho = ((tempo_na_sala div 5) mod 2 == 0) ? 0.9 : 0.25;
} else if (carga > 0) {
    brilho = max(brilho, 0.45 * carga / carga_max);
}

if (especial_recarga > 0) {
    especial_recarga -= 1;
    if (especial_recarga <= 0) {
        especial_pronto = 12;
    }
}
especial_negado = max(0, especial_negado - 1);
especial_pronto = max(0, especial_pronto - 1);
if (especial_buffer > 0 && !is_dashing) {
    especial_buffer = 0;
    girar();
}
especial_buffer = max(0, especial_buffer - 1);

tempo_na_sala += 1;

if (_dash_apertado && dash_charges == 0 && !is_dashing) {
    dash_negado = 14;
}
if (dash_buffer > 0 && !is_dashing && dash_charges > 0) {
    dash_buffer = 0;
    is_dashing = true;
    dash_timer = dash_duration;
    dash_charges -= 1;
    if (dash_cooldown <= 0) {
        dash_cooldown = dash_cooldown_max;
    }
    // diagonal com o mesmo alcance da reta (sem isso o dash diagonal vai 41% mais longe)
    var _norm_dash = (face_h != 0 && face_v != 0) ? 0.7071 : 1;
    dash_dir_x = face_h * _norm_dash;
    dash_dir_y = face_v * _norm_dash;
    dash_contador += 1;
    audio_play_sound(snd_dash, 1, false, 1, 0, 1 + 0.05 * sin(dash_contador * 2.4));
    brilho = 1;
    fx_dash_arrancada(x, y, point_direction(0, 0, dash_dir_x, dash_dir_y));
}
dash_buffer = max(0, dash_buffer - 1);

var _move_x = 0;
var _move_y = 0;

if (is_dashing) {
    var _vel = dash_perfil[dash_duration - dash_timer];
    _move_x = dash_dir_x * _vel;
    _move_y = dash_dir_y * _vel;
} else {
    var _norm = (_h != 0 && _v != 0) ? 0.7071 : 1;
    var _passo = move_speed;
    if (carga > 0) {
        _passo *= carga_lentidao;
    } else if (is_attacking) {
        _passo *= golpe_lentidao;
    }
    _move_x = _h * _passo * _norm;
    _move_y = _v * _passo * _norm;
}
// terceiro golpe do combo: passo curto para a frente, que da peso ao golpe
if (ataque_impulso > 0 && !is_dashing) {
    ataque_impulso -= 1;
    if (global.mira_mouse) {
        // para o lado do golpe; resto de arredondamento vira 0 (lengthdir_x
        // de 270 graus da -0,0000000000000005, que desligaria o escorregao
        // nas quinas em mover_eixo)
        var _ix = lengthdir_x(2.5, ataque_dir);
        var _iy = lengthdir_y(2.5, ataque_dir);
        _move_x += (abs(_ix) < 0.001) ? 0 : _ix;
        _move_y += (abs(_iy) < 0.001) ? 0 : _iy;
    } else {
        var _norm_golpe = (face_h != 0 && face_v != 0) ? 0.7071 : 1;
        _move_x += face_h * 2.5 * _norm_golpe;
        _move_y += face_v * 2.5 * _norm_golpe;
    }
}

var _de_x = x;
var _de_y = y;
mover_eixo(_move_x, true, _move_y == 0);
mover_eixo(_move_y, false, _move_x == 0);

if (is_dashing) {
    // rastro do dash: uma copia brilhante por frame, do branco ao vermelho,
    // mais riscos de velocidade; mostram a invencibilidade
    var _t = dash_timer / dash_duration;
    with (instance_create_depth(_de_x, _de_y, depth + 1, obj_fx)) {
        tipo = "rastro";
        sprite_index = other.sprite_index;
        image_index = other.image_index;
        cor = merge_colour(make_colour_rgb(200, 30, 40), make_colour_rgb(255, 190, 170), _t);
        vida_max = 12;
        vida = vida_max;
    }
    fx_risco(_de_x, _de_y, x, y, make_colour_rgb(255, 120, 110));
    dash_timer -= 1;
    if (dash_timer <= 0) {
        is_dashing = false;
        dash_freio = dash_freio_max;
    }
}

if (is_attacking) {
    attack_anim_timer -= 1;
    if (attack_anim_timer <= 0) {
        is_attacking = false;
    }
}

if (is_attacking) {
    sprite_index = spr_player_slash;
    var _progress = 1 - (attack_anim_timer / attack_anim_duration);
    anim_frame = floor(_progress * slash_frames);
    if (anim_frame >= slash_frames) {
        anim_frame = slash_frames - 1;
    }
    // segundo golpe do combo: a mesma animacao de tras para frente
    if (golpe_atual == 2) {
        anim_frame = slash_frames - 1 - anim_frame;
    }
    image_index = facing_dir * slash_frames + anim_frame;
} else if (is_dashing) {
    sprite_index = spr_player_walk;
    image_index = facing_dir * walk_frames + 1;
} else if (_h != 0 || _v != 0) {
    sprite_index = spr_player_walk;
    anim_timer += 1;
    if (anim_timer >= anim_speed) {
        anim_timer = 0;
        anim_frame = (anim_frame + 1) mod walk_frames;
    }
    image_index = facing_dir * walk_frames + anim_frame;
} else {
    sprite_index = spr_player_idle;
    anim_timer += 1;
    if (anim_timer >= anim_speed) {
        anim_timer = 0;
        anim_frame = (anim_frame + 1) mod idle_frames;
    }
    image_index = facing_dir * idle_frames + anim_frame;
}

if (invuln_timer > 0) {
    invuln_timer -= 1;
    image_alpha = (invuln_timer div 4) % 2 == 0 ? 0.3 : 1;
} else {
    image_alpha = 1;
}

if (hp <= 0) {
    // onde e quando morreu: alimenta o mapa de mortes do site
    rede_evento("morte", { x: round(x), y: round(y), tentativa: global.tentativas, tempo_ms: frames_para_ms(tempo_na_sala) });
    is_dead = true;
    cancelar_carga();
    brilho = 0;
    impacto(8, 9);
    death_timer = death_timer_max;
    image_alpha = 1;
    image_blend = c_red;
}