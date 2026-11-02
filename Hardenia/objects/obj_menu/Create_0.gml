// modo de teste automatico: Hardenia.exe -autotest (ver obj_autotest)
if (!instance_exists(obj_autotest)) {
    for (var _i = 1; _i <= parameter_count(); _i++) {
        if (parameter_string(_i) == "-autotest") {
            instance_create_depth(0, 0, 0, obj_autotest);
            break;
        }
    }
}

// tela cheia so ao abrir o jogo: quem trocou para janela (Alt+Enter) e voltou
// ao menu continua em janela. No navegador quem decide e o jogador (F11)
if (!instance_exists(obj_autotest) && !variable_global_exists("tela_cheia_aplicada") && os_browser == browser_not_a_browser) {
    global.tela_cheia_aplicada = true;
    window_set_fullscreen(true);
}

// opcoes e recordes do aparelho (nao vale para o robo)
salvo_ler();
volumes_aplicar();

// no menu o cursor do sistema volta (no jogo ele fica escondido)
window_set_cursor(cr_default);

// cada morte conta uma tentativa; a run inteira comeca aqui
global.tentativas = 1;
global.mortes_por_sala = {};
global.caidos_vistos = {};
global.desafio = false;
run_zerar();

musica(snd_menu_music);
som_fundo(-1);
coracao_atualizar(false);

// o menu: o que cada item faz. O robo aperta Enter no primeiro
cursor = 0;
mouse_antes_x = -1;
mouse_antes_y = -1;
itens = [
    { nome: "Jogar", acao: "jogar" },
    { nome: "Desafio do dia", acao: "desafio" },
    { nome: "Como jogar", acao: "como_jogar" },
    { nome: "Opções", acao: "opcoes" },
    { nome: "Créditos", acao: "creditos" },
];
// no navegador nao ha janela para fechar
if (os_browser == browser_not_a_browser) {
    array_push(itens, { nome: "Sair", acao: "sair" });
}
acionar = function(_acao) {
    switch (_acao) {
        case "jogar":
            event_perform(ev_keypress, vk_enter);
            break;
        case "desafio":
            global.desafio = true;
            global.desafio_dia = desafio_hoje();
            run_zerar();
            comecar();
            break;
        case "sair":
            game_end();
            break;
        default:
            sfx(snd_confirm, 1, false);
            with (instance_create_depth(0, 0, -9500, obj_opcoes)) {
                modo = _acao;
            }
            break;
    }
};
// [esquerda, cima, direita, baixo] do item, na tela
item_ret = function(_i) {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _esc = max(1, _h / 540);
    var _y = _h * 0.46 + _i * 34 * _esc;
    return [_w * 0.56, _y, _w * 0.8, _y + 32 * _esc];
};
// o primeiro item e sempre o Enter: o robo e quem ja sabe jogar comecam direto

// a abertura aparece so na primeira vez
comecar = function() {
    sfx(snd_confirm, 1, false);
    if (!global.abertura_vista) {
        global.abertura_vista = true;
        salvo_gravar();
        instance_create_depth(0, 0, -9000, obj_abertura);
    } else {
        comecar_run();
    }
};

// comeca a run: zera o tempo e avisa o site (estatisticas de partidas)
comecar_run = function() {
    global.run_frames = 0;
    rede_evento("inicio");
    ir_para_sala(Room1);
};

// prototipo de horda: H ou clique no texto do canto (obj_menu, Draw GUI). Fica fora do
// caminho da run: nao conta tempo de ranking nem manda evento ao site
horda_iniciar = function() {
    if (instance_exists(obj_mapa) || instance_exists(obj_abertura) || instance_exists(obj_opcoes)) {
        return;
    }
    sfx(snd_confirm, 1, false);
    global.run_frames = 0;
    room_goto(Room_Horda);
};
botao_horda = function() {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _esc = max(1, _h / 540);
    return [_w - 240 * _esc, 30 * _esc, _w, 70 * _esc];
};
