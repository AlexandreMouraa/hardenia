// onde o guerreiro ja caiu nesta sala, no chao. A mais nova e a mais forte: a morte e a historia
// do jogo, e olhar para o chao conta quantas tentativas custou chegar aqui
var _nome = room_get_name(room);
if (!variable_struct_exists(global.marcas_morte, _nome)) {
    exit;
}
var _lista = variable_struct_get(global.marcas_morte, _nome);
var _n = array_length(_lista);
for (var _i = 0; _i < _n; _i++) {
    var _idade = (_n - 1 - _i) / max(1, _n);
    draw_sprite_ext(spr_marca_morte, 0, _lista[_i][0], _lista[_i][1] + 18, 1, 1, 0, c_white, 0.75 - 0.5 * _idade);
}
