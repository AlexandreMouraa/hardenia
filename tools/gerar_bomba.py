"""Desenha a bomba que cai (spr_bomba): folha de 2 quadros de 48 x 48, com o pavio aceso
trocando de um quadro para o outro. Feita aqui mesmo, sem arte de fora.

    python3 tools/gerar_bomba.py bomba.png
    python3 tools/importar_recurso.py sprite spr_bomba bomba.png --quadro 48x48

Precisa de Pillow.
"""
import math
import sys

from PIL import Image

LADO = 48
CX = 24
CY = 28
RAIO = 13
CONTORNO = (11, 10, 16, 255)
# do escuro para o claro; a luz vem de cima e da esquerda
RAMPA = [(21, 20, 28), (34, 33, 44), (52, 51, 66), (78, 78, 96), (120, 120, 142)]
PAVIO = [(25, 14), (26, 13), (27, 12), (28, 11), (29, 10), (30, 9), (31, 9), (32, 8)]


def desenhar(quadro):
    f = Image.new("RGBA", (LADO, LADO), (0, 0, 0, 0))
    px = f.load()
    for y in range(LADO):
        for x in range(LADO):
            dx = x + 0.5 - CX
            dy = y + 0.5 - CY
            d = math.hypot(dx, dy)
            if d > RAIO + 1:
                continue
            if d > RAIO:
                px[x, y] = CONTORNO
                continue
            nz = math.sqrt(max(0, RAIO * RAIO - d * d)) / RAIO
            luz = max(0, (-dx * 0.5 - dy * 0.62) / RAIO + nz * 0.6)
            # faixa de metal em volta, como as bombas de ferro antigas
            cor = RAMPA[min(len(RAMPA) - 1, int(luz * len(RAMPA)))]
            if abs(dy - 2 - dx * 0.18) < 1.0:
                cor = RAMPA[max(0, min(len(RAMPA) - 1, int(luz * len(RAMPA))) - 1)]
            px[x, y] = cor + (255,)
    # boca onde entra o pavio
    for y in range(12, 16):
        for x in range(20, 28):
            px[x, y] = (62, 61, 78, 255) if y > 12 else CONTORNO
    for x in range(21, 27):
        px[x, 15] = (92, 92, 112, 255)
    for x, y in PAVIO:
        px[x, y] = (186, 150, 96, 255)
        px[x, y + 1] = (112, 88, 54, 255)
    # fagulha na ponta
    fim_x, fim_y = PAVIO[-1]
    if quadro == 0:
        faisca = [(1, -1, (255, 240, 170)), (2, -2, (255, 200, 70)), (2, 0, (255, 150, 40)), (0, -2, (255, 150, 40))]
    else:
        faisca = [(1, -1, (255, 210, 90)), (2, -1, (255, 240, 170)), (1, -3, (255, 170, 50)), (3, -2, (255, 130, 30)), (3, 0, (255, 170, 50))]
    for dx, dy, cor in faisca:
        px[fim_x + dx, fim_y + dy] = cor + (255,)
    return f


def principal():
    folha = Image.new("RGBA", (LADO * 2, LADO), (0, 0, 0, 0))
    for i in range(2):
        folha.paste(desenhar(i), (i * LADO, 0))
    folha.save(sys.argv[1])


if __name__ == "__main__":
    principal()
