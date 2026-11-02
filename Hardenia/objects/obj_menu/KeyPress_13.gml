// Enter de novo com o mapa, a abertura ou outra tela aberta: quem pula sao eles
if (instance_exists(obj_mapa) || instance_exists(obj_abertura) || instance_exists(obj_opcoes)) {
    exit;
}
// Enter em outro item do menu faz o que aquele item faz
if (cursor != 0 && !instance_exists(obj_autotest)) {
    acionar(itens[cursor].acao);
    exit;
}
comecar();
