// Voz dos inimigos (#96). Cada tipo tem tres sons: ao notar o jogador (junto do "!"), antes do
// golpe (junto do aviso) e ao morrer. O som avisa o perigo antes de o jogador ver, e cada inimigo
// fica com a sua cara. A tabela fica aqui, e nao no Create de cada um, para um tipo novo ganhar
// voz numa linha so. Os arquivos saem de tools/gerar_sons_vozes.py.
//
// A chave e o nome do objeto; o Caido usa "caido_" + a chave dele (scr_duelos).
//   notar, aviso, morte  o som de cada momento. noone = calado naquele momento: o arqueiro ja
//                        avisa com o arco, a horda nao tem aviso, o curandeiro nao ataca
//   tom    o mesmo arquivo mais grave ou mais agudo: parentes soam parecidos sem arquivo novo
//          (o arqueiro e um esqueleto menor; cada Caido tem o seu, do mais pesado ao mais leve)
//   ganho  volume, de 0 a 1. Valores de partida: ninguem ouviu ainda com o jogo rodando
global.vozes = {
    obj_enemy:            { notar: snd_voz_esqueleto_notar,  aviso: snd_voz_esqueleto_aviso,  morte: snd_voz_esqueleto_morte,  tom: 1,    ganho: 0.8 },
    obj_enemy_arqueiro:   { notar: snd_voz_esqueleto_notar,  aviso: noone,                    morte: snd_voz_esqueleto_morte,  tom: 1.22, ganho: 0.7 },
    obj_enemy_ghoul:      { notar: snd_voz_ghoul_notar,      aviso: snd_voz_ghoul_aviso,      morte: snd_voz_ghoul_morte,      tom: 1,    ganho: 0.8 },
    obj_enemy_wight:      { notar: snd_voz_wight_notar,      aviso: snd_voz_wight_aviso,      morte: snd_voz_wight_morte,      tom: 1,    ganho: 0.85 },
    obj_enemy_defensor:   { notar: snd_voz_wight_notar,      aviso: snd_voz_wight_aviso,      morte: snd_voz_wight_morte,      tom: 1.12, ganho: 0.8 },
    obj_enemy_conjurador: { notar: snd_voz_conjurador_notar, aviso: snd_voz_conjurador_aviso, morte: snd_voz_conjurador_morte, tom: 1,    ganho: 0.9 },
    obj_enemy_curandeiro: { notar: snd_voz_conjurador_notar, aviso: noone,                    morte: snd_voz_conjurador_morte, tom: 1.18, ganho: 0.8 },
    obj_enemy_horda:      { notar: snd_voz_horda_notar,      aviso: noone,                    morte: snd_voz_horda_morte,      tom: 1,    ganho: 0.6 },
    obj_enemy_chefe:      { notar: snd_voz_rei_notar,        aviso: snd_voz_rei_aviso,        morte: snd_voz_rei_morte,        tom: 1,    ganho: 1 },
    caido_carrasco:       { notar: snd_voz_caido_notar,      aviso: snd_voz_caido_aviso,      morte: snd_voz_caido_morte,      tom: 0.84, ganho: 0.9 },
    caido_sentinela:      { notar: snd_voz_caido_notar,      aviso: snd_voz_caido_aviso,      morte: snd_voz_caido_morte,      tom: 0.94, ganho: 0.9 },
    caido_sapador:        { notar: snd_voz_caido_notar,      aviso: snd_voz_caido_aviso,      morte: snd_voz_caido_morte,      tom: 1.06, ganho: 0.9 },
    caido_batedor:        { notar: snd_voz_caido_notar,      aviso: snd_voz_caido_aviso,      morte: snd_voz_caido_morte,      tom: 1.2,  ganho: 0.9 },
};

// tempo minimo, em ms, entre duas falas iguais do mesmo tipo. Um grupo que acorda junto fala uma
// vez so, e no navegador cada som pesa. A horda nasce e morre as dezenas: o intervalo maior e o
// teto de sons dela ao mesmo tempo. current_time e do relogio, nao entra na conta do jogo
#macro VOZ_INTERVALO 90
#macro VOZ_INTERVALO_HORDA 160
global.voz_ultima = {};
global.voz_contador = 0;

// _chave: da tabela. _momento: "notar", "aviso" ou "morte"
function voz_tocar_chave(_chave, _momento, _intervalo = VOZ_INTERVALO) {
    if (!variable_struct_exists(global.vozes, _chave)) {
        return;
    }
    var _voz = variable_struct_get(global.vozes, _chave);
    var _som = variable_struct_get(_voz, _momento);
    if (_som == noone) {
        return;
    }
    // por tipo e momento: esqueleto e arqueiro dividem o arquivo, mas cada um fala
    var _marca = _chave + "/" + _momento;
    if (variable_struct_exists(global.voz_ultima, _marca) && current_time - variable_struct_get(global.voz_ultima, _marca) < _intervalo) {
        return;
    }
    variable_struct_set(global.voz_ultima, _marca, current_time);
    // o tom balanca um pouco a cada fala, por contador: sem random, o robo depende do RNG do jogo
    global.voz_contador += 1;
    sfx(_som, 1, false, _voz.ganho, 0, _voz.tom * (1 + 0.04 * sin(global.voz_contador * 2.4)));
}

// a fala de um inimigo vivo (ou morrendo)
function voz_tocar(_inimigo, _momento) {
    var _chave = (_inimigo.object_index == obj_enemy_caido) ? "caido_" + _inimigo.caido : object_get_name(_inimigo.object_index);
    voz_tocar_chave(_chave, _momento, _inimigo.leve ? VOZ_INTERVALO_HORDA : VOZ_INTERVALO);
}
