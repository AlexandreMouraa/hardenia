// a sala com mascara de colisao cria as paredes aqui (scr_mapa)
paredes_da_mascara();
if (room == Room2) instance_create_depth(0, 0, 90, obj_patio);
// profundidade entre o chao (100) e os personagens (0), como a poeira do dash
instance_create_depth(0, 0, 60, obj_marcas);
instance_create_depth(0, 0, 75, obj_ambiente);
musica(musica_da_sala());
som_fundo((ambiente_da_sala() != undefined) ? ambiente_da_sala().fundo : -1);

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

// a vida passa de uma sala para a outra (global.vida, em scr_mapa)
hp = global.vida;
hp_max = VIDA_MAX;
invuln_timer = 0;
// HUD: tela e barra reagem ao levar golpe e ao ganhar vida (frames restantes)
hud_dano = 0;
hud_dano_max = 30;
hud_cura = 0;
hud_cura_max = 40;
// golpe que pegou. A morte fica no fim do Step
// quem acertou o ultimo golpe e a frase da tela de morte (frase_de_morte, em scr_mapa)
morto_por = "";
frase_morte = "";
levar_dano = function(_dano) {
    hp -= _dano;
    global.vida = hp;
    invuln_timer = 45;
    hud_dano = hud_dano_max;
    if (hp > 0) {
        impacto(5, 7);
    }
    if (tem_tecnica("retribuicao")) {
        fx_onda(x, y, 110, global.caidos.sentinela.cor);
        tecnica_contar("retribuicao");
        golpe_em_volta(x, y, 110, 1, 30, true, false);
    }
};

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
// golpear tem custo: anda mais devagar durante a animacao do golpe. Com mouse o
// robo fazia a run sem levar golpe; 50% e a sugestao da issue #6, ajustar jogando
golpe_lentidao = 0.5;

// golpe carregado: o toque continua igual, com o golpe normal saindo ao apertar.
// Continuar segurando depois dele enche a carga; soltar com ela cheia solta um
// golpe forte. Enquanto carrega, anda devagar: esse e o risco da escolha
carga_armada = false;   // apertou o ataque e ainda nao soltou
carga = 0;              // frames carregados
carga_max = 30;         // 0,5 s, sugestao da issue #3; ajustar jogando
carga_lentidao = 0.5;   // velocidade enquanto carrega, tambem da issue #3
golpe_carregado = false; // o ultimo golpe foi carregado (o robo conta)
// tecla ou botao ainda apertado; no modo -autotest quem decide e o robo
ataque_segurado = function() {
    if (global.toque_ativo) {
        return global.toque.ataque_preso;
    }
    if (instance_exists(obj_autotest)) {
        return obj_autotest.bot_segurar;
    }
    return mouse_check_button(mb_left) || keyboard_check(ord("J")) || pad_ataque_preso();
};
// fim da carga, sem golpe: dash, morte e vitoria
cancelar_carga = function() {
    carga_armada = false;
    carga = 0;
};

// mira: o golpe vira sozinho para o inimigo mais perto, com preferencia para quem esta
// para onde o jogador anda. Clique, J e toque seguem a mesma regra; sem ninguem perto, o
// golpe vai para onde o jogador esta virado. 140 px: um pouco alem do alcance do golpe forte
mira_raio = 140;
golpe_mirado = false; // o ultimo golpe virou para um inimigo
golpe_dobrado = false; // Ultimo Instante: o proximo golpe vale o dobro
mira_alvo = function() {
    var _rumo = point_direction(0, 0, face_h, face_v);
    var _melhor = noone;
    var _nota = infinity;
    with (obj_enemy) {
        var _d = point_distance(other.x, other.y, x, y);
        if (_d < other.mira_raio) {
            // quem esta de costas para o rumo conta como ate 1,5 vez mais longe
            var _n = _d * (1 + 0.5 * abs(angle_difference(_rumo, point_direction(other.x, other.y, x, y))) / 180);
            if (_n < _nota && collision_line(other.x, other.y, x, y, obj_wall, false, true) == noone) {
                _nota = _n;
                _melhor = id;
            }
        }
    }
    return _melhor;
};
// cursor do sistema escondido no jogo: o golpe nao depende do mouse
window_set_cursor(cr_none);

// tela de vitoria: manda o nome ao ranking. Sem nome, pula o ranking
pedido_nome = -1; // resposta pendente do teclado do aparelho (Other_63)
enviar_nome = function() {
    var _nome = string_trim(vitoria_nome);
    if (_nome == "") {
        room_goto(Room_Menu);
        return;
    }
    req_vitoria = rede_post("/api/vitoria", {
        nome: _nome,
        tentativas: global.tentativas,
        tempo_ms: frames_para_ms(global.run_frames),
        desafio: global.desafio ? global.desafio_dia : "",
    });
    vitoria_estado = "enviando";
    vitoria_nome_recusado = false;
    vitoria_espera = 0;
};

golpear = function(_carregado = false) {
    // os numeros vem da arma na mao (scr_armas); a espada tem os de sempre
    var _arma = arma_def();
    combo_passo += 1;
    // o forte e o ultimo golpe do combo da arma (3 na espada, 4 nas adagas) e o carregado. Para a
    // animacao, as dicas e o robo ele e sempre o golpe 3; os comuns alternam entre 1 e 2
    var _forte = _carregado || combo_passo >= _arma.combo;
    golpe_atual = _forte ? 3 : ((combo_passo - 1) mod 2) + 1;
    golpe_carregado = _carregado;
    golpe_estocada = false;
    var _alcance = _forte ? _arma.alcance_forte : _arma.alcance;
    var _dir = point_direction(0, 0, face_h, face_v);
    var _alvo = mira_alvo();
    golpe_mirado = (_alvo != noone);
    if (golpe_mirado) {
        _dir = point_direction(x, y, _alvo.x, _alvo.y);
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
    // sem alvo: 32 em cada eixo da direcao (45 nas diagonais). Com alvo: mesmo
    // alcance em qualquer angulo. A conta com alvo daria o mesmo sem ele, mas
    // com resto de arredondamento (32,000000000000004), e o robo mostrou que
    // isso muda a run; sem alvo fica a conta exata
    var _gx = x + face_h * _alcance;
    var _gy = y + face_v * _alcance;
    if (golpe_mirado) {
        var _cx = lengthdir_x(1, _dir);
        var _cy = lengthdir_y(1, _dir);
        var _k = _alcance / max(abs(_cx), abs(_cy));
        _gx = x + _cx * _k;
        _gy = y + _cy * _k;
    }
    // ULTIMO INSTANTE (golpe_dobrado) dobra o dano deste golpe, seja qual for a forma dele
    var _dobro = 1;
    if (golpe_dobrado) {
        golpe_dobrado = false;
        _dobro = 2;
    }
    var _quebra = _carregado || _arma.quebra;
    // BOMBA DE MAO: ate onde ela vai se decide antes do golpe, porque o impacto e a estocada longa
    // acertam na hora e o alvo mirado pode ja ter morrido quando a bomba sair
    var _bomba_ate = -1;
    if (_forte && tem_tecnica("bomba_combo")) {
        // no alvo; sem alvo, a frente, sem cair dentro da parede
        _bomba_ate = linha_ate_parede(x, y, _dir, golpe_mirado ? point_distance(x, y, _alvo.x, _alvo.y) : 150);
    }
    // a forma do golpe forte vem da arma (scr_armas): a espada e as adagas usam a area de sempre
    // (obj_attack, 8 quadros na frente); o machado e a alabarda acertam de uma vez, em area ou em linha
    var _tipo = _forte ? _arma.forte : "arco";
    if (_tipo == "arco" || _tipo == "duplo") {
        var _golpe = instance_create_layer(_gx, _gy, "Instances", obj_attack);
        _golpe.quebra_escudo = _quebra;
        if (!_forte) {
            _golpe.damage = _arma.dano * _dobro;
            _golpe.knockback = _arma.empurra;
            _golpe.image_xscale = _arma.escala;
            _golpe.image_yscale = _arma.escala;
        } else {
            _golpe.forte = true;
            // adagas: o primeiro dos dois cortes tira 1 e empurra pouco; o forte e o segundo
            _golpe.damage = (_tipo == "duplo" ? 1 : _arma.dano_forte) * _dobro;
            _golpe.knockback = (_tipo == "duplo") ? _arma.empurra : _arma.empurra_forte;
            _golpe.image_xscale = _arma.escala_forte;
            _golpe.image_yscale = _arma.escala_forte;
        }
    }
    if (_tipo == "duplo") {
        // segundo corte: 6 quadros depois e 14 px mais a frente, aonde o avanco maior leva o guerreiro
        var _g2 = instance_create_layer(_gx + lengthdir_x(14, _dir), _gy + lengthdir_y(14, _dir), "Instances", obj_attack);
        _g2.atraso = 6;
        _g2.forte = true;
        _g2.quebra_escudo = _quebra;
        _g2.damage = _arma.dano_forte * _dobro;
        _g2.knockback = _arma.empurra_forte;
        _g2.image_xscale = _arma.escala_forte;
        _g2.image_yscale = _arma.escala_forte;
    }
    if (_tipo == "impacto") {
        // machado: a lamina cai no ponto do golpe e o chao responde em volta dele. 72 px de raio: um
        // pouco alem da area do forte da espada (36 + 40), em todas as direcoes a partir do ponto
        golpe_em_volta(_gx, _gy, 72, _arma.dano_forte * _dobro, _arma.empurra_forte, true, _quebra);
        impacto(3, 7);
        fx_onda(_gx, _gy, 110, arma_cor());
    }
    if (_tipo == "estocada") {
        // alabarda: a ponta atravessa a fila, 150 px (o alcance comum dela e 50 + a area), cortado na parede
        var _comp = linha_ate_parede(x, y, _dir, 150);
        golpe_em_linha(x, y, _dir, _comp, 18, _arma.dano_forte * _dobro, _arma.empurra_forte, true, _quebra);
        with (instance_create_depth(x, y, depth - 1, obj_fx)) {
            tipo = "estocada";
            dir = _dir;
            dono = other.id;
            raio = _comp;
            espessura = 10;
            cor = arma_cor();
            vida_max = 12;
            vida = vida_max;
        }
    }
    if (_bomba_ate >= 0) {
        bomba_jogador(x, y, x + lengthdir_x(_bomba_ate, _dir), y + lengthdir_y(_bomba_ate, _dir), 24, 0, 1);
        tecnica_contar("bomba_combo");
    }
    // arco de corte desenhado (o golpe em si, obj_attack, e invisivel). O
    // segundo varre ao contrario; o terceiro e mais largo e mais claro
    // Do tamanho do alcance do golpe (64 e 76 px na espada), e claro, para nao confundir com o vermelho
    // dos ataques dos inimigos. Arma de Caido: abertura, raio e cor dela (a cor do Caido)
    var _espada = (_arma.caido == "");
    var _cor_arma = arma_cor();
    with (instance_create_depth(x, y, depth - 1, obj_fx)) {
        tipo = "arco";
        dir = _dir;
        dono = other.id;
        if (_forte) {
            abertura = _arma.arco_forte;
            raio = _arma.raio_forte;
            espessura = 24;
            cor = _espada ? make_colour_rgb(255, 160, 60) : merge_colour(_cor_arma, c_white, 0.25);
            intensidade = 1.6;
            vida_max = 13;
        } else {
            abertura = _arma.arco;
            raio = _arma.raio;
            espessura = 18;
            sentido = (other.golpe_atual == 2) ? -1 : 1;
            if (_espada) {
                cor = (other.golpe_atual == 2) ? make_colour_rgb(255, 215, 180) : make_colour_rgb(190, 210, 240);
            } else {
                cor = (other.golpe_atual == 2) ? merge_colour(_cor_arma, c_white, 0.45) : _cor_arma;
            }
            vida_max = 10;
        }
        vida = vida_max;
    }
    if (_forte) {
        combo_passo = 0;
        combo_janela = 0;
        attack_cooldown = _arma.recarga_forte;
        attack_anim_duration = 14;
        // adagas: avanco maior, que leva o guerreiro ate o segundo corte; alabarda: a ponta vai e o
        // corpo quase nao sai do lugar
        ataque_impulso = (_tipo == "duplo") ? 8 : ((_tipo == "estocada") ? 2 : 4);
    } else {
        // espada: mesma recarga do ataque antigo (20 frames), um inimigo comum morre
        // no mesmo tempo de antes; mais 14 frames para emendar o proximo
        combo_janela = _arma.janela;
        attack_cooldown = _arma.recarga;
        attack_anim_duration = 12;
        // alvo na beira do alcance: passo curto ate ele, para o golpe nao passar raspando
        // (48 px na espada: alcance mais 16)
        if (golpe_mirado && point_distance(x, y, _alvo.x, _alvo.y) > _alcance + 16) {
            ataque_impulso = 3;
        }
    }
    is_attacking = true;
    attack_anim_timer = attack_anim_duration;
    // segundo golpe mais agudo, para o combo ter um ritmo de ouvido. Cada arma tem o seu tom
    sfx(_forte ? snd_golpe_forte : snd_attack, 1, false, 1, 0, (golpe_atual == 2 ? 1.12 : 1) * _arma.tom);
};

// estocada: atacar no dash ou logo no fim dele (dash_freio) sai para o lado do
// dash, com 96 px de alcance contra 64 do golpe normal. Mesmo dano e recarga do
// golpe normal. Nao mexe na invencibilidade, presa ao is_dashing (10 frames)
golpe_estocada = false; // o ultimo golpe foi estocada (o robo conta)
estocar = function() {
    combo_passo = 0;
    combo_janela = 0;
    golpe_atual = 1;
    golpe_carregado = false;
    golpe_estocada = true;
    var _dir = point_direction(0, 0, dash_dir_x, dash_dir_y);
    ataque_dir = _dir;
    if (_dir <= 45 || _dir >= 315) {
        facing_dir = 1;
    } else if (_dir >= 135 && _dir <= 225) {
        facing_dir = 0;
    } else {
        facing_dir = (_dir < 180) ? 2 : 3;
    }
    // 96 de comprimento por 48 de largura; na diagonal, 82 nos dois eixos
    var _golpe = instance_create_layer(x + dash_dir_x * 48, y + dash_dir_y * 48, "Instances", obj_attack);
    _golpe.quebra_escudo = true;
    if (golpe_dobrado) {
        golpe_dobrado = false;
        _golpe.damage *= 2;
    }
    _golpe.image_xscale = (48 + abs(dash_dir_x) * 48) / sprite_get_width(spr_attack);
    _golpe.image_yscale = (48 + abs(dash_dir_y) * 48) / sprite_get_height(spr_attack);
    with (instance_create_depth(x, y, depth - 1, obj_fx)) {
        tipo = "estocada";
        dir = _dir;
        dono = other.id;
        raio = 96;
        espessura = 8;
        cor = make_colour_rgb(255, 110, 80);
        vida_max = 10;
        vida = vida_max;
    }
    attack_cooldown = 20;
    attack_anim_duration = 12;
    attack_anim_timer = attack_anim_duration;
    is_attacking = true;
    sfx(snd_estocada, 1, false);
};

// golpe especial (clique direito ou K): giro que acerta todos em volta, para
// quando estiver cercado. A recarga longa e o custo
especial_recarga = 0;
especial_recarga_max = 180; // 3 s, sugestao da issue #4; ajustar jogando
especial_buffer = 0;        // apertar na micro-pausa fica guardado, como o dash
especial_negado = 0;        // barrinha treme ao apertar sem recarga (como dash_negado)
especial_pronto = 0;        // barrinha pisca quando a recarga termina
especial_acertos = 0;       // inimigos no ultimo giro (o robo registra)
girar = function() {
    especial_recarga = especial_recarga_max;
    cancelar_carga();
    combo_passo = 0;
    combo_janela = 0;
    golpe_atual = 1;
    golpe_carregado = false;
    golpe_estocada = false;
    // dano e empurrao do golpe forte. Escala 2,4 = 77 px para cada lado, o mesmo
    // alcance do golpe forte (36 de distancia + 40 de metade da area), em volta toda
    with (instance_create_layer(x, y, "Instances", obj_attack)) {
        especial = true;
        forte = true;
        quebra_escudo = true;
        damage = 2;
        knockback = 28;
        image_xscale = 2.4;
        image_yscale = 2.4;
    }
    if (tem_tecnica("polvora")) {
        for (var _b = 0; _b < 4; _b++) {
            var _bx = x + lengthdir_x(62, 45 + _b * 90);
            var _by = y + lengthdir_y(62, 45 + _b * 90);
            if (collision_point(_bx, _by, obj_wall, false, true) == noone) {
                bomba_jogador(x, y, _bx, _by, 10, 30, 1);
            }
        }
        tecnica_contar("polvora");
    }
    with (instance_create_depth(x, y, depth - 1, obj_fx)) {
        tipo = "arco";
        dono = other.id;
        abertura = 360;
        raio = 75;
        espessura = 22;
        cor = make_colour_rgb(120, 200, 255);
        intensidade = 1.6;
        vida_max = 14;
        vida = vida_max;
    }
    // mesma recarga do golpe comum (20 frames): nao emenda um golpe no giro
    attack_cooldown = max(attack_cooldown, 20);
    attack_anim_duration = 14;
    attack_anim_timer = attack_anim_duration;
    is_attacking = true;
    sfx(snd_giro, 1, false);
};

// Giro Furioso: segurar o especial com a Furia cheia. 20 frames, como quem toma folego. Anda
// devagar enquanto segura, e por isso nao da para usar sem pensar
especial_carga = 0;
especial_carga_max = 20;
// a Furia de cada arma (scr_armas): a espada gira; o machado bate no chao (TERREMOTO); a alabarda
// avanca em linha (INVESTIDA, o avanco sai no Step); as adagas cortam em volta tres vezes
// seguidas (TEMPESTADE, os cortes seguintes saem no Step)
furia_investida = 0;     // px que faltam do avanco
furia_investida_dir = 0;
furia_pulsos = 0;        // cortes da Tempestade que ainda faltam
furia_pulso_timer = 0;
// um corte da Tempestade: em volta, perto, 1 de dano
furia_pulso = function() {
    golpe_em_volta(x, y, 118, 1, 30, true, true);
    with (instance_create_depth(x, y, depth - 1, obj_fx)) {
        tipo = "arco";
        dono = other.id;
        abertura = 360;
        raio = 116;
        espessura = 26;
        cor = arma_cor();
        borda = make_colour_rgb(255, 230, 200);
        intensidade = 1.8;
        vida_max = 12;
        vida = vida_max;
    }
    sfx(snd_giro, 1, false, 1, 0, 1.3);
};
giro_furioso = function() {
    var _arma = arma_def();
    especial_carga = 0;
    cancelar_carga();
    combo_passo = 0;
    combo_janela = 0;
    var _cor = (_arma.caido == "") ? make_colour_rgb(255, 90, 40) : arma_cor();
    var _raio_fx = 138;
    var _espessura_fx = 40;
    switch (_arma.furia) {
        case "TERREMOTO":
            // maior e mais forte que o giro, e empurra para longe: abre espaco em vez de so ferir
            golpe_em_volta(x, y, 190, 4, 80, true, true);
            global.lento = max(global.lento, 36);
            global.flash = max(global.flash, 0.3);
            impacto(10, 22);
            fx_onda(x, y, 230, _cor);
            _raio_fx = 188;
            _espessura_fx = 50;
            break;
        case "INVESTIDA":
            // para o alvo mirado, ou para onde o guerreiro olha; para na parede. O golpe sai agora, na
            // linha toda; o corpo chega la nos quadros seguintes (Step), invencivel no caminho
            var _alvo = mira_alvo();
            var _dir = (_alvo != noone) ? point_direction(x, y, _alvo.x, _alvo.y) : point_direction(0, 0, face_h, face_v);
            var _comp = linha_ate_parede(x, y, _dir, 240);
            ataque_dir = _dir;
            golpe_em_linha(x, y, _dir, _comp, 30, 3, 60, true, true);
            furia_investida = _comp;
            furia_investida_dir = _dir;
            global.lento = max(global.lento, 16);
            global.flash = max(global.flash, 0.22);
            impacto(4, 10);
            with (instance_create_depth(x, y, depth - 1, obj_fx)) {
                tipo = "estocada";
                dir = _dir;
                dono = other.id;
                raio = _comp;
                espessura = 30;
                cor = _cor;
                vida_max = 16;
                vida = vida_max;
            }
            _raio_fx = 70;
            _espessura_fx = 24;
            break;
        case "TEMPESTADE":
            // tres cortes, um agora e dois a cada 8 quadros (Step); o dash volta inteiro para sair logo
            furia_pulso();
            furia_pulsos = 2;
            furia_pulso_timer = 8;
            dash_charges = dash_charges_max;
            global.lento = max(global.lento, 16);
            global.flash = max(global.flash, 0.18);
            impacto(4, 8);
            _raio_fx = 0;
            break;
        default:
            // espada, o Giro Furioso de sempre. A barra zera depois de acertar: este golpe nao enche a proxima
            golpe_em_volta(x, y, 140, 3, 60, true, true);
            global.lento = max(global.lento, 24);
            global.flash = max(global.flash, 0.22);
            impacto(6, 12);
            fx_onda(x, y, 160, make_colour_rgb(255, 120, 60));
            break;
    }
    global.furia = 0;
    global.giros_furiosos += 1;
    invuln_timer = max(invuln_timer, 40);
    if (_raio_fx > 0) {
        with (instance_create_depth(x, y, depth - 1, obj_fx)) {
            tipo = "arco";
            dono = other.id;
            abertura = 360;
            raio = _raio_fx;
            espessura = _espessura_fx;
            cor = _cor;
            borda = make_colour_rgb(255, 210, 140);
            intensidade = 1.8;
            vida_max = 18;
            vida = vida_max;
        }
    }
    attack_cooldown = max(attack_cooldown, 20);
    attack_anim_duration = 14;
    attack_anim_timer = attack_anim_duration;
    is_attacking = true;
    sfx(snd_giro, 1, false, 1, 0, 0.75 * _arma.tom);
    som(snd_explosao, 0.7);
};

is_dead = false;
death_timer = 0;
death_timer_max = 90;

venceu = false;
// depois do rei cair: frames ate o texto do final, e uma folga depois dele
final_espera = 0;
final_pausa = 0;

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
// (nome recusado pela API volta de "enviando" para "nome")
sala_limpa_enviada = false;
duelo_curou = false; // nas salas de duelo, a cura de limpar a sala ja veio antes dele
vitoria_estado = "fim";
vitoria_nome = "";
vitoria_nome_recusado = false;
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
cam_w = camera_get_view_width(view_camera[0]);
cam_h = camera_get_view_height(view_camera[0]);
zoom = 1; // aperta na camera lenta (so na tela: a conta do jogo nao usa a camera)
posicionar_camera = function(_na_hora) {
    var _cam = view_camera[0];
    zoom = lerp(zoom, (global.lento > 0) ? 0.86 : 1, 0.14);
    // na cena, a camera vai devagar ate quem esta se apresentando
    var _cena = instance_exists(obj_cena);
    var _fx = _cena ? obj_cena.alvo_x : x;
    var _fy = _cena ? obj_cena.alvo_y : y;
    if (abs(zoom - 1) < 0.002) {
        zoom = 1;
    }
    var _cw = 2 * round(cam_w * zoom / 2);
    var _ch = 2 * round(cam_h * zoom / 2);
    camera_set_view_size(_cam, _cw, _ch);
    var _ax = clamp(_fx - _cw / 2, 0, room_width - _cw);
    var _ay = clamp(_fy - _ch / 2, 0, room_height - _ch);
    if (_na_hora) {
        cam_x = _ax;
        cam_y = _ay;
    } else {
        cam_x = lerp(cam_x, _ax, _cena ? 0.06 : 0.2);
        cam_y = lerp(cam_y, _ay, _cena ? 0.06 : 0.2);
    }
    var _cx = cam_x + global.chute_x * global.op_tremor;
    var _cy = cam_y + global.chute_y * global.op_tremor;
    global.chute_x *= 0.75;
    global.chute_y *= 0.75;
    if (global.tremor > 0) {
        tremor_fase += 1;
        _cx += sin(tremor_fase * 1.7) * global.tremor * global.op_tremor;
        _cy += cos(tremor_fase * 2.3) * global.tremor * global.op_tremor;
        global.tremor = (global.tremor < 0.5) ? 0 : global.tremor * 0.82;
    }
    camera_set_view_pos(_cam, round(clamp(_cx, 0, room_width - _cw)), round(clamp(_cy, 0, room_height - _ch)));
};
camera_set_view_target(view_camera[0], noone);
global.hitstop = 0;
global.tremor = 0;
global.lento = 0;
global.flash = 0;
global.chute_x = 0;
global.chute_y = 0;
posicionar_camera(true);

global.game_paused = false;

global.morto_x = x;
global.morto_y = y;
// o que as tecnicas mudam nos numeros do jogador: ao nascer em cada sala e ao ganhar uma nova
tecnicas_aplicar = function() {
    if (tem_tecnica("folego") && dash_charges_max < 3) {
        dash_charges_max = 3;
        dash_charges += 1;
        dash_cooldown_max = 24;
        hud_recarga = array_create(dash_charges_max, 0);
        tecnica_contar("folego");
    }
};
tecnicas_aplicar();
