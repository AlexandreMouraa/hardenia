// O que fica no aparelho entre uma sessao e outra: opcoes e recordes, nunca o personagem. Morrer
// continua zerando a run. No navegador fica no armazenamento da pagina. O robo nao le nem grava:
// a run dele tem de sair igual em qualquer computador.
#macro SALVO_ARQUIVO "hardenia-salvo.json"
global.salvo = {
    abertura_vista: false,
    mortes_total: 0,
    vitorias: 0,
    melhor_ms: 0,
    melhor_tentativas: 0,
    caidos_livres: [],
    dicas: {},
};
// opcoes: 1 = normal
global.op_tremor = 1;
global.op_flash = true;
global.op_dicas = true;
global.salvo_lido = false;

function salvo_ler() {
    if (global.salvo_lido || instance_exists(obj_autotest)) {
        return;
    }
    global.salvo_lido = true;
    if (!file_exists(SALVO_ARQUIVO)) {
        return;
    }
    try {
        var _f = file_text_open_read(SALVO_ARQUIVO);
        var _texto = file_text_read_string(_f);
        file_text_close(_f);
        var _d = json_parse(_texto);
        // so o que ja existe: arquivo antigo ou mexido nao quebra o jogo
        var _campos = variable_struct_get_names(global.salvo);
        for (var _i = 0; _i < array_length(_campos); _i++) {
            if (variable_struct_exists(_d, _campos[_i])) {
                variable_struct_set(global.salvo, _campos[_i], variable_struct_get(_d, _campos[_i]));
            }
        }
        if (variable_struct_exists(_d, "marcas")) {
            global.marcas_morte = _d.marcas;
        }
        if (variable_struct_exists(_d, "vol_musica")) {
            global.vol_musica = _d.vol_musica;
            global.vol_efeitos = _d.vol_efeitos;
            global.op_tremor = _d.tremor;
            global.op_flash = _d.flash;
            global.op_ambiente = _d.ambiente;
            global.op_dicas = _d.dicas;
        }
    } catch (_erro) {
        // arquivo estragado: comeca do zero
    }
    global.abertura_vista = global.salvo.abertura_vista;
}

function salvo_gravar() {
    if (instance_exists(obj_autotest)) {
        return;
    }
    global.salvo.abertura_vista = global.abertura_vista;
    var _d = {
        vol_musica: global.vol_musica,
        vol_efeitos: global.vol_efeitos,
        tremor: global.op_tremor,
        flash: global.op_flash,
        ambiente: global.op_ambiente,
        dicas: global.op_dicas,
        marcas: global.marcas_morte,
    };
    var _campos = variable_struct_get_names(global.salvo);
    for (var _i = 0; _i < array_length(_campos); _i++) {
        variable_struct_set(_d, _campos[_i], variable_struct_get(global.salvo, _campos[_i]));
    }
    var _f = file_text_open_write(SALVO_ARQUIVO);
    file_text_write_string(_f, json_stringify(_d));
    file_text_close(_f);
}

function salvo_vitoria(_tentativas, _ms) {
    global.salvo.vitorias += 1;
    if (global.salvo.melhor_ms == 0 || _ms < global.salvo.melhor_ms) {
        global.salvo.melhor_ms = _ms;
        global.salvo.melhor_tentativas = _tentativas;
    }
    salvo_gravar();
}

function salvo_caido_livre(_chave) {
    if (!array_contains(global.salvo.caidos_livres, _chave)) {
        array_push(global.salvo.caidos_livres, _chave);
    }
    salvo_gravar();
}
