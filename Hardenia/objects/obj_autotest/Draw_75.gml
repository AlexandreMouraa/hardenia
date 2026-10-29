// Draw GUI End: unico lugar onde o screen_save pega o quadro completo
if (print_pendente != "") {
    prints_feitos += 1;
    var _num = string_replace_all(string_format(prints_feitos, 3, 0), " ", "0");
    var _arquivo = pasta + _num + "_" + room_get_name(room) + "_" + print_pendente + ".png";
    screen_save(_arquivo);
    print_pendente = "";
}
