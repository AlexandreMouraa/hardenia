"""Gera a arte e a mascara dos mapas de tunel e do salao do Trono a partir de um so
tracado: as camaras e os corredores abaixo. O que e parede na imagem e parede na colisao,
sem conferir na mao.

    python3 tools/gerar_tunel.py PASTA_SAIDA IMAGEM_FASE01 [tunel|trono]

Cores e pecas (portao, braseiro) vem da arte da Fase 1, para o mapa combinar com o
resto do jogo. Precisa de numpy, scipy e Pillow. A semente e fixa: mesma saida sempre.
Larguras: docs/ESPECIFICACAO_ARTE.md (corredor de 160 px ou mais; 96 a 128 so como
desafio de dash; camara de 400 x 400 ou mais).
"""
import pathlib
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi
from scipy.spatial import cKDTree

L, A = 2000, 1400  # tamanho da sala
P = 2  # cada pixel da arte ocupa 2 da sala, como a arte das outras fases
RNG = np.random.default_rng(7)

CAMARAS = [  # centro e raios
    (240, 1120, 175, 150),   # entrada
    (470, 320, 225, 190),    # noroeste
    (1010, 700, 245, 210),   # centro
    (1670, 300, 225, 190),   # nordeste
    (1640, 1120, 225, 170),  # saida
]
CORREDORES = [  # largura, pontos
    (170, [(240, 1120), (190, 800), (300, 500)]),
    (170, [(620, 430), (790, 560), (880, 620)]),
    (170, [(1200, 600), (1380, 420), (1500, 330)]),
    (170, [(1730, 470), (1810, 760), (1730, 980)]),
    (170, [(390, 1180), (700, 1170), (880, 980), (930, 880)]),
    (116, [(1200, 830), (1380, 1010), (1480, 1090)]),  # atalho apertado: desafio de dash
    (190, [(240, 1120), (240, 1400)]),                 # portao de volta
    (190, [(1640, 1120), (1640, 1400)]),               # portao adiante
]
BRASEIROS = [(110, 1040), (370, 1040), (310, 190), (630, 190), (850, 530), (1170, 530), (1520, 170), (1820, 170), (1450, 1030), (1830, 1030)]


COLUNAS = [(430, 420), (1106, 420), (430, 720), (1106, 720)]
BRASEIROS_TRONO = [(250, 300), (1286, 300), (250, 830), (1286, 830), (600, 300), (936, 300)]


def fbm(h, w, escalas=(64, 32, 16, 8, 4)):
    saida = np.zeros((h, w))
    peso = 1.0
    for e in escalas:
        saida += peso * ndi.gaussian_filter(RNG.standard_normal((h, w)), e, mode="reflect") * e
        peso *= 0.55
    saida -= saida.min()
    return saida / saida.max()


def tracar_trono():
    """salao retangular, com 4 colunas: a investida do chefe para nelas"""
    img = Image.new("L", (L, A), 0)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([150, 220, L - 150, 900], 40, fill=255)
    d.rectangle([768 - 80, 880, 768 + 80, A], fill=255)
    for cx, cy in COLUNAS:
        d.ellipse([cx - 50, cy - 50, cx + 50, cy + 50], fill=0)
    aberto = np.asarray(img) > 127
    aberto = aberto.copy()
    aberto[-20:, :] = False
    return aberto


def tracar():
    img = Image.new("L", (L, A), 0)
    d = ImageDraw.Draw(img)
    for cx, cy, rx, ry in CAMARAS:
        d.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=255)
    for largura, pontos in CORREDORES:
        d.line(pontos, fill=255, width=largura, joint="curve")
        for x, y in pontos:
            d.ellipse([x - largura / 2, y - largura / 2, x + largura / 2, y + largura / 2], fill=255)
    # contorno de caverna: ondula e alisa, sem dentes menores que 32 px
    aberto = ndi.gaussian_filter(np.asarray(img, dtype=float) / 255, 14) + (fbm(A // 4, L // 4, (16, 8)).repeat(4, 0).repeat(4, 1)[:A, :L] - 0.5) * 0.35
    aberto = ndi.gaussian_filter(aberto, 6) > 0.5
    # borda da sala fechada; a parede de baixo so abre nos portoes
    aberto[:24, :] = False
    aberto[:, :24] = False
    aberto[:, -24:] = False
    aberto[-20:, :] = False
    return aberto


def rampa(v, cores):
    cores = np.asarray(cores, dtype=float)
    pos = np.clip(v, 0, 0.9999) * (len(cores) - 1)
    i = pos.astype(int)
    f = (pos - i)[..., None]
    return cores[i] * (1 - f) + cores[i + 1] * f


def colar(arte, peca, cx, base, borda=4):
    """cola um pedaco da arte da Fase 1 com a borda esmaecida; ela nao tem transparencia"""
    h, w = peca.shape[:2]
    y0, x0 = base - h, cx - w // 2
    alfa = np.ones((h, w))
    for k in range(borda):
        t = (k + 1) / (borda + 1)
        alfa[k, :] = np.minimum(alfa[k, :], t)
        alfa[-1 - k, :] = np.minimum(alfa[-1 - k, :], t)
        alfa[:, k] = np.minimum(alfa[:, k], t)
        alfa[:, -1 - k] = np.minimum(alfa[:, -1 - k], t)
    y1, x1 = min(y0 + h, arte.shape[0]), min(x0 + w, arte.shape[1])
    arte[y0:y1, x0:x1] = arte[y0:y1, x0:x1] * (1 - alfa[: y1 - y0, : x1 - x0, None]) + peca[: y1 - y0, : x1 - x0] * alfa[: y1 - y0, : x1 - x0, None]


def desenhar(aberto, fase01, mapa="tunel"):
    h, w = A // P, L // P
    chao = np.asarray(Image.fromarray(aberto).resize((w, h), Image.NEAREST))
    parede = ~chao
    dist_chao = ndi.distance_transform_edt(chao)
    dist_parede = ndi.distance_transform_edt(parede)

    # ----- chao: terra da Fase 1, escurecendo perto da parede
    ruido = fbm(h, w)
    fino = RNG.random((h, w))
    terra = rampa(ruido * 0.75 + fino * 0.25, [(34, 26, 22), (52, 40, 30), (70, 54, 40), (86, 68, 50), (104, 84, 60)])
    # pedrinhas: pontos claros com sombra embaixo
    pedras = fino > 0.992
    terra[pedras] = (120, 110, 100)
    terra[np.roll(pedras, 1, axis=0)] = (28, 22, 20)
    # sangue seco e musgo vermelho, mais perto das paredes
    manchas = fbm(h, w, (24, 12, 6))
    sangue = manchas > 0.72
    terra[sangue] = terra[sangue] * 0.55 + np.array((86, 12, 16)) * 0.45
    musgo = (dist_chao < 16) & (fbm(h, w, (6, 3)) > 0.60)
    terra[musgo] = rampa(fino[musgo], [(70, 10, 24), (120, 16, 30), (160, 26, 44)])

    # ----- rocha: blocos irregulares, com a luz vindo de cima
    pontos = np.column_stack([RNG.random(5200) * h, RNG.random(5200) * w])
    arvore = cKDTree(pontos)
    grade = np.indices((h, w)).reshape(2, -1).T
    d, qual = arvore.query(grade, k=2)
    d = d.reshape(h, w, 2)
    qual = qual[:, 0].reshape(h, w)
    tom = RNG.random(5200)[qual]
    junta = (d[..., 1] - d[..., 0]) < 1.4
    relevo = ((pontos[qual, 0] - np.indices((h, w))[0]) / 14).clip(-1, 1) * 0.22
    rocha = rampa(np.clip(0.22 + tom * 0.32 + relevo, 0, 1), [(20, 18, 24), (36, 33, 42), (56, 52, 62), (80, 76, 84), (108, 104, 110)])
    rocha[junta] = (14, 12, 16)

    if mapa == "trono":
        # chao de lajes: os mesmos blocos da rocha, mais claros, e o tapete ate o trono
        lajes = np.asarray(Image.fromarray(rocha.astype(np.uint8)).point(lambda v: min(255, v * 1.15 + 14))).astype(float)
        l_i, c_i = np.indices((h, w))
        tapete = (np.abs(c_i - w / 2) < 36) & (l_i > 120)
        lajes[tapete] = rampa(fino[tapete] * 0.5 + 0.2, [(70, 8, 16), (104, 14, 24), (130, 20, 30)])
        lajes[(np.abs(np.abs(c_i - w / 2) - 36) < 1.5) & (l_i > 120)] = (170, 130, 50)
        terra = lajes
        # parede bem mais escura que o chao: as colunas e o limite do salao precisam saltar
        rocha = rocha * 0.42

    arte = np.where(parede[..., None], rocha, terra)

    # ----- face da parede: a rocha que olha para o chao ao sul dela, em fiadas de pedra
    altura_face = 18
    face = parede & (ndi.maximum_filter1d(chao.astype(np.uint8), altura_face, axis=0, origin=-(altura_face // 2)) > 0)
    linhas = np.indices((h, w))[0]
    colunas = np.indices((h, w))[1]
    fiada = (linhas // 6) % 2
    tijolo = ((colunas + fiada * 8) % 16 == 0) | (linhas % 6 == 0)
    tons = rampa(np.clip(ndi.gaussian_filter(fino, 1.2) * 2.4 - 0.7, 0, 1), [(40, 36, 44), (58, 54, 62), (76, 72, 80)])
    # mais escura no pe: a parede afunda no chao
    ate_chao = ndi.distance_transform_edt(~chao)
    tons = tons * np.clip(ate_chao / 18 + 0.35, 0, 1)[..., None]
    arte[face] = tons[face]
    arte[face & tijolo] = (20, 18, 22)
    # sombra da parede no chao, logo abaixo da face
    sombra = chao & (ndi.maximum_filter1d(parede.astype(np.uint8), 9, axis=0, origin=4) > 0)
    arte[sombra] *= 0.55
    arte[chao] *= np.clip(0.6 + dist_chao[chao] / 40, 0, 1)[..., None]

    # ----- pecas da Fase 1: portoes e braseiros
    portao = fase01[512:622, 405:522].astype(float)
    if mapa == "trono":
        colar(arte, portao, w // 2, h, 6)
        estandarte = fase01[200:285, 888:938].astype(float)
        for x in (200, 310, 458, 568):
            colar(arte, estandarte, x, 108, 3)
        # o trono, no alto do tapete: degraus, encosto e a coroa que falta nele
        cx = w // 2
        for k, (lg, cor) in enumerate([(110, (84, 80, 88)), (92, (70, 66, 74)), (74, (58, 54, 62))]):
            arte[128 - k * 8: 136 - k * 8, cx - lg // 2: cx + lg // 2] = cor
            arte[128 - k * 8, cx - lg // 2: cx + lg // 2] = (116, 112, 118)
        arte[70:112, cx - 22:cx + 22] = (26, 20, 26)
        arte[62:70, cx - 16:cx + 16] = (36, 30, 36)
        arte[78:110, cx - 16:cx + 16] = (86, 12, 20)
        for dx in (-22, 21):
            arte[56:112, cx + dx:cx + dx + 2] = (170, 130, 50)
    else:
        colar(arte, portao, 240 // P, h, 6)
        colar(arte, portao, 1640 // P, h, 6)
    # ----- luz: quente em volta dos braseiros, breu longe deles. A leitura do combate
    # nao pode depender disso, entao nunca escurece demais
    luz = np.zeros((h, w))
    for bx, by in (BRASEIROS_TRONO if mapa == "trono" else BRASEIROS):
        g = np.hypot(linhas - by / P, colunas - bx / P)
        luz = np.maximum(luz, np.clip(1 - g / 150, 0, 1) ** 1.6)
    arte = arte * (0.8 + 0.45 * luz)[..., None]
    arte[..., 0] += 26 * luz
    arte[..., 1] += 10 * luz
    # breu no fundo da rocha, longe de tudo
    arte[parede] *= np.clip(1.15 - dist_parede[parede] / 60, 0.45, 1)[..., None]
    return np.clip(arte, 0, 255).astype(np.uint8)


def principal():
    saida = pathlib.Path(sys.argv[1])
    saida.mkdir(parents=True, exist_ok=True)
    fase01 = np.asarray(Image.open(sys.argv[2]).convert("RGB"))
    mapa = sys.argv[3] if len(sys.argv) > 3 else "tunel"
    global L, A
    if mapa == "trono":
        L, A = 1536, 1024
    aberto = tracar_trono() if mapa == "trono" else tracar()

    # a arte fica nas cores da Fase 1: e o que faz o mapa parecer do mesmo jogo
    paleta = Image.fromarray(fase01).quantize(colors=96, method=Image.MEDIANCUT)
    arte = np.asarray(Image.fromarray(desenhar(aberto, fase01, mapa)).quantize(palette=paleta, dither=Image.NONE).convert("RGB")).astype(float)
    # o braseiro entra depois de reduzir as cores: a chama laranja e pouca e sumiria
    braseiro = fase01[86:126, 300:326].astype(float)
    for bx, by in (BRASEIROS_TRONO if mapa == "trono" else BRASEIROS):
        colar(arte, braseiro, bx // P, by // P + 16, 3)
    arte = Image.fromarray(arte.astype(np.uint8))
    arte.resize((L, A), Image.NEAREST).convert("RGBA").save(saida / (mapa + ".png"), optimize=True)
    Image.fromarray(np.where(aberto, 255, 0).astype(np.uint8)).convert("RGBA").save(saida / ("mascara_" + mapa + ".png"), optimize=True)

    # conferencia das larguras: raio livre maximo ao longo da area aberta
    d = ndi.distance_transform_edt(aberto)
    print("area aberta: %.0f%%; maior raio livre: %.0f px" % (100 * aberto.mean(), d.max()))
    # tudo ligado para o tamanho do jogador e dos inimigos (a folga do mapa de direcoes)?
    for nome, mx, my in (("jogador", 14, 19), ("inimigo", 26, 32)):
        cabe = ndi.minimum_filter(aberto, size=(2 * my + 1, 2 * mx + 1))
        marcas, total = ndi.label(cabe)
        tamanhos = ndi.sum(cabe, marcas, range(1, total + 1))
        print("%s: %d pedaco(s) ligado(s), o maior com %.1f%% da area" % (nome, total, 100 * max(tamanhos) / cabe.sum()))


if __name__ == "__main__":
    principal()
