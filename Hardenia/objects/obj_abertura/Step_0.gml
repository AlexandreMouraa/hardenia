tempo += 1;
var _pular = tempo > pode_pular && !instance_exists(obj_autotest) && aperto_de_passar();
// o robo espera menos: o que ele confere aqui e se a abertura termina
var _tempo_carta = instance_exists(obj_autotest) ? 40 : por_carta;
if (tempo >= _tempo_carta || _pular) {
    tempo = 0;
    carta += 1;
    if (carta >= array_length(global.abertura) && !fim) {
        fim = true;
        with (obj_menu) {
            comecar_run();
        }
        instance_destroy();
    }
}
