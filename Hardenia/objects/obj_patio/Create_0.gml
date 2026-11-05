depth = 90; // acima do fundo antigo e abaixo da luz, dos avisos e dos personagens
chao = -1;
// Primeiro barril perto da entrada, longe do primeiro grupo: experimentar sem ser cercado.
var _barris = [[840, 500], [380, 280], [1140, 750], [760, 690]];
for (var _i = 0; _i < array_length(_barris); _i++) {
    instance_create_layer(_barris[_i][0], _barris[_i][1], "Instances", obj_perigo_patio);
}
var _armadilhas = [[640, 360], [896, 664]];
for (var _j = 0; _j < array_length(_armadilhas); _j++) {
    with (instance_create_layer(_armadilhas[_j][0], _armadilhas[_j][1], "Instances", obj_perigo_patio)) {
        tipo = "armadilha";
        raio = 38;
        dano = 2; // metade do barril, compensada pelo rearmamento
        zona = zona_criar({forma: "circulo", alcance: 0, tamanho: raio}, x, y, 0);
    }
}
