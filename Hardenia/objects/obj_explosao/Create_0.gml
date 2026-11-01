// explosao da elite: objeto proprio porque dura depois da morte de quem explodiu (o
// golpe comum some com o dono). Mesma zona dos outros ataques: o que aparece e o que acerta
zona = zona_criar({ forma: "circulo", alcance: 0, tamanho: 90 }, x, y, 0);
causa = "obj_explosao"; // quem aparece na frase de morte (o chefe usa este objeto na magia)
estado = 1; // 1 = aviso, 2 = explodindo. Mesmos numeros do inimigo: o robo le igual
aviso = 55;
tempo = aviso;
duracao = 16;
acerto = 8;
image_speed = 0;
