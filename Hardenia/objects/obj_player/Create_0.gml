move_speed = 3;

dash_speed = 7.8;
dash_duration = 10;
dash_cooldown_max = 30;
dash_timer = 0;
dash_cooldown = 0;
is_dashing = false;

dash_charges_max = 2;
dash_charges = dash_charges_max;

// velocidade de cada frame do dash: arranca forte e freia ate o passo normal,
// em vez de velocidade fixa e parada seca. Mesmo alcance (78 px) e mesma
// invencibilidade (10 frames) do dash antigo
dash_perfil = [];
var _soma = 0;
for (var _i = 0; _i < dash_duration; _i++) {
    var _p = _i / (dash_duration - 1);
    dash_perfil[_i] = 1 - 0.65 * _p * _p;
    _soma += dash_perfil[_i];
}
for (var _i = 0; _i < dash_duration; _i++) {
    dash_perfil[_i] *= dash_speed * dash_duration / _soma;
}
// direcao travada no inicio: o dash vai reto mesmo se soltar ou trocar a tecla
dash_dir_x = 0;
dash_dir_y = 1;
// aperto antecipado: apertar ate 8 frames antes de poder (fim do dash anterior,
// micro-pausa de um golpe, carga quase de volta) ainda vale
dash_buffer = 0;
dash_buffer_max = 8;
dash_contador = 0; // varia o tom do som sem usar random (o robo depende do RNG)
// efeitos: estica no dash, achata ao frear, brilho branco ao arrancar
dash_freio = 0;
dash_freio_max = 6;
brilho = 0;
// HUD: barrinha que treme sem carga e pisca quando a carga volta
dash_negado = 0;
hud_recarga = array_create(dash_charges_max, 0);

face_h = 0;
face_v = 1;

hp = 1;
hp_max = 1;
invuln_timer = 0;

attack_cooldown = 0;

// combo de 3 golpes: J de novo logo depois de um golpe emenda o proximo. O
// terceiro e mais largo, vale 2 e empurra o inimigo para longe, mas demora
// mais para atacar de novo (risco e recompensa)
combo_passo = 0;        // golpes ja dados nesta sequencia
combo_janela = 0;       // frames que ainda da para emendar
golpe_atual = 1;        // 1, 2 ou 3: escolhe animacao e efeito
ataque_buffer = 0;
ataque_buffer_max = 12;
ataque_impulso = 0;     // passo curto para a frente no terceiro golpe
ataque_dir = 270;       // angulo do ultimo golpe

// mira: atacando com o clique, o golpe vai para onde o mouse aponta, em
// qualquer angulo; com J, para onde o jogador esta virado. Vale o ultimo dos
// dois que o jogador usou (global: passa de uma sala para a outra)
if (!variable_global_exists("mira_mouse")) {
    global.mira_mouse = false;
}
// ponto da mira na sala; no modo -autotest -mouse, o alvo que o robo escolheu
mira_alvo = function() {
    if (instance_exists(obj_autotest)) {
        return [obj_autotest.bot_mira_x, obj_autotest.bot_mira_y];
    }
    return [mouse_x, mouse_y];
};
// a mira aparece com mouse de verdade, ou no robo so com -mouse
mostra_mira = function() {
    return !instance_exists(obj_autotest) || obj_autotest.usar_mouse;
};
// cursor do sistema escondido no jogo: quem mostra o mouse e a mira (Draw GUI)
window_set_cursor(cr_none);

golpear = function() {
    combo_passo += 1;
    golpe_atual = combo_passo;
    var _forte = (combo_passo == 3);
    var _alcance = _forte ? 36 : 32;
    var _dir = point_direction(0, 0, face_h, face_v);
    if (global.mira_mouse) {
        var _m = mira_alvo();
        _dir = point_direction(x, y, _m[0], _m[1]);
        // o dash parado tambem sai para o lado do golpe
        face_h = round(lengthdir_x(1, _dir));
        face_v = round(lengthdir_y(1, _dir));
    }
    ataque_dir = _dir;
    // o boneco vira para o lado (dos 4 do sprite) mais perto do golpe; nas
    // diagonais exatas, para o lado, como era no teclado
    if (_dir <= 45 || _dir >= 315) {
        facing_dir = 1;
    } else if (_dir >= 135 && _dir <= 225) {
        facing_dir = 0;
    } else {
        facing_dir = (_dir < 180) ? 2 : 3;
    }
    // teclado: 32 em cada eixo da direcao (45 nas diagonais). Mouse: mesmo
    // alcance em qualquer angulo. A conta do mouse daria o mesmo no teclado,
    // mas com resto de arredondamento (32,000000000000004), e o robo mostrou
    // que isso muda a run; no teclado fica a conta exata
    var _gx = x + face_h * _alcance;
    var _gy = y + face_v * _alcance;
    if (global.mira_mouse) {
        var _cx = lengthdir_x(1, _dir);
        var _cy = lengthdir_y(1, _dir);
        var _k = _alcance / max(abs(_cx), abs(_cy));
        _gx = x + _cx * _k;
        _gy = y + _cy * _k;
    }
    var _golpe = instance_create_layer(_gx, _gy, "Instances", obj_attack);
    if (_forte) {
        _golpe.forte = true;
        _golpe.damage = 2;
        _golpe.knockback = 28;
        _golpe.image_xscale = 1.25;
        _golpe.image_yscale = 1.25;
    }
    // arco de corte desenhado (o golpe em si, obj_attack, e invisivel). O
    // segundo varre ao contrario; o terceiro e mais largo e mais claro
    with (instance_create_depth(x, y, depth - 1, obj_fx)) {
        tipo = "arco";
        dir = _dir;
        if (_forte) {
            abertura = 220;
            raio = 44;
            espessura = 14;
            cor = make_colour_rgb(255, 150, 40);
            intensidade = 1.6;
            vida_max = 12;
        } else {
            sentido = (other.combo_passo == 2) ? -1 : 1;
            cor = (other.combo_passo == 2) ? make_colour_rgb(255, 110, 80) : make_colour_rgb(255, 70, 70);
            vida_max = 9;
        }
        vida = vida_max;
    }
    if (_forte) {
        combo_passo = 0;
        combo_janela = 0;
        attack_cooldown = 36;
        attack_anim_duration = 14;
        ataque_impulso = 4;
    } else {
        // mesma recarga do ataque antigo (20 frames): um inimigo comum morre
        // no mesmo tempo de antes; mais 14 frames para emendar o proximo
        combo_janela = 34;
        attack_cooldown = 20;
        attack_anim_duration = 12;
    }
    is_attacking = true;
    attack_anim_timer = attack_anim_duration;
    audio_play_sound(snd_attack, 1, false, 1, 0, _forte ? 0.85 : (golpe_atual == 2 ? 1.08 : 1));
};

is_dead = false;
death_timer = 0;
death_timer_max = 90;

venceu = false;

// escurecido que some ao entrar na sala (troca de sala e reinicio apos morrer)
fade = 1;

// frames jogados nesta sala (para a dica do objetivo na primeira sala)
tempo_na_sala = 0;

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

// rede: evento de sala limpa (uma vez por sala) e tela de vitoria com ranking.
// vitoria_estado: "fim" (sem rede) ou "nome" -> "enviando" -> "enviado" / "falhou"
sala_limpa_enviada = false;
vitoria_estado = "fim";
vitoria_nome = "";
vitoria_espera = 0;
vitoria_posicao = 0;
vitoria_total = 0;
vitoria_ranking = [];
req_vitoria = -1;
req_ranking = -1;

// anda _d px num eixo, de 1 em 1 px perto da parede: encosta nela em vez de
// parar antes. Em movimento reto, batendo de raspao numa quina (ate 6 px),
// escorrega para o lado livre em vez de travar
mover_eixo = function(_d, _no_x, _reto) {
    var _s = sign(_d);
    var _resto = abs(_d);
    while (_resto > 0) {
        var _p = min(1, _resto);
        var _mx = _no_x ? _s * _p : 0;
        var _my = _no_x ? 0 : _s * _p;
        if (!place_meeting(x + _mx, y + _my, obj_wall)) {
            x += _mx;
            y += _my;
            _resto -= _p;
            continue;
        }
        if (!_reto) {
            break;
        }
        var _lado = 0;
        for (var _k = 1; _k <= 6 && _lado == 0; _k++) {
            if (_no_x) {
                if (!place_meeting(x + _mx, y - _k, obj_wall)) _lado = -1;
                else if (!place_meeting(x + _mx, y + _k, obj_wall)) _lado = 1;
            } else {
                if (!place_meeting(x - _k, y + _my, obj_wall)) _lado = -1;
                else if (!place_meeting(x + _k, y + _my, obj_wall)) _lado = 1;
            }
        }
        var _lx = _no_x ? 0 : _lado;
        var _ly = _no_x ? _lado : 0;
        if (_lado == 0 || place_meeting(x + _lx, y + _ly, obj_wall)) {
            break;
        }
        x += _lx;
        y += _ly;
        _resto -= 1;
    }
};

// camera em codigo: centrada no jogador e presa nas bordas, com o tremor dos
// impactos. Segue com um leve atraso, que suaviza o dash; atualiza no End Step
tremor_fase = 0;
cam_x = 0;
cam_y = 0;
posicionar_camera = function(_na_hora) {
    var _cam = view_camera[0];
    var _cw = camera_get_view_width(_cam);
    var _ch = camera_get_view_height(_cam);
    var _ax = clamp(x - _cw / 2, 0, room_width - _cw);
    var _ay = clamp(y - _ch / 2, 0, room_height - _ch);
    if (_na_hora) {
        cam_x = _ax;
        cam_y = _ay;
    } else {
        cam_x = lerp(cam_x, _ax, 0.2);
        cam_y = lerp(cam_y, _ay, 0.2);
    }
    var _cx = cam_x;
    var _cy = cam_y;
    if (global.tremor > 0) {
        tremor_fase += 1;
        _cx += sin(tremor_fase * 1.7) * global.tremor;
        _cy += cos(tremor_fase * 2.3) * global.tremor;
        global.tremor = (global.tremor < 0.5) ? 0 : global.tremor * 0.82;
    }
    camera_set_view_pos(_cam, round(clamp(_cx, 0, room_width - _cw)), round(clamp(_cy, 0, room_height - _ch)));
};
camera_set_view_target(view_camera[0], noone);
global.hitstop = 0;
global.tremor = 0;
posicionar_camera(true);

global.game_paused = false;