tipo = "barril";
estado = 0; // 0: pronto, 1: aviso, 2: golpe, 3: recarga ou restos
tempo = 0;
// Um segundo de aviso permite sair a pe do raio de 112 px, mesmo sem dash.
aviso = 60;
raio = 112;
dano = 4; // um combo completo; ajuda contra os inimigos mais duros da terceira fase
zona = zona_criar({forma: "circulo", alcance: 0, tamanho: raio}, x, y, 0);
depth = -5;
