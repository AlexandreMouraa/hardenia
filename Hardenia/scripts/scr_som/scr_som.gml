// Musica, som de fundo e efeitos, com o volume de cada um (opcoes). Musica e fundo trocam suave:
// o que estava tocando abaixa enquanto o novo sobe. Nada aqui usa o sorteio do jogo.
global.vol_musica = 0.8;
global.vol_efeitos = 1;
global.musica_agora = -1;
global.musica_inst = -1;
global.musica_velha = -1;
global.fundo_agora = -1;
global.fundo_inst = -1;
global.fundo_velho = -1;
global.coracao_inst = -1;
global.passo_n = 0;
// som de fundo e bem mais baixo que a musica
#macro FUNDO_GANHO 0.55

// todo efeito passa por aqui, por causa do volume
function sfx(_som, _prioridade, _repete, _ganho = 1, _inicio = 0, _tom = 1) {
    return audio_play_sound(_som, _prioridade, _repete, _ganho * global.vol_efeitos, _inicio, _tom);
}

// _som = -1: so abaixa o que estava tocando
function musica(_som, _ms = 1000) {
    if (_som == global.musica_agora) {
        return;
    }
    if (global.musica_velha != -1) {
        audio_stop_sound(global.musica_velha);
    }
    global.musica_velha = global.musica_inst;
    if (global.musica_inst != -1) {
        audio_sound_gain(global.musica_inst, 0, _ms);
    }
    global.musica_agora = _som;
    global.musica_inst = -1;
    if (_som != -1) {
        global.musica_inst = audio_play_sound(_som, 2, true, 0);
        audio_sound_gain(global.musica_inst, global.vol_musica, _ms);
    }
}

function som_fundo(_som, _ms = 1500) {
    if (_som == global.fundo_agora) {
        return;
    }
    if (global.fundo_velho != -1) {
        audio_stop_sound(global.fundo_velho);
    }
    global.fundo_velho = global.fundo_inst;
    if (global.fundo_inst != -1) {
        audio_sound_gain(global.fundo_inst, 0, _ms);
    }
    global.fundo_agora = _som;
    global.fundo_inst = -1;
    if (_som != -1) {
        global.fundo_inst = audio_play_sound(_som, 1, true, 0);
        audio_sound_gain(global.fundo_inst, global.vol_efeitos * FUNDO_GANHO, _ms);
    }
}

// o volume mudou nas opcoes: vale para o que ja esta tocando
function volumes_aplicar() {
    if (global.musica_inst != -1) {
        audio_sound_gain(global.musica_inst, global.vol_musica, 0);
    }
    if (global.fundo_inst != -1) {
        audio_sound_gain(global.fundo_inst, global.vol_efeitos * FUNDO_GANHO, 0);
    }
}

// musica e fundo de cada sala: scr_mapa e scr_ambiente
function musica_da_sala() {
    var _fase = mapa_indice(room);
    return (_fase >= 0) ? global.mapa_fases[_fase].musica : snd_game_music;
}

// com a ultima vida, o coracao bate ate acabar a run ou curar
function coracao_atualizar(_ligado) {
    if (_ligado && global.coracao_inst == -1) {
        global.coracao_inst = sfx(snd_coracao, 3, true, 0.8);
    } else if (!_ligado && global.coracao_inst != -1) {
        audio_stop_sound(global.coracao_inst);
        global.coracao_inst = -1;
    }
}

// passo do jogador: depende do chao da sala. Contador, sem sorteio
function passo_som() {
    var _chao = (ambiente_da_sala() != undefined) ? ambiente_da_sala().chao : "pedra";
    global.passo_n += 1;
    var _qual = global.passo_n mod 3;
    var _som = snd_passo_pedra0;
    switch (_chao) {
        case "neve":
            _som = [snd_passo_neve0, snd_passo_neve1, snd_passo_neve2][_qual];
            break;
        case "terra":
            _som = [snd_passo_terra0, snd_passo_terra1, snd_passo_terra2][_qual];
            break;
        default:
            _som = [snd_passo_pedra0, snd_passo_pedra1, snd_passo_pedra2][_qual];
            break;
    }
    sfx(_som, 0, false, (_chao == "pedra") ? 0.22 : 0.3, 0, 1 + 0.05 * sin(global.passo_n * 2.4));
}
