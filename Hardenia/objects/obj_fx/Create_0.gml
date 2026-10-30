// Efeito visual de curta duracao, desenhado em codigo. Quem cria escolhe:
//   "rastro": copia do sprite do jogador no dash, brilhante, sumindo
//   "risco":  linhas de velocidade do dash (ver fx_risco)
//   "anel" e "poeira": arrancada do dash (ver fx_dash_arrancada)
//   "arco":   arco de corte da espada, na direcao do golpe
//   "estocada": ponta do golpe que sai do dash
//   "faisca": linhas saindo do ponto de impacto (ver fx_faiscas)
tipo = "";
vida_max = 10;
vida = vida_max;
cor = c_white;
dir = 0;
raio = 34;
// arco: varre no sentido 1 (anti-horario) ou -1, "abertura" graus
sentido = 1;
abertura = 140;
espessura = 9;
intensidade = 1; // acima de 1: o arco demora mais para apagar
angulos = [];
distancias = [];
x2 = x;
y2 = y;
image_speed = 0;
