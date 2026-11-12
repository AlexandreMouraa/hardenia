"""Gera a arte e a mascara das Ruinas, do Patio e do Cemiterio a partir de um so tracado, como
tools/gerar_tunel.py faz com as Catacumbas: o que e parede na imagem e parede na
colisao, sem conferir na mao.

    python3 tools/gerar_mapas.py PASTA_SAIDA PASTA_SPRITES ruinas|patio|cemiterio

PASTA_SPRITES e Hardenia/sprites: as cores e as pecas (portoes, braseiros, colunas,
estandartes, lapides, estatua) saem das fases pintadas: a Fase 1 do jogo, e o Patio e o
Cemiterio de tools/pinturas, que sairam do jogo quando os mapas novos entraram. Precisa de numpy, scipy e Pillow. A
semente e fixa: mesma saida sempre. Larguras: docs/ESPECIFICACAO_ARTE.md (corredor de
160 px ou mais; 96 a 128 so como desafio de dash; camara de 400 x 400 ou mais).

Alem da arte e da mascara, escreve uma previa com o tracado, os inimigos e a saida, e
imprime as luzes para scr_ambiente.
"""
import pathlib
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi
from scipy.spatial import cKDTree

P = 2  # cada pixel da arte gerada ocupa 2 da sala, como no tunel

# ---------- Ruinas: o primeiro mapa. Um caminho que vai abrindo, um inimigo de cada vez
# no comeco: entrada sem ninguem, 1 na primeira camara, 2 na segunda e a praca no fim, com
# o portao que desce para as Catacumbas. Atalho apertado da primeira camara direto para a
# praca, para quem ja sabe usar o dash.
RUINAS = {
    "estilo": "ruinas",
    "semente": 11,
    "tamanho": (2000, 1400),
    "pintura": "fase01",
    "camaras": [  # centro e raios
        (300, 370, 210, 150),    # entrada, com o portao fechado na parede de cima
        (640, 820, 230, 180),    # primeira camara
        (1250, 470, 260, 200),   # segunda camara
        (1580, 1050, 330, 230),  # praca
    ],
    "corredores": [  # largura, pontos
        (180, [(380, 420), (520, 580), (600, 680)]),
        (180, [(840, 780), (1020, 680), (1120, 580)]),
        (190, [(1400, 620), (1520, 780), (1580, 900)]),
        (116, [(840, 930), (1060, 1080), (1280, 1110)]),  # atalho apertado: desafio de dash
        (200, [(1640, 1050), (1640, 1400)]),              # portao para as Catacumbas
    ],
    # estrada de pedra pelo caminho principal: mostra para onde ir sem precisar de seta
    "estrada": [(300, 236), (300, 370), (380, 420), (520, 560), (600, 680), (640, 820), (840, 780), (1020, 680), (1120, 580), (1250, 470), (1400, 620), (1520, 780), (1580, 900), (1640, 1050), (1640, 1400)],
    # colunas quebradas no meio das camaras: peca e o pe dela, em pixels da sala
    "obstaculos": [("coluna1", 590, 910), ("coluna2", 1130, 420), ("coluna4", 1300, 640), ("coluna3", 1420, 980), ("coluna5", 1760, 980), ("coluna1", 1470, 1190)],
    # braseiros: x e a camara; ficam encostados na parede de cima dela
    "braseiros": [(170, 0), (430, 0), (450, 1), (740, 1), (1100, 2), (1400, 2), (1320, 3), (1860, 3)],
    "estandartes": [(640, 1), (1250, 2), (1580, 3)],
    "portao_cima": 300,
    "portao_baixo": 1640,
    "jogador": (300, 360),
    "saida": (1560, 1366),  # canto de cima e esquerda do obj_exit (spr_wall, 64 px, escala 2.5): centrado no portao
    # inimigos do arranjo original (o primeiro, que quem esta comecando sempre ve)
    "inimigos": [(660, 800), (1170, 540), (1330, 380), (1560, 1010), (1700, 1150)],
}

# ---------- Patio do Castelo: chega-se por cima, vindo das Catacumbas. O patio central (com a
# rosa dos ventos) e cercado de agua: para descer, atravessa-se uma das pontes, a oeste ou a
# leste, e a ala do outro lado leva ao patio da saida, de onde o portao segue para o Cemiterio.
PATIO = {
    "estilo": "patio",
    "semente": 23,
    "tamanho": (2000, 1600),
    "pintura": "fase02",
    "camaras": [
        (1000, 320, 300, 100),   # chegada, com o portao de volta para as Catacumbas
        (1000, 760, 400, 240),   # patio central
        (340, 900, 180, 290),    # ala oeste
        (1660, 900, 180, 290),   # ala leste
        (1000, 1220, 320, 120),  # patio da saida
    ],
    "corredores": [
        (110, [(1000, 330), (1000, 0)]),      # portao de volta: so o vao do arco
        (220, [(1000, 380), (1000, 560)]),    # escadaria para o patio central
        (170, [(640, 920), (480, 920)]),      # ponte oeste
        (170, [(1360, 920), (1520, 920)]),    # ponte leste
        (180, [(380, 1180), (560, 1330), (760, 1270)]),
        (180, [(1620, 1180), (1440, 1330), (1240, 1270)]),
        (110, [(1000, 1220), (1000, 1600)]),  # portao para o Cemiterio
    ],
    # agua (x0, y0, x1, y1): canais dos lados do patio central e o fosso entre ele e a saida
    "agua": [(500, 520, 620, 1180), (1380, 520, 1500, 1180), (600, 1000, 1400, 1100)],
    "pontes": [(470, 840, 650, 1000), (1350, 840, 1530, 1000)],
    # braseiros de pedestal no patio central: tem colisao
    "obstaculos": [("pedestal", 800, 700), ("pedestal", 1200, 700), ("pedestal", 800, 920), ("pedestal", 1200, 920),
                   ("pedestal", 300, 780), ("pedestal", 1700, 780)],
    "braseiros": [(860, 0), (1140, 0), (400, 2), (1600, 3)],
    "rosa": (1000, 820),
    "jogador": (1000, 300),
    "volta": (920, 30),
    "saida": (920, 1566),
    "inimigos": [(870, 780), (1130, 820), (360, 980), (1640, 980)],
}

# ---------- Cemiterio: chega-se por cima, vindo do Patio. O caminho desce em zigue-zague: o
# campo de lapides a oeste, a praca da estatua, o campo a leste e o patio da saida, com o
# portao para o Trono. Atalho apertado da praca direto para a saida; o lago congelado fecha o
# lado oeste da praca.
CEMITERIO = {
    "estilo": "cemiterio",
    "semente": 31,
    "tamanho": (2000, 1600),
    "pintura": "fase03",
    "camaras": [
        (1000, 300, 260, 100),   # chegada, com o portao de volta para o Patio
        (430, 450, 290, 200),    # campo de lapides a oeste
        (1000, 840, 300, 230),   # praca da estatua
        (1600, 780, 270, 220),   # campo de lapides a leste
        (1000, 1330, 260, 110),  # patio da saida
    ],
    "corredores": [
        (110, [(1000, 330), (1000, 0)]),   # portao de volta: so o vao do arco
        (180, [(860, 330), (620, 390)]),
        (180, [(560, 620), (720, 740), (800, 790)]),
        (180, [(1260, 820), (1400, 790)]),
        (190, [(1620, 970), (1560, 1180), (1300, 1320), (1150, 1330)]),
        (116, [(1000, 1060), (1000, 1250)]),  # atalho apertado: desafio de dash
        (110, [(1000, 1330), (1000, 1600)]),  # portao para o Trono
    ],
    "lagos": [(570, 1110, 290, 220), (370, 980, 150, 110)],  # lago congelado: elipses, com a beira ondulada
    # lapides em fileiras (passa um inimigo entre elas) e a estatua no meio da praca; na
    # estatua, so o corpo tem colisao: a base redonda e degrau, da para pisar
    "obstaculos": [("lapide1", 260, 420), ("lapide2", 400, 420), ("lapide3", 540, 420), ("cruz", 330, 580), ("lapide1", 470, 580),
                   ("lapide2", 1480, 740), ("lapide4", 1620, 740), ("lapide1", 1760, 740), ("lapide3", 1550, 900), ("cruz", 1660, 890),
                   ("estatua_centro", 1000, 880, (46, 0, 94, 96))],
    "braseiros": [(870, 0), (1130, 0), (430, 1), (1000, 2), (1600, 3)],
    "jogador": (1000, 300),
    "volta": (920, 30),
    "saida": (920, 1566),
    "inimigos": [(400, 500), (860, 800), (1610, 815), (1140, 800)],
}

MAPAS = {"ruinas": RUINAS, "patio": PATIO, "cemiterio": CEMITERIO}

# pecas recortadas da Fase 1 (x0, y0, x1, y1 na imagem de 960 x 640); entram na escala da arte
# gerada (cada pixel vira 2 da sala)
CAIXAS_FASE01 = {
    "coluna1": (383, 174, 416, 233), "coluna2": (294, 240, 333, 296), "coluna3": (681, 190, 727, 244),
    "coluna4": (624, 443, 663, 503), "coluna5": (198, 486, 228, 544),
    "entulho1": (158, 166, 204, 204), "entulho2": (573, 233, 622, 280), "entulho3": (288, 453, 334, 499),
    "estandarte1": (90, 498, 136, 574), "estandarte2": (838, 518, 884, 590),
    "arbusto": (198, 170, 240, 202), "arvore1": (116, 328, 154, 390), "arvore2": (826, 400, 874, 454),
    "caixas": (686, 100, 784, 148), "barris": (286, 556, 334, 594), "ossos1": (316, 522, 354, 548),
    "ossos2": (128, 432, 160, 458), "cerca": (182, 546, 288, 596), "portao_cima": (368, 0, 522, 112),
    "portao_baixo": (405, 512, 522, 622), "braseiro": (300, 86, 326, 126),
}
# pecas do Patio pintado (1536 x 1024, um pixel por pixel da sala): entram do tamanho que sao
CAIXAS_FASE02 = {
    "pedestal": (220, 165, 264, 254), "rosa": (660, 450, 834, 584),
    "portao_cima": (688, 78, 818, 292), "portao_baixo": (688, 812, 818, 1010),
}
# pecas do Cemiterio pintado (1536 x 1024), tambem do tamanho que sao. Lapides e estatua
# saem recortadas da neve; o resto fica inteiro
CAIXAS_FASE03 = {
    "lapide1": (1300, 752, 1340, 805), "lapide2": (1372, 705, 1412, 762), "lapide3": (1430, 688, 1464, 738),
    "lapide4": (1346, 512, 1384, 548), "cruz": (196, 238, 232, 302), "estatua_centro": (696, 428, 836, 562),
    "pedestal": (676, 140, 708, 222), "portao_cima": (696, 60, 836, 225), "portao_baixo": (690, 830, 840, 1000),
}
# chama de cada braseiro de pedestal, a partir do pe (x, y), em pixels da sala
CHAMA_PEDESTAL = (-2, -68)

RNG = np.random.default_rng(11)


def fbm(h, w, escalas=(64, 32, 16, 8, 4)):
    saida = np.zeros((h, w))
    peso = 1.0
    for e in escalas:
        saida += peso * ndi.gaussian_filter(RNG.standard_normal((h, w)), e, mode="reflect") * e
        peso *= 0.55
    saida -= saida.min()
    return saida / saida.max()


def rampa(v, cores):
    cores = np.asarray(cores, dtype=float)
    pos = np.clip(v, 0, 0.9999) * (len(cores) - 1)
    i = pos.astype(int)
    f = (pos - i)[..., None]
    return cores[i] * (1 - f) + cores[i + 1] * f


def cores_de_terra(pintura):
    """as cores do chao de terra da Fase 1, tiradas de dois trechos limpos: o que nao e
    terra num recorte e a peca"""
    amostra = np.concatenate([pintura[250:320, 480:640].reshape(-1, 3), pintura[120:160, 240:360].reshape(-1, 3)])
    sorteio = np.random.default_rng(1)
    c = amostra[sorteio.choice(len(amostra), 16, replace=False)]
    for _ in range(20):
        k = ((amostra[:, None] - c[None]) ** 2).sum(-1).argmin(1)
        c = np.array([amostra[k == i].mean(0) if (k == i).any() else c[i] for i in range(len(c))])
    cont = np.bincount(k, minlength=len(c))
    # sombra e pedra tambem aparecem no chao; terra e marrom: vermelho bem acima do azul
    return c[(cont > len(amostra) * 0.01) & (c[:, 0] - c[:, 2] >= 12) & (c.mean(1) >= 38)]


def cores_de_neve(pintura):
    """as cores da neve do Cemiterio pintado, do mesmo jeito: neve e azulada e clara"""
    amostra = np.concatenate([pintura[600:700, 900:1100].reshape(-1, 3), pintura[300:400, 400:600].reshape(-1, 3)]).astype(float)
    sorteio = np.random.default_rng(1)
    c = amostra[sorteio.choice(len(amostra), 16, replace=False)]
    for _ in range(20):
        k = ((amostra[:, None] - c[None]) ** 2).sum(-1).argmin(1)
        c = np.array([amostra[k == i].mean(0) if (k == i).any() else c[i] for i in range(len(c))])
    cont = np.bincount(k, minlength=len(c))
    return c[(cont > len(amostra) * 0.01) & (c[:, 2] - c[:, 0] >= 15) & (c.mean(1) >= 70)]


def recortar(pintura, caixa, terra, escuro=0):
    """escuro: abaixo desse brilho tambem e fundo (pecas que ficam encostadas no breu)"""
    x0, y0, x1, y1 = caixa
    p = pintura[y0:y1, x0:x1].astype(float)
    d = ((p[..., None, :] - terra[None, None]) ** 2).sum(-1).min(-1) ** 0.5
    solido = ndi.binary_opening((d > 13) & (p.mean(-1) >= escuro), iterations=1)
    solido = ndi.binary_fill_holes(ndi.binary_closing(solido, iterations=2))
    marcas, n = ndi.label(solido)
    if n:
        tam = ndi.sum(solido, marcas, range(1, n + 1))
        solido = np.isin(marcas, [i + 1 for i, t in enumerate(tam) if t >= 20])
    return np.dstack([p, solido * 255.0])


def inteira(pintura, caixa, borda=3):
    """a peca com o fundo que ela tem, so com a borda esmaecida (braseiro, portao, rosa)"""
    x0, y0, x1, y1 = caixa
    alfa = np.ones((y1 - y0, x1 - x0))
    for k in range(borda):
        t = (k + 1) / (borda + 1)
        alfa[k, :] = np.minimum(alfa[k, :], t)
        alfa[-1 - k, :] = np.minimum(alfa[-1 - k, :], t)
        alfa[:, k] = np.minimum(alfa[:, k], t)
        alfa[:, -1 - k] = np.minimum(alfa[:, -1 - k], t)
    return np.dstack([pintura[y0:y1, x0:x1].astype(float), alfa * 255])


def colar(arte, peca, cx, base):
    """peca com alfa (0 a 255), pelo meio de baixo"""
    h, w = peca.shape[:2]
    y0, x0 = int(base) - h, int(cx) - w // 2
    ya, xa = max(0, -y0), max(0, -x0)
    y1, x1 = min(y0 + h, arte.shape[0]), min(x0 + w, arte.shape[1])
    if y1 <= max(y0, 0) or x1 <= max(x0, 0):
        return
    alfa = peca[ya: ya + y1 - max(y0, 0), xa: xa + x1 - max(x0, 0), 3:4] / 255
    cor = peca[ya: ya + y1 - max(y0, 0), xa: xa + x1 - max(x0, 0), :3]
    trecho = arte[max(y0, 0):y1, max(x0, 0):x1]
    arte[max(y0, 0):y1, max(x0, 0):x1] = trecho * (1 - alfa) + cor * alfa


def caixa_obstaculo(peca, escala, x, y, caixa=None):
    """retangulo de colisao (pixels da sala) do que a peca desenha, pelo pe em x, y. Sobe uns
    pixels a mais: o boneco do jogador passa um pouco do proprio pe, e nao pode ficar por
    cima do desenho. caixa: so esse trecho da peca (x0, y0, x1, y1) tem colisao"""
    h, w = peca.shape[:2]
    x0 = x - w * escala / 2
    y0 = y - h * escala
    if caixa:
        return (x0 + caixa[0] * escala, y0 + caixa[1] * escala - 8, x0 + caixa[2] * escala, y0 + caixa[3] * escala + 2)
    ys, xs = np.nonzero(peca[..., 3] > 127)
    return (x0 + xs.min() * escala, y0 + ys.min() * escala - 8, x0 + (xs.max() + 1) * escala, y + 2)


def tracar(m, obstaculos):
    L, A = m["tamanho"]
    img = Image.new("L", (L, A), 0)
    d = ImageDraw.Draw(img)
    for cx, cy, rx, ry in m["camaras"]:
        d.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=255)
    for largura, pontos in m["corredores"]:
        d.line(pontos, fill=255, width=largura, joint="curve")
        for x, y in pontos:
            d.ellipse([x - largura / 2, y - largura / 2, x + largura / 2, y + largura / 2], fill=255)
    if m["estilo"] == "ruinas":
        # contorno de muro caido: ondula menos que a caverna, e sem dentes menores que 32 px
        aberto = ndi.gaussian_filter(np.asarray(img, dtype=float) / 255, 12) + (fbm(A // 4, L // 4, (16, 8)).repeat(4, 0).repeat(4, 1)[:A, :L] - 0.5) * 0.22
        aberto = ndi.gaussian_filter(aberto, 6) > 0.5
    else:
        # muralha de castelo: contorno liso
        aberto = ndi.gaussian_filter(np.asarray(img, dtype=float) / 255, 10) > 0.5
    agua = np.zeros((A, L), bool)
    if m.get("lagos"):
        img = Image.new("L", (L, A), 0)
        d = ImageDraw.Draw(img)
        for cx, cy, rx, ry in m["lagos"]:
            d.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=255)
        lago = ndi.gaussian_filter(np.asarray(img, dtype=float) / 255, 16) + (fbm(A // 4, L // 4, (12, 6)).repeat(4, 0).repeat(4, 1)[:A, :L] - 0.5) * 0.4
        agua = ndi.gaussian_filter(lago, 4) > 0.5
        aberto &= ~agua
    if m.get("agua"):
        img = Image.new("L", (L, A), 0)
        d = ImageDraw.Draw(img)
        for x0, y0, x1, y1 in m["agua"]:
            d.rounded_rectangle([x0, y0, x1, y1], 24, fill=255)
        agua = np.asarray(img) > 127
        img = Image.new("L", (L, A), 0)
        d = ImageDraw.Draw(img)
        for x0, y0, x1, y1 in m.get("pontes", []):
            d.rectangle([x0, y0, x1, y1], fill=255)
        ponte = np.asarray(img) > 127
        # o corredor passa por baixo da ponte; a agua corta o resto dele
        agua &= ~ponte
        aberto &= ~agua
    # obstaculos: retangulos de canto redondo, depois de alisar o resto
    img = Image.fromarray(np.where(aberto, 255, 0).astype(np.uint8))
    d = ImageDraw.Draw(img)
    for x0, y0, x1, y1 in obstaculos:
        d.rounded_rectangle([x0, y0, x1, y1], 14, fill=0)
    aberto = np.asarray(img) > 127
    aberto = aberto.copy()
    aberto[:24, :] = False
    aberto[:, :24] = False
    aberto[:, -24:] = False
    aberto[-20:, :] = False
    return aberto, agua & ~aberto


def parede_de_cima(chao, x, cy):
    """primeira linha de chao abaixo da parede, subindo de cy na coluna x (pixels da arte)"""
    y = cy
    while y > 0 and chao[y - 1, x]:
        y -= 1
    return y


def calcamento(h, w, n, cores, junta):
    """pedras irregulares (Voronoi) com a luz vindo de cima"""
    linhas = np.indices((h, w))[0]
    pontos = np.column_stack([RNG.random(n) * h, RNG.random(n) * w])
    dd, qual = cKDTree(pontos).query(np.indices((h, w)).reshape(2, -1).T, k=2)
    dd = dd.reshape(h, w, 2)
    qual = qual[:, 0].reshape(h, w)
    tom = RNG.random(n)[qual]
    pedra = rampa(0.2 + tom * 0.5, cores)
    pedra[(dd[..., 1] - dd[..., 0]) < 1.3] = junta
    borda_cima = ((pontos[qual, 0] - linhas) > 2.2) & ((dd[..., 1] - dd[..., 0]) < 2.4)
    pedra[borda_cima] = pedra[borda_cima] * 1.18
    return pedra


def desenhar_ruinas(m, chao):
    L, A = m["tamanho"]
    h, w = A // P, L // P
    parede = ~chao
    dist_chao = ndi.distance_transform_edt(chao)
    dist_parede = ndi.distance_transform_edt(parede)
    linhas, colunas = np.indices((h, w))

    # ----- chao: terra da Fase 1, com tufos de grama seca e pedrinhas
    ruido = fbm(h, w)
    fino = RNG.random((h, w))
    terra = rampa(ruido * 0.75 + fino * 0.25, [(36, 28, 24), (54, 42, 34), (68, 53, 42), (80, 64, 50), (96, 78, 58)])
    capim = (fbm(h, w, (10, 5)) > 0.62) & (fino > 0.82)
    terra[capim] = rampa(fino[capim], [(70, 66, 40), (92, 86, 50), (112, 104, 60)])
    pedras = fino > 0.993
    terra[pedras] = (118, 108, 104)
    terra[np.roll(pedras, 1, axis=0)] = (30, 24, 22)
    manchas = fbm(h, w, (24, 12, 6))
    sangue = manchas > 0.78
    terra[sangue] = terra[sangue] * 0.6 + np.array((86, 12, 16)) * 0.4
    musgo = (dist_chao < 10) & (fbm(h, w, (6, 3)) > 0.62)
    terra[musgo] = rampa(fino[musgo], [(70, 10, 24), (120, 16, 30), (160, 26, 44)])

    # ----- estrada de pedra, quebrada aos pedacos
    img = Image.new("L", (w, h), 0)
    ImageDraw.Draw(img).line([(x / P, y / P) for x, y in m["estrada"]], fill=255, width=34, joint="curve")
    estrada = ndi.gaussian_filter(np.asarray(img, dtype=float) / 255, 3) + (fbm(h, w, (8, 4)) - 0.5) * 1.1 > 0.6
    estrada &= chao & (dist_chao > 3)
    laje = calcamento(h, w, 16000, [(48, 42, 44), (62, 56, 58), (76, 70, 70), (90, 82, 80)], (34, 28, 28))
    terra[estrada] = laje[estrada]

    # ----- fora do caminho: mato escuro com folhagem vermelha, como em volta da Fase 1
    folha = fbm(h, w, (12, 6, 3))
    mato = rampa(np.clip(folha * 1.6 - 0.5, 0, 1), [(12, 8, 12), (22, 12, 18), (44, 12, 22), (90, 14, 30), (140, 24, 40)])
    mato[fino > 0.985] = (60, 50, 56)

    # ----- muro: blocos de pedra em volta do caminho (o topo do muro)
    bloco_l = (linhas // 7)
    deslocado = colunas + (bloco_l % 2) * 6
    junta = (linhas % 7 == 0) | (deslocado % 12 == 0)
    tom_bloco = RNG.random((h // 7 + 2, w // 12 + 3))[bloco_l, deslocado // 12]
    pedra = rampa(0.2 + tom_bloco * 0.55 + (fino - 0.5) * 0.15, [(34, 30, 38), (52, 48, 56), (70, 66, 74), (90, 86, 92)])
    pedra[junta] = (18, 16, 22)

    altura_face = 18
    face = parede & (ndi.maximum_filter1d(chao.astype(np.uint8), altura_face, axis=0, origin=-(altura_face // 2)) > 0)
    # o muro caiu em alguns trechos: ali so sobra entulho baixo, e o mato aparece atras
    caido = fbm(h, w, (20, 10)) > 0.66
    topo = parede & ~face & (ndi.distance_transform_edt(~(chao | face)) <= 9) & ~caido
    arte = np.where(parede[..., None], mato, terra)
    arte[topo] = pedra[topo]

    fiada = (linhas // 6) % 2
    tijolo = ((colunas + fiada * 8) % 16 == 0) | (linhas % 6 == 0)
    tons = rampa(np.clip(ndi.gaussian_filter(fino, 1.2) * 2.4 - 0.7, 0, 1), [(46, 42, 50), (64, 60, 68), (84, 80, 88)])
    ate_chao = ndi.distance_transform_edt(~chao)
    tons = tons * np.clip(ate_chao / 18 + 0.35, 0, 1)[..., None]
    arte[face] = tons[face]
    arte[face & tijolo] = (22, 20, 26)
    entulho = face & caido
    arte[entulho] = rampa(fino[entulho], [(30, 26, 32), (48, 44, 52), (66, 62, 70)])
    # sombra do muro no chao, logo abaixo da face
    sombra = chao & (ndi.maximum_filter1d(parede.astype(np.uint8), 9, axis=0, origin=4) > 0)
    arte[sombra] *= 0.6
    arte[chao] *= np.clip(0.62 + dist_chao[chao] / 40, 0, 1)[..., None]
    # breu no fundo do mato, longe do caminho
    arte[parede] *= np.clip(1.2 - dist_parede[parede] / 50, 0.4, 1)[..., None]
    return arte, dist_parede


# cores do Patio e do Cemiterio: o mesmo desenho de castelo, com o chao e a agua de cada um
PALETA_PATIO = {
    "chao": [(46, 34, 34), (60, 46, 44), (74, 58, 54), (90, 72, 66)], "junta": (26, 18, 20),
    "mancha": (90, 14, 18), "folhas": [(80, 12, 22), (128, 18, 30), (160, 30, 40)],
    "agua": [(10, 12, 20), (16, 20, 32), (24, 30, 46)], "marola": (44, 52, 70), "reflexo": (110, 20, 30),
    "beira": [(54, 48, 54), (72, 66, 72), (88, 82, 88)],
    "fundo": [(12, 8, 12), (22, 14, 20), (40, 14, 22), (80, 16, 28)],
    "topo": [(38, 30, 36), (56, 46, 52), (74, 64, 70), (94, 84, 88)], "junta_topo": (20, 14, 18),
    "face": [(48, 40, 46), (66, 56, 62), (86, 76, 82)], "rejunte": (22, 16, 20), "gelo": False,
}
PALETA_CEMITERIO = {
    "chao": [(66, 70, 98), (80, 86, 116), (96, 102, 132), (112, 118, 148)], "junta": (44, 46, 66),
    "mancha": (78, 62, 58), "folhas": [(126, 132, 160), (144, 150, 176), (162, 168, 192)],
    "agua": [(56, 72, 92), (70, 90, 112), (88, 108, 130)], "marola": (120, 140, 160), "reflexo": (110, 40, 60),
    "beira": [(120, 126, 152), (140, 146, 170), (160, 166, 188)],
    "fundo": [(10, 12, 22), (18, 22, 36), (30, 34, 52), (44, 50, 72)],
    "topo": [(104, 110, 138), (124, 130, 156), (144, 150, 174), (164, 170, 192)], "junta_topo": (70, 74, 98),
    "face": [(46, 46, 62), (62, 62, 80), (80, 80, 98)], "rejunte": (22, 22, 32), "gelo": True,
}


def desenhar_castelo(m, chao, agua, c):
    L, A = m["tamanho"]
    h, w = A // P, L // P
    seco = ~chao & ~agua  # muralha e o que fica atras dela
    dist_chao = ndi.distance_transform_edt(chao)
    dist_parede = ndi.distance_transform_edt(seco)
    linhas, colunas = np.indices((h, w))
    fino = RNG.random((h, w))

    # ----- chao: calcamento da fase pintada, com manchas e folhas (no Cemiterio, terra e neve)
    arte = calcamento(h, w, 15000, c["chao"], c["junta"])
    manchas = fbm(h, w, (24, 12, 6))
    sangue = (manchas > 0.74) & chao
    arte[sangue] = arte[sangue] * 0.6 + np.array(c["mancha"]) * 0.4
    folhas = (dist_chao < 12) & (fbm(h, w, (6, 3)) > 0.6) & (fino > 0.4)
    arte[folhas] = rampa(fino[folhas], c["folhas"])

    # ----- pontes de madeira: tabuas de norte a sul, guarda-corpo nas bordas
    for x0, y0, x1, y1 in m.get("pontes", []):
        a0, b0, a1, b1 = x0 // P, y0 // P, x1 // P, y1 // P
        trecho = (slice(b0, b1), slice(a0, a1))
        madeira = rampa(ndi.gaussian_filter(fino[trecho], (0.5, 3)) * 1.6 - 0.3, [(58, 40, 28), (78, 56, 38), (98, 72, 48)])
        madeira[:, (np.arange(a1 - a0) % 6) == 0] = (34, 22, 16)
        madeira[:3] = madeira[-3:] = (40, 26, 18)
        madeira[:3, (np.arange(a1 - a0) % 14) < 3] = (24, 16, 12)
        madeira[-3:, (np.arange(a1 - a0) % 14) < 3] = (24, 16, 12)
        arte[trecho] = madeira

    # ----- agua parada: escura, com marolas claras e o reflexo vermelho da lua
    onda = np.sin(colunas / 5.0 + fbm(h, w, (12, 6)) * 9) * np.sin(linhas / 2.0)
    agua_cor = rampa(fbm(h, w, (16, 8)) * 0.8 + 0.1, c["agua"])
    agua_cor[(onda > 0.93) & (fino > 0.3)] = c["marola"]
    reflexo = fbm(h, w, (20, 10)) > 0.7
    agua_cor[reflexo] = agua_cor[reflexo] * 0.6 + np.array(c["reflexo"]) * 0.4
    if c["gelo"]:
        # lago congelado: rachaduras escuras e neve juntando na beira
        pontos = np.column_stack([RNG.random(700) * h, RNG.random(700) * w])
        dd, _ = cKDTree(pontos).query(np.indices((h, w)).reshape(2, -1).T, k=2)
        dd = dd.reshape(h, w, 2)
        agua_cor[(dd[..., 1] - dd[..., 0]) < 0.9] = (40, 52, 70)
        neve = ndi.distance_transform_edt(agua) < 5 + fbm(h, w, (6, 3)) * 6
        agua_cor[neve] = rampa(fino[neve], c["beira"])
    arte[agua] = agua_cor[agua]
    # beira de pedra onde a agua encontra o chao
    beira = agua & (ndi.distance_transform_edt(agua) <= 3) & ndi.binary_dilation(chao, iterations=3)
    arte[beira] = rampa(fino[beira], c["beira"])

    # ----- muralha: o que fica atras dela, topo de blocos e face de tijolo
    folha = fbm(h, w, (12, 6, 3))
    fundo = rampa(np.clip(folha * 1.5 - 0.45, 0, 1), c["fundo"])
    if c["gelo"]:
        # floresta de pinheiros com neve atras do muro: pontinhos claros
        fundo[fino > 0.975] = (110, 116, 140)
    arte[seco] = fundo[seco]
    bloco_l = (linhas // 7)
    deslocado = colunas + (bloco_l % 2) * 6
    junta = (linhas % 7 == 0) | (deslocado % 12 == 0)
    tom_bloco = RNG.random((h // 7 + 2, w // 12 + 3))[bloco_l, deslocado // 12]
    pedra = rampa(0.2 + tom_bloco * 0.55 + (fino - 0.5) * 0.15, c["topo"])
    pedra[junta] = c["junta_topo"]
    altura_face = 20
    face = seco & (ndi.maximum_filter1d(chao.astype(np.uint8), altura_face, axis=0, origin=-(altura_face // 2)) > 0)
    topo = seco & ~face & (ndi.distance_transform_edt(~(chao | face | agua)) <= 10)
    arte[topo] = pedra[topo]
    # ameias no topo que fica de frente: um dente a cada 14 pixels
    ameia = topo & (ndi.maximum_filter1d(face.astype(np.uint8), 12, axis=0, origin=-6) > 0) & ((colunas % 14) < 5)
    arte[ameia] = arte[ameia] * 0.45
    fiada = (linhas // 6) % 2
    tijolo = ((colunas + fiada * 8) % 16 == 0) | (linhas % 6 == 0)
    tons = rampa(np.clip(ndi.gaussian_filter(fino, 1.2) * 2.4 - 0.7, 0, 1), c["face"])
    ate_chao = ndi.distance_transform_edt(~chao)
    tons = tons * np.clip(ate_chao / 20 + 0.35, 0, 1)[..., None]
    arte[face] = tons[face]
    arte[face & tijolo] = c["rejunte"]
    sombra = chao & (ndi.maximum_filter1d(seco.astype(np.uint8), 9, axis=0, origin=4) > 0)
    arte[sombra] *= 0.6
    arte[chao] *= np.clip(0.66 + dist_chao[chao] / 40, 0, 1)[..., None]
    arte[seco] *= np.clip(1.2 - dist_parede[seco] / 50, 0.4, 1)[..., None]
    return arte, dist_parede


def enfeitar_ruinas(m, arte, chao, dist_parede, pecas):
    """pecas da Fase 1. No chao, so o que da para atravessar (ossos); o que parece solido
    fica no mato, fora do caminho, ou e obstaculo com colisao"""
    L, A = m["tamanho"]
    h, w = A // P, L // P
    sorteio = np.random.default_rng(5)
    # arvores secas, caixas e entulho no mato, perto do muro
    longe = (dist_parede > 22) & (dist_parede < 60)
    candidatos = np.argwhere(longe[::9, ::9]) * 9
    sorteio.shuffle(candidatos)
    usados = []
    tipos = ["arvore1", "arvore2", "arvore1", "entulho1", "arvore2", "caixas", "barris", "entulho2", "arbusto", "cerca", "entulho3"]
    k = 0
    for y, x in candidatos:
        if all((y - uy) ** 2 + (x - ux) ** 2 > 70 ** 2 for uy, ux in usados):
            peca = pecas[tipos[k % len(tipos)]]
            # a peca inteira no mato: nada dela pode cair no caminho
            ph, pw = peca.shape[:2]
            y0, x0 = y - ph, x - pw // 2
            if y0 < 0 or x0 < 0 or x0 + pw > w or y > h:
                continue
            if chao[max(0, y0 - 6): y + 6, max(0, x0 - 6): x0 + pw + 6].any():
                continue
            colar(arte, peca, x, y)
            usados.append((y, x))
            k += 1
    # ossos no chao: poucos e espalhados
    lugares = np.argwhere(ndi.binary_erosion(chao, iterations=14))
    sorteio.shuffle(lugares)
    postos = []
    for y, x in lugares:
        if len(postos) >= 14:
            break
        if all((y - py) ** 2 + (x - px) ** 2 > 110 ** 2 for py, px in postos):
            colar(arte, pecas["ossos1" if len(postos) % 2 else "ossos2"], x, y)
            postos.append((y, x))
    for nome, x, y in m["obstaculos"]:
        colar(arte, pecas[nome], x / P, y / P)
    # estandartes na face do muro, em cima das camaras
    for i, (x, c) in enumerate(m["estandartes"]):
        cx, cy = x // P, m["camaras"][c][1] // P
        topo = parede_de_cima(chao, cx, cy)
        colar(arte, pecas["estandarte1" if i % 2 else "estandarte2"], cx, topo + 4)
    # o portao por onde ele chegou: fechado, na parede de cima da entrada
    cx = m["portao_cima"] // P
    colar(arte, pecas["portao_cima"], cx, parede_de_cima(chao, cx, m["camaras"][0][1] // P) + 6)
    colar(arte, pecas["portao_baixo"], m["portao_baixo"] // P, h)


def pes_dos_braseiros(m, chao, obstaculos, recuo):
    """pe de cada braseiro de parede, em pixels da arte, encostado na parede de cima da camara.
    Os obstaculos nao contam como parede aqui"""
    livre = chao.copy()
    for x0, y0, x1, y1 in obstaculos:
        livre[int(y0 // P) - 4: int(y1 // P) + 4, int(x0 // P) - 4: int(x1 // P) + 4] = True
    saida = []
    for x, c in m["braseiros"]:
        cx, cy = x // P, m["camaras"][c][1] // P
        saida.append((cx, parede_de_cima(livre, cx, cy) + recuo))
    return saida


def brilho(arte, chamas):
    """luz quente em volta das chamas (pixels da arte); a leitura do combate nao pode depender disso"""
    h, w = arte.shape[:2]
    linhas, colunas = np.indices((h, w))
    luz = np.zeros((h, w))
    for bx, by in chamas:
        g = np.hypot(linhas - by, colunas - bx)
        luz = np.maximum(luz, np.clip(1 - g / 140, 0, 1) ** 1.6)
    arte = arte * (0.85 + 0.4 * luz)[..., None]
    arte[..., 0] += 24 * luz
    arte[..., 1] += 9 * luz
    return arte


def nas_cores(arte, pintura):
    """nas cores da fase pintada: e o que faz o mapa parecer do mesmo jogo"""
    paleta = Image.fromarray(pintura).quantize(colors=96, method=Image.MEDIANCUT)
    return np.asarray(Image.fromarray(np.clip(arte, 0, 255).astype(np.uint8)).quantize(palette=paleta, dither=Image.NONE).convert("RGB")).astype(float)


def principal():
    global RNG
    saida = pathlib.Path(sys.argv[1])
    saida.mkdir(parents=True, exist_ok=True)
    sprites = pathlib.Path(sys.argv[2])
    nome = sys.argv[3] if len(sys.argv) > 3 else "ruinas"
    m = MAPAS[nome]
    RNG = np.random.default_rng(m["semente"])
    L, A = m["tamanho"]
    h, w = A // P, L // P

    def pintura_de(fase):
        # a Fase 1 continua no jogo (fundo da Horda); as outras pinturas ficam em tools/pinturas
        pasta = sprites / ("spr_bg_" + fase)
        arquivo = sorted(pasta.glob("*.png"))[0] if pasta.exists() else pathlib.Path(__file__).parent / "pinturas" / (fase + ".png")
        return np.asarray(Image.open(arquivo).convert("RGB"))

    pintura = pintura_de(m["pintura"])
    fase01 = pintura_de("fase01")
    terra = cores_de_terra(fase01)
    # pecas que ficam no breu: o escuro em volta tambem e fundo (as arvores sao escuras, menos)
    no_breu = {"estandarte1": 26, "estandarte2": 26, "arvore1": 12, "arvore2": 12, "caixas": 16, "barris": 16, "cerca": 16,
               "entulho1": 20, "entulho2": 20, "entulho3": 20, "arbusto": 20}
    pecas = {k: recortar(fase01, c, terra, no_breu.get(k, 0)) for k, c in CAIXAS_FASE01.items()}
    # o braseiro fica inteiro, com a borda esmaecida, como no tunel: a terra acesa em volta
    # dele e parte do desenho
    pecas["braseiro"] = inteira(fase01, CAIXAS_FASE01["braseiro"])
    if m["estilo"] == "patio":
        pecas.update({k: inteira(pintura, c, 4) for k, c in CAIXAS_FASE02.items()})
        pecas["rosa"] = inteira(pintura, CAIXAS_FASE02["rosa"], 14)
    if m["estilo"] == "cemiterio":
        neve = cores_de_neve(pintura)
        pecas.update({k: inteira(pintura, c, 4) for k, c in CAIXAS_FASE03.items()})
        for k in ("lapide1", "lapide2", "lapide3", "lapide4", "cruz", "estatua_centro"):
            pecas[k] = recortar(pintura, CAIXAS_FASE03[k], neve)
        # a estatua: so o pedaco grande, sem os pontinhos que sobram da neve em volta
        alfa = pecas["estatua_centro"][..., 3] > 127
        marcas, n = ndi.label(alfa)
        maior = np.argmax(ndi.sum(alfa, marcas, range(1, n + 1))) + 1
        pecas["estatua_centro"][..., 3] = np.where(marcas == maior, 255, 0)
    escala = P if m["estilo"] == "ruinas" else 1
    obstaculos = [caixa_obstaculo(pecas[o[0]], escala, o[1], o[2], o[3] if len(o) > 3 else None) for o in m["obstaculos"]]

    aberto, agua = tracar(m, obstaculos)
    chao = np.asarray(Image.fromarray(aberto).resize((w, h), Image.NEAREST))
    agua_a = np.asarray(Image.fromarray(agua).resize((w, h), Image.NEAREST)) & ~chao

    if m["estilo"] == "ruinas":
        arte, dist_parede = desenhar_ruinas(m, chao)
        enfeitar_ruinas(m, arte, chao, dist_parede, pecas)
        pes = pes_dos_braseiros(m, chao, obstaculos, 16)
        chamas = [(bx, by - 12) for bx, by in pes]
        arte = nas_cores(brilho(arte, chamas), pintura)
        # o braseiro entra depois de reduzir as cores: a chama laranja e pouca e sumiria
        for bx, by in pes:
            colar(arte, pecas["braseiro"], bx, by)
        final = np.asarray(Image.fromarray(np.clip(arte, 0, 255).astype(np.uint8)).resize((L, A), Image.NEAREST)).astype(float)
        luzes = [(bx * P - 1, by * P) for bx, by in chamas]
    else:
        arte, dist_parede = desenhar_castelo(m, chao, agua_a, PALETA_PATIO if m["estilo"] == "patio" else PALETA_CEMITERIO)
        pes = pes_dos_braseiros(m, chao, obstaculos, 6)
        pedestais = [(o[1], o[2]) for o in m["obstaculos"] if o[0] == "pedestal"]
        # chamas em pixels da sala: braseiros de parede e de pedestal sao a mesma peca
        luzes = [(bx * P + CHAMA_PEDESTAL[0], by * P + CHAMA_PEDESTAL[1]) for bx, by in pes]
        luzes += [(x + CHAMA_PEDESTAL[0], y + CHAMA_PEDESTAL[1]) for x, y in pedestais]
        arte = nas_cores(brilho(arte, [(x / P, y / P) for x, y in luzes]), pintura)
        # as pecas da fase pintada entram do tamanho original, depois de ampliar a arte
        final = np.asarray(Image.fromarray(np.clip(arte, 0, 255).astype(np.uint8)).resize((L, A), Image.NEAREST)).astype(float)
        if "rosa" in m:
            rx, ry = m["rosa"]
            colar(final, pecas["rosa"], rx, ry + pecas["rosa"].shape[0] // 2)
        for bx, by in pes:
            colar(final, pecas["pedestal"], bx * P, by * P)
        for o in m["obstaculos"]:
            colar(final, pecas[o[0]], o[1], o[2])
        colar(final, pecas["portao_cima"], m["volta"][0] + 80, pecas["portao_cima"].shape[0] + 10)
        colar(final, pecas["portao_baixo"], m["saida"][0] + 80, A)

    imagem = Image.fromarray(np.clip(final, 0, 255).astype(np.uint8))
    imagem.convert("RGBA").save(saida / (nome + ".png"), optimize=True)
    Image.fromarray(np.where(aberto, 255, 0).astype(np.uint8)).convert("RGBA").save(saida / ("mascara_" + nome + ".png"), optimize=True)

    # previa para aprovar: contorno da colisao, jogador, inimigos e saida
    previa_np = np.asarray(imagem.resize((L // 2, A // 2), Image.NEAREST).convert("RGB")).copy()
    contorno = aberto ^ ndi.binary_erosion(aberto, iterations=3)
    previa_np[contorno[::2, ::2]] = (0, 230, 255)
    previa = Image.fromarray(previa_np)
    d = ImageDraw.Draw(previa)
    jx, jy = m["jogador"]
    d.ellipse([jx / 2 - 8, jy / 2 - 8, jx / 2 + 8, jy / 2 + 8], outline=(80, 255, 80), width=3)
    for x, y in m["inimigos"]:
        d.ellipse([x / 2 - 8, y / 2 - 8, x / 2 + 8, y / 2 + 8], outline=(255, 60, 60), width=3)
    sx, sy = m["saida"]
    d.rectangle([sx / 2, sy / 2, sx / 2 + 80, sy / 2 + 16], outline=(255, 220, 0), width=3)
    previa.save(saida / ("previa_" + nome + ".png"))

    print("luzes (scr_ambiente): " + ", ".join("[%d, %d]" % l for l in luzes))
    dist = ndi.distance_transform_edt(aberto)
    print("area aberta: %.0f%%; maior raio livre: %.0f px" % (100 * aberto.mean(), dist.max()))
    for nome_c, mx, my in (("jogador", 14, 19), ("inimigo", 26, 32)):
        cabe = ndi.minimum_filter(aberto, size=(2 * my + 1, 2 * mx + 1))
        marcas, total = ndi.label(cabe)
        tamanhos = ndi.sum(cabe, marcas, range(1, total + 1))
        print("%s: %d pedaco(s) ligado(s), o maior com %.1f%% da area" % (nome_c, total, 100 * max(tamanhos) / cabe.sum()))
        for x, y in [m["jogador"]] + m["inimigos"]:
            if not cabe[y, x]:
                print("  ATENCAO: %s nao cabe em (%d, %d)" % (nome_c, x, y))


if __name__ == "__main__":
    principal()
