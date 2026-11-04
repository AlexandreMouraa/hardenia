// no navegador nao ha janela para fechar
if (os_browser == browser_not_a_browser && !instance_exists(obj_mapa) && !instance_exists(obj_abertura) && !instance_exists(obj_opcoes)) {
    game_end();
}
