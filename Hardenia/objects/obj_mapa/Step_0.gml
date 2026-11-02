tempo += 1;
var _pular = tempo > pode_pular && aperto_de_passar();
if (!saindo && (tempo >= duracao || _pular)) {
    saindo = true;
    room_goto(destino);
}
