// Robo de teste automatico. So existe quando o jogo abre com -autotest
// (quem cria e o obj_menu). Joga a run inteira sozinho, sem som e em janela,
// e grava log + prints na pasta de save: %LOCALAPPDATA%\Hardenia\autotest\
// Parametros: -runs N (padrao 3)  -speed FPS (padrao 240)  -morrer
// -desatento N  -diag  -appsurface  -mouse  -carregar  -especial. Para rodar: tools\autotest.ps1
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
// para testar a tela de morte, o reinicio da sala e o contador de tentativas
morrer = false;
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
    var _objs = [obj_exit_to_room1, obj_exit_to_room2, obj_exit_to_room3];
    var _salas = [Room1, Room2, Room3];
    for (var _i = 0; _i < array_length(_objs); _i++) {
        if (_salas[_i] == _prox && instance_exists(_objs[_i])) {
            return instance_find(_objs[_i], 0);
        }
    }
    return noone;
};

// a zona do golpe (quadrado de 64 em volta de _z[0],_z[1]) encosta no
// jogador se ele estiver em _x,_y?
zona_toca = function(_z, _x, _y, _margem) {
    var _p = instance_find(obj_player, 0);
    var _l = _x - (_p.x - _p.bbox_left) - _margem;
    var _r = _x + (_p.bbox_right - _p.x) + _margem;
    var _t = _y - (_p.y - _p.bbox_top) - _margem;
    var _b = _y + (_p.bbox_bottom - _p.y) + _margem;
    return rectangle_in_rectangle(_z[0] - 32, _z[1] - 32, _z[0] + 32, _z[1] + 32, _l, _t, _r, _b) > 0;
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
