// So controla os perigos e as dicas; o cenario e a colisao continuam os originais.
depth = 90;
// Barris e armadilhas desligados por enquanto (decisao do Alexandre, 06/11): o Patio vai ser refeito
// com caminhos na 0.10 (issue #91), e estas posicoes so servem no Patio antigo. Para religar, volte
// com perigos_ligados = true e reposicione no mapa novo.
var perigos_ligados = false;
if (!perigos_ligados) exit;
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
