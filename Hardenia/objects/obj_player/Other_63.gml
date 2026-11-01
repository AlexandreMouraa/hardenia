// Async Dialog: o nome escrito no teclado do aparelho (obj_player, Step, tela de vitoria)
if (async_load[? "id"] != pedido_nome) {
    exit;
}
pedido_nome = -1;
if (async_load[? "status"]) {
    keyboard_string = nome_filtrado(async_load[? "result"]);
    vitoria_nome = keyboard_string;
    if (string_trim(vitoria_nome) != "") {
        enviar_nome();
    }
}
