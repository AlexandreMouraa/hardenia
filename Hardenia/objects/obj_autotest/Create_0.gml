// Robo de teste automatico. So existe quando o jogo abre com -autotest
// (quem cria e o obj_menu). Joga a run inteira sozinho, sem som e em janela,
// e grava log + prints na pasta de save: %LOCALAPPDATA%\Hardenia\autotest\
// Parametros: -runs N (padrao 3)  -speed FPS (padrao 240)  -morrer
// -desatento N  -diag  -appsurface  -mouse  -carregar  -especial  -estocar  -formas  -grupo  -horda. Para rodar: tools\autotest.ps1
// Rede: por padrao o robo nao manda nada ao site. Com -api URL ele manda os
// eventos para essa API (teste local), e com -nome X digita X na vitoria e
// envia ao ranking dela.
runs_total = 3;
velocidade = 240;
diag = false;
// -desatento N: em N% dos avisos o robo nao percebe a zona (simula humano;
// sem isso ele nunca morre e o caminho da morte fica sem teste)
desatento = 0;
percebeu = {};
// -morrer: na primeira run o robo morre uma vez em cada sala, de proposito,
// para testar a tela de morte, a volta ao comeco da run e o contador de tentativas.
// Na segunda, apanha sem morrer, para testar a vida entre salas e a cura
morrer = false;
salas_morreu = {};
frases_testadas = false;
mortes_run = 0;
// vida: danos conta os golpes que pegaram (golpes_inimigos conta os que foram dados)
danos = 0;
curas = 0;
vida_antes = -1;
avisos_max = 0;
// -mouse: ataca com o clique, mirando no inimigo (sem precisar virar), como
// quem joga com mouse. Sem ela, ataca com J, para onde esta virado
usar_mouse = false;
// -carregar: segura o ataque depois de cada golpe e solta com a carga cheia
// (testa o golpe carregado; soma "carregados=N" no resumo)
carregar = false;
segurar_frames = 0;
carregados = 0;
viu_carga = false;
// -especial: usa o giro sempre que tem alvo perto e recarga pronta (soma
// "especiais=N" no resumo e registra quantos inimigos cada giro acertou)
usar_especial = false;
especiais = 0;
especial_logado = false;
viu_especial = false;
cercou = false;
// -estocar: com alvo perto e carga de dash, da o dash e ataca 2 frames depois
// (soma "estocadas=N" no resumo)
usar_estocada = false;
estocar_em = 0;
estocadas = 0;
estocada_antes = false;
viu_estocada = false;
// -formas: confere a geometria das zonas e da uma das 4 formas a cada inimigo,
// com mais vida, para todas aparecerem (prints "aviso_*" e "golpe_*"; soma
// "formas=N" no resumo, e sao 8 quando todas apareceram nos dois momentos)
testar_formas = false;
formas_testadas = false;
formas_vistas = {};
tipos_vistos = {};
ataques_formas = [
    { forma: "quadrado", gatilho: 50, alcance: 40, tamanho: 32, aviso: 45, duracao: 20, acerto: 10, recarga: 40, avanco: 0 },
    { forma: "circulo", gatilho: 70, alcance: 0, tamanho: 80, aviso: 45, duracao: 20, acerto: 10, recarga: 40, avanco: 0 },
    { forma: "linha", gatilho: 70, alcance: 130, tamanho: 16, aviso: 45, duracao: 20, acerto: 10, recarga: 40, avanco: 0 },
    { forma: "arco", gatilho: 60, alcance: 90, tamanho: 60, aviso: 45, duracao: 20, acerto: 10, recarga: 40, avanco: 0 },
];
// -grupo: na primeira sala, o robo fica parado e confere o comportamento em grupo:
// visao, memoria, alerta dos vizinhos e cerco (print "cerco" e "grupo=1" no resumo)
testar_grupo = false;
grupo_passo = 0;
grupo_tempo = 0;
grupo_parede = noone;
grupo_a = noone;
grupo_dir = 0;
grupo_ok = 0;
grupo_chegou = false;
// -horda: joga as 3 ondas da sala de teste, com a vida sempre cheia (aqui a pergunta
// e se o fluxo funciona, nao o balanceamento). Depois mede o limite do aparelho a 60 fps,
// parado, e registra o fps a cada segundo. Rodar com -Runs 1
usar_horda = false;
golpes = 0;
nome_robo = "";
// golpes seguidos que nao tiraram vida do alvo (ver Step_1, ataque)
golpes_vazios = 0;
alvo_golpeado = noone;
hp_golpeado = 0;
for (var _i = 1; _i <= parameter_count(); _i++) {
    if (parameter_string(_i) == "-diag") {
        diag = true;
    }
    if (parameter_string(_i) == "-morrer") {
        morrer = true;
    }
    if (parameter_string(_i) == "-mouse") {
        usar_mouse = true;
    }
    if (parameter_string(_i) == "-carregar") {
        carregar = true;
    }
    if (parameter_string(_i) == "-especial") {
        usar_especial = true;
    }
    if (parameter_string(_i) == "-estocar") {
        usar_estocada = true;
    }
    if (parameter_string(_i) == "-formas") {
        testar_formas = true;
    }
    if (parameter_string(_i) == "-grupo") {
        testar_grupo = true;
    }
    if (parameter_string(_i) == "-horda") {
        usar_horda = true;
    }
}
for (var _i = 1; _i < parameter_count(); _i++) {
    if (parameter_string(_i) == "-runs") {
        runs_total = real(parameter_string(_i + 1));
    }
    if (parameter_string(_i) == "-speed") {
        velocidade = real(parameter_string(_i + 1));
    }
    if (parameter_string(_i) == "-desatento") {
        desatento = real(parameter_string(_i + 1));
    }
    if (parameter_string(_i) == "-nome") {
        nome_robo = parameter_string(_i + 1);
    }
}

frame = 0;
run_atual = 0;
runs_feitas = 0;
vitorias = 0;
mortes_total = 0;
encerrando = false;

pasta = "autotest/";
arquivo_log = pasta + "log.txt";
directory_create("autotest");
var _f = file_text_open_write(arquivo_log);
file_text_write_string(_f, "frame\trun\tsala\tevento\tdetalhe");
file_text_writeln(_f);
file_text_close(_f);

// uma linha por evento, gravada na hora (sobrevive a um crash)
log = function(_evento, _detalhe) {
    var _arq = file_text_open_append(arquivo_log);
    file_text_write_string(_arq, string(frame) + "\t" + string(run_atual) + "\t" + room_get_name(room) + "\t" + _evento + "\t" + string(_detalhe));
    file_text_writeln(_arq);
    file_text_close(_arq);
};

// screen_save so funciona no Draw GUI End: aqui so fica o pedido
print_pendente = "";
prints_feitos = 0;
prints_max = 80;
pedir_print = function(_nome) {
    if (prints_feitos < prints_max && print_pendente == "") {
        print_pendente = _nome;
    }
};

// erro de execucao: registra e fecha, em vez de parar na janela de erro
exception_unhandled_handler(function(_ex) {
    log("ERRO", string_replace_all(string(_ex.longMessage), "\n", " | "));
    game_end(2);
    return 0;
});

// Entrada do robo. Teclas simuladas (keyboard_key_press) nao funcionam com a
// janela sem foco, entao: movimento, dash e Enter da vitoria o obj_player le
// destas variaveis; ataque, pausa e Enter do menu sao os proprios eventos de
// tecla, chamados com event_perform. O clique (-mouse) tambem e variavel: o
// ponto da mira vai em bot_mira_x/y, na sala
bot_h = 0;
bot_v = 0;
bot_dash = false;
bot_enter = false;
bot_clique = false;
bot_segurar = false;
bot_especial = false;
bot_mira_x = 0;
bot_mira_y = 0;

encerrar = function(_codigo) {
    if (encerrando) {
        return;
    }
    encerrando = true;
    bot_h = 0;
    bot_v = 0;
    log("encerrar", "codigo=" + string(_codigo));
    game_end(_codigo);
};

terminar_run = function(_motivo) {
    runs_feitas += 1;
    log("run_fim", _motivo + " tentativas=" + string(global.tentativas));
    room_goto(Room_Menu);
};

// portao que leva adiante (o que brilha quando a sala esta limpa)
saida_adiante = function() {
    var _prox = room_next(room);
    var _objs = [obj_exit_to_room1, obj_exit_to_tunel, obj_exit_to_room2, obj_exit_to_room3, obj_exit_to_trono];
    var _salas = [Room1, Room_Tunel, Room2, Room3, Room_Trono];
    for (var _i = 0; _i < array_length(_objs); _i++) {
        if (_salas[_i] == _prox && instance_exists(_objs[_i])) {
            return instance_find(_objs[_i], 0);
        }
    }
    return noone;
};

// a zona do golpe encosta no jogador se ele estiver em _x,_y?
zona_toca = function(_z, _x, _y, _margem) {
    var _p = instance_find(obj_player, 0);
    var _l = _x - (_p.x - _p.bbox_left) - _margem;
    var _r = _x + (_p.bbox_right - _p.x) + _margem;
    var _t = _y - (_p.y - _p.bbox_top) - _margem;
    var _b = _y + (_p.bbox_bottom - _p.y) + _margem;
    return zona_toca_retangulo(_z, _l, _t, _r, _b);
};

// a zona passa do quadrado de 64? Ate esse tamanho, olhar 18 px a frente (Step_1,
// movimento) basta, e procurar a saida mudaria o jeito de o robo lutar com o
// golpe de hoje: os numeros do resumo deixariam de servir de comparacao
zona_grande = function(_z) {
    var _v = _z.pontos;
    var _x1 = _v[0][0];
    var _x2 = _x1;
    var _y1 = _v[0][1];
    var _y2 = _y1;
    for (var _i = 1; _i < array_length(_v); _i++) {
        _x1 = min(_x1, _v[_i][0]);
        _x2 = max(_x2, _v[_i][0]);
        _y1 = min(_y1, _v[_i][1]);
        _y2 = max(_y2, _v[_i][1]);
    }
    return _x2 - _x1 > 64 || _y2 - _y1 > 64;
};

// quantos passos de 16 px na direcao _dh,_dv ate sair de todas as zonas (passos_max
// + 1 se nao sair, ou se tiver parede no caminho). Olhar so 18 px a frente nao
// mostra a saida de uma zona grande
passos_max = 12;
passos_ate_sair = function(_zonas, _x, _y, _dh, _dv) {
    var _norm = (_dh != 0 && _dv != 0) ? 0.7071 : 1;
    for (var _passo = 1; _passo <= passos_max; _passo++) {
        var _px = _x + _dh * _norm * 16 * _passo;
        var _py = _y + _dv * _norm * 16 * _passo;
        if (collision_line(_x, _y, _px, _py, obj_wall, false, true) != noone) {
            break;
        }
        var _livre = true;
        for (var _i = 0; _i < array_length(_zonas); _i++) {
            if (zona_toca(_zonas[_i][0], _px, _py, 8)) {
                _livre = false;
                break;
            }
        }
        if (_livre) {
            return _passo;
        }
    }
    return passos_max + 1;
};

// -formas: geometria das zonas com casos conhecidos, e a parede protegendo.
// Erro vira FALHA no log, e o autotest.ps1 reprova
testar_zonas = function() {
    // forma, alcance, tamanho, direcao; retangulo (l, t, r, b); encosta?
    var _casos = [
        ["quadrado", 40, 32, 0, 1070, 1000, 1080, 1010, true], // na borda
        ["quadrado", 40, 32, 0, 1073, 1000, 1080, 1010, false], // logo depois da borda
        ["quadrado", 40, 32, 0, 1030, 995, 1040, 1005, true], // retangulo dentro da zona
        ["quadrado", 40, 32, 0, 900, 900, 1200, 1100, true], // zona dentro do retangulo
        ["circulo", 40, 40, 0, 1070, 995, 1085, 1005, true], // na borda
        ["circulo", 40, 40, 0, 1074, 1034, 1084, 1044, false], // no canto do quadrado em volta
        ["linha", 100, 10, 45, 1030, 960, 1040, 970, true], // no meio da linha
        ["linha", 100, 10, 45, 1060, 990, 1070, 1000, false], // ao lado da linha
        ["arco", 70, 60, 0, 1050, 995, 1060, 1005, true], // na frente
        ["arco", 70, 60, 0, 930, 995, 945, 1005, false], // atras
        ["arco", 70, 60, 0, 1008, 938, 1012, 942, false], // ao lado, a 80 graus
        ["arco", 70, 60, 0, 1066, 980, 1080, 1020, true], // so a barriga do arco
        ["arco", 70, 110, 0, 985, 940, 995, 950, true], // abertura maior que 180
        ["arco", 70, 110, 0, 940, 995, 950, 1005, false], // atras dessa abertura
    ];
    for (var _i = 0; _i < array_length(_casos); _i++) {
        var _c = _casos[_i];
        // nasce em outro lugar para testar zona_posicionar junto
        var _z = zona_criar({ forma: _c[0], alcance: _c[1], tamanho: _c[2] }, 0, 0, _c[3]);
        zona_posicionar(_z, 1000, 1000);
        if (zona_toca_retangulo(_z, _c[4], _c[5], _c[6], _c[7]) != _c[8]) {
            log("FALHA_zona", "caso " + string(_i) + " forma=" + _c[0]);
        }
    }

    // parede no meio protege: de um lado sem parede, acerta; com parede, nao
    var _p = instance_find(obj_player, 0);
    var _ataque = { forma: "quadrado", alcance: 40, tamanho: 32 };
    for (var _dir = 0; _dir < 360; _dir += 90) {
        var _ox = _p.x + lengthdir_x(50, _dir);
        var _oy = _p.y + lengthdir_y(50, _dir);
        if (collision_line(_ox, _oy, _p.x, _p.y, obj_wall, false, true) == noone) {
            var _zona = zona_criar(_ataque, _ox, _oy, _dir + 180);
            if (!zona_acerta_jogador(_zona)) {
                log("FALHA_zona", "sem parede nao acertou");
            }
            var _parede = instance_create_layer((_ox + _p.x) / 2, (_oy + _p.y) / 2, "Instances", obj_wall);
            if (zona_acerta_jogador(_zona)) {
                log("FALHA_zona", "acertou atraves da parede");
            }
            instance_destroy(_parede);
            log("zonas_conferidas", string(array_length(_casos)) + " casos e parede");
            return;
        }
    }
    log("FALHA_zona", "jogador cercado de parede: nao deu para testar");
};

// -grupo. Passo 0: visao e alerta na hora, e comeca a memoria com uma parede no meio.
// Passo 1: quem perdeu o jogador foi ate a memoria e desistiu; todos acordam longe.
// Passo 2: com uma parede grande no meio, ele da a volta e chega a ver o jogador.
// Passo 3: os 4 chegam, cada um de um lado. Erro vira FALHA no log
grupo_conferir = function(_p) {
    grupo_tempo -= 1;
    switch (grupo_passo) {
        case 0:
            grupo_a = instance_find(obj_enemy, 0);
            var _b = instance_find(obj_enemy, 1);
            var _c = instance_find(obj_enemy, 2);
            var _dir = -1;
            for (var _d = 0; _d < 360 && _dir < 0; _d += 30) {
                if (collision_line(_p.x, _p.y, _p.x + lengthdir_x(280, _d), _p.y + lengthdir_y(280, _d), obj_wall, false, true) == noone) {
                    _dir = _d;
                }
            }
            if (_dir < 0) {
                log("FALHA_grupo", "sem lado livre em volta do jogador");
                grupo_passo = 4;
                return;
            }
            with (obj_enemy) {
                acordado = false;
            }
            grupo_a.x = _p.x + lengthdir_x(200, _dir);
            grupo_a.y = _p.y + lengthdir_y(200, _dir);
            // visao: enxerga perto, nao enxerga longe nem atraves de parede
            var _ve = false;
            with (grupo_a) {
                _ve = inimigo_ve_jogador();
            }
            if (!_ve) {
                log("FALHA_grupo", "nao viu o jogador a 200 px");
            }
            // parede grande e centrada na linha: a origem do sprite e o canto dela
            grupo_parede = instance_create_layer(_p.x + lengthdir_x(100, _dir), _p.y + lengthdir_y(100, _dir), "Instances", obj_wall);
            grupo_parede.image_xscale = 48 / sprite_get_width(grupo_parede.sprite_index);
            grupo_parede.image_yscale = 48 / sprite_get_height(grupo_parede.sprite_index);
            grupo_parede.x -= 24;
            grupo_parede.y -= 24;
            with (grupo_a) {
                _ve = inimigo_ve_jogador();
            }
            if (_ve) {
                log("FALHA_grupo", "viu atraves da parede");
            }
            // alerta: um golpe de verdade acorda o vizinho perto, e nao o longe
            _b.x = grupo_a.x + lengthdir_x(100, _dir + 90);
            _b.y = grupo_a.y + lengthdir_y(100, _dir + 90);
            _c.x = grupo_a.x + lengthdir_x(grupo_a.raio_alerta + 100, _dir);
            _c.y = grupo_a.y + lengthdir_y(grupo_a.raio_alerta + 100, _dir);
            var _a = grupo_a;
            with (instance_create_layer(_a.x, _a.y, "Instances", obj_attack)) {
                acertar(_a);
                instance_destroy();
            }
            if (!grupo_a.acordado || !_b.acordado) {
                log("FALHA_grupo", "o golpe nao acordou o inimigo e o vizinho");
            }
            if (_c.acordado) {
                log("FALHA_grupo", "o golpe acordou inimigo longe");
            }
            // memoria: atras da parede, vai ate o ultimo lugar onde viu e desiste. O
            // lugar fica mais para longe na mesma linha, para a parede continuar no meio
            with (obj_enemy) {
                x = home_x;
                y = home_y;
                acordado = false;
            }
            grupo_a.x = _p.x + lengthdir_x(200, _dir);
            grupo_a.y = _p.y + lengthdir_y(200, _dir);
            grupo_a.acordado = true;
            grupo_a.memoria_x = grupo_a.x + lengthdir_x(24, _dir);
            grupo_a.memoria_y = grupo_a.y + lengthdir_y(24, _dir);
            grupo_a.procura = grupo_a.procura_max;
            grupo_dir = _dir;
            grupo_tempo = 45;
            grupo_passo = 1;
            break;

        case 1:
            if (grupo_tempo <= 0) {
                if (grupo_a.acordado) {
                    log("FALHA_grupo", "sem ver o jogador, nao desistiu depois da memoria");
                }
                instance_destroy(grupo_parede);
                // parede de 160 x 160 entre os dois, atravessando a linha de visao
                with (obj_enemy) {
                    x = home_x;
                    y = home_y;
                    acordado = false;
                }
                var _meio_x = _p.x + lengthdir_x(120, grupo_dir);
                var _meio_y = _p.y + lengthdir_y(120, grupo_dir);
                grupo_parede = instance_create_layer(_meio_x - 80, _meio_y - 80, "Instances", obj_wall);
                grupo_parede.image_xscale = 160 / sprite_get_width(grupo_parede.sprite_index);
                grupo_parede.image_yscale = 160 / sprite_get_height(grupo_parede.sprite_index);
                global.campo.sala = -1;
                grupo_a.x = _p.x + lengthdir_x(250, grupo_dir);
                grupo_a.y = _p.y + lengthdir_y(250, grupo_dir);
                grupo_a.vendo = false;
                grupo_a.acordado = true;
                grupo_a.memoria_x = _p.x;
                grupo_a.memoria_y = _p.y;
                grupo_a.procura = grupo_a.procura_max;
                with (grupo_a) {
                    campo_ver(_p.x, _p.y);
                }
                grupo_tempo = 900;
                grupo_passo = 2;
            }
            break;

        case 2:
            with (grupo_a) {
                other.grupo_chegou = inimigo_ve_jogador();
            }
            if (grupo_chegou || grupo_tempo <= 0) {
                if (grupo_chegou) {
                    log("contorno", "viu o jogador depois de " + string(900 - grupo_tempo) + " frames");
                } else {
                    log("FALHA_grupo", "nao deu a volta na parede");
                }
                pedir_print("contorno");
                instance_destroy(grupo_parede);
                global.campo.sala = -1;
                // todos juntos no mesmo lado: o cerco e que tem de espalhar
                var _k = 0;
                var _lado = grupo_dir;
                with (obj_enemy) {
                    x = _p.x + lengthdir_x(200, _lado + 12 * (_k - 1.5));
                    y = _p.y + lengthdir_y(200, _lado + 12 * (_k - 1.5));
                    home_x = x;
                    home_y = y;
                    acordado = true;
                    memoria_x = _p.x;
                    memoria_y = _p.y;
                    procura = procura_max;
                    cerco_timer = 0;
                    _k += 1;
                }
                grupo_tempo = 220;
                grupo_passo = 3;
            }
            break;

        case 3:
            // 220 frames: tempo de um inimigo dar a volta ate o lado oposto
            if (grupo_tempo <= 0) {
                var _n = instance_number(obj_enemy);
                var _perto = 0;
                var _angulos = [];
                with (obj_enemy) {
                    if (point_distance(x, y, _p.x, _p.y) <= 160) {
                        _perto += 1;
                    }
                    array_push(_angulos, point_direction(_p.x, _p.y, x, y));
                }
                var _menor = 360;
                for (var _i = 0; _i < _n; _i++) {
                    for (var _j = _i + 1; _j < _n; _j++) {
                        _menor = min(_menor, abs(angle_difference(_angulos[_i], _angulos[_j])));
                    }
                }
                log("cerco", "perto=" + string(_perto) + " de " + string(_n) + " menor_angulo=" + string(round(_menor)));
                if (_perto < _n) {
                    log("FALHA_grupo", "o grupo nao chegou");
                }
                // os lados ficam a 60 graus e cada um balanca 12 para cada lado: no minimo 36
                if (_menor < 30) {
                    log("FALHA_grupo", "dois inimigos chegaram do mesmo lado");
                }
                pedir_print("cerco");
                grupo_ok = 1;
                grupo_passo = 4;
            }
            break;
    }
};

// celula livre da grade mais perto de _x,_y (encostado na parede, a celula
// do proprio jogador cai na margem de seguranca e o caminho falharia)
celula_livre = function(_x, _y) {
    var _cx = floor(_x / 8);
    var _cy = floor(_y / 8);
    if (mp_grid_get_cell(grade, _cx, _cy) == 0) {
        return [_x, _y];
    }
    for (var _r = 1; _r <= 6; _r++) {
        for (var _ix = -_r; _ix <= _r; _ix++) {
            for (var _iy = -_r; _iy <= _r; _iy++) {
                if (max(abs(_ix), abs(_iy)) == _r && mp_grid_get_cell(grade, _cx + _ix, _cy + _iy) == 0) {
                    return [(_cx + _ix) * 8 + 4, (_cy + _iy) * 8 + 4];
                }
            }
        }
    }
    return [_x, _y];
};

tem_caminho = function(_x1, _y1, _x2, _y2) {
    var _a = celula_livre(_x1, _y1);
    var _b = celula_livre(_x2, _y2);
    return mp_grid_path(grade, caminho, _a[0], _a[1], _b[0], _b[1], true);
};

// habilidades de elite que apareceram: o log e o resumo mostram quantas, com um print de cada
elites_vistas = {};
ver_elite = function(_nome) {
    if (!variable_struct_exists(elites_vistas, _nome)) {
        variable_struct_set(elites_vistas, _nome, true);
        log("elite", _nome);
        pedir_print("elite_" + _nome);
    }
};

// chefe: conta as vezes que ele caiu e registra as duas fases (print da metade da vida)
chefe_vivo = false;
chefe_vencido = 0;
chefe_metade_vista = false;

// estado por sala (zerado no Room Start)
grade = -1;
caminho = path_add();
sala_anterior = -1;
salas_checadas = {};
tempo_sala = 0;
inimigos_antes = 0;
estava_morto = false;
espera = 0;
mortes_sala = 0;
ultimo_x = 0;
ultimo_y = 0;
travado = 0;
quieto = 0;
ocioso = 0;
forcar_caminho = 0;
andou_frames = 0;
janela_x = 0;
janela_y = 0;
mov_h = 0;
mov_v = 0;
desvio_frames = 0;
desvio_h = 0;
desvio_v = 0;
proximo_x = -1;
proximo_y = -1;
sala_limpa_logada = false;
limpa_desde = 0;
sem_caminho_logado = false;
ja_viu_aviso = false;
viu_fx_morte = false;
// prints do primeiro dash da run 1: no meio (rastro e riscos) e logo depois
dash_prints = 0;
viu_combo = false;
combos = 0;
forte_antes = false;
testou_pausa = false;

audio_master_gain(0);
game_set_speed(velocidade, gamespeed_fps);
// sem a application surface o screen_save pega a janela inteira, com o HUD.
// -appsurface mantem a renderizacao normal (o print sai sem o HUD)
var _manter_surface = false;
for (var _i = 1; _i <= parameter_count(); _i++) {
    if (parameter_string(_i) == "-appsurface") {
        _manter_surface = true;
    }
}
if (!_manter_surface) {
    application_surface_enable(false);
}

log("inicio", "runs=" + string(runs_total) + " speed=" + string(velocidade) + " save=" + game_save_id);
