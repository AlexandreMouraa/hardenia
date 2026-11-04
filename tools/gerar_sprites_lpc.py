"""Monta as folhas dos inimigos novos com pecas do Universal LPC Spritesheet Character
Generator (cada pedaco tem autor e licenca em docs/CREDITOS_ASSETS.md).

    python3 tools/gerar_sprites_lpc.py PASTA_CACHE PASTA_SAIDA

Baixa so o que falta para PASTA_CACHE. A saida e uma folha por animacao, no formato do
jogo: quadros de 64 x 64 e linhas na ordem baixo, esquerda, direita, cima (no LPC e cima,
esquerda, baixo, direita). O quadro parado do LPC (coluna 0 do andar) fica de fora: o
inimigo so usa os 8 da caminhada. Precisa de Pillow e numpy.
"""
import pathlib
import sys
import urllib.request

import numpy as np
from PIL import Image

BASE = "https://raw.githubusercontent.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator/master/spritesheets/"
Q = 64
ORDEM = [2, 1, 3, 0]  # linha do LPC para baixo, esquerda, direita, cima

def osso(acao):
    return ["body/bodies/skeleton/%s.png" % acao, "head/heads/skeleton/adult/%s.png" % acao]


def peca(cache, caminho):
    arquivo = cache / caminho
    if not arquivo.exists():
        arquivo.parent.mkdir(parents=True, exist_ok=True)
        urllib.request.urlretrieve(BASE + caminho, arquivo)
    return Image.open(arquivo).convert("RGBA")


def centrar(img, cel):
    """arma grande vem em quadros maiores, com o corpo no meio: corta o meio de cada um
    para alinhar com o corpo. O que passa de 64 px fica de fora"""
    colunas = img.width // cel
    linhas = img.height // cel
    m = (cel - Q) // 2
    saida = Image.new("RGBA", (colunas * Q, linhas * Q), (0, 0, 0, 0))
    for l in range(linhas):
        for c in range(colunas):
            saida.paste(img.crop((c * cel + m, l * cel + m, c * cel + m + Q, l * cel + m + Q)), (c * Q, l * Q))
    return saida


def tingir(img, cor, forca=1.0):
    """multiplica pela cor, para vestir o esqueleto: o LPC so traz algumas cores"""
    a = np.asarray(img).astype(float)
    a[..., :3] = a[..., :3] * (1 - forca) + a[..., :3] * np.array(cor) / 255 * forca
    return Image.fromarray(a.astype(np.uint8))


def juntar(cache, camadas):
    """camadas de tras para a frente: caminho, ou (caminho, cor)"""
    fundo = None
    for c in camadas:
        caminho, cor = c if isinstance(c, tuple) else (c, None)
        img = peca(cache, caminho)
        # 256 px de altura = 4 linhas de 64. Mais que isso, a peca usa quadros maiores
        if img.height > 256:
            img = centrar(img, img.height // 4)
        if cor:
            img = tingir(img, cor)
        if fundo is None:
            fundo = Image.new("RGBA", img.size, (0, 0, 0, 0))
        if img.size != fundo.size:
            img = img.crop((0, 0) + fundo.size)
        fundo = Image.alpha_composite(fundo, img)
    return fundo


def folha(img, colunas, escala=1):
    """escolhe as colunas e poe as linhas na ordem do jogo"""
    q = Q * escala
    saida = Image.new("RGBA", (q * len(colunas), q * 4), (0, 0, 0, 0))
    for l_jogo, l_lpc in enumerate(ORDEM):
        for c_jogo, c_lpc in enumerate(colunas):
            quadro = img.crop((c_lpc * Q, l_lpc * Q, (c_lpc + 1) * Q, (l_lpc + 1) * Q))
            if escala != 1:
                quadro = quadro.resize((q, q), Image.NEAREST)
            saida.paste(quadro, (c_jogo * q, l_jogo * q))
    return saida


ANDAR = list(range(1, 9))


def arqueiro(cache, saida):
    # o arco tem parte atras e parte na frente do corpo
    folha(juntar(cache, ["weapon/ranged/bow/normal/walk/background/dark.png"] + osso("walk") + ["weapon/ranged/bow/normal/walk/foreground/dark.png"]), ANDAR).save(saida / "arqueiro_andar.png")
    folha(juntar(cache, ["weapon/ranged/bow/normal/universal/background/shoot/dark.png"] + osso("shoot") + ["weapon/ranged/bow/arrow/shoot/arrow.png", "weapon/ranged/bow/normal/universal/foreground/shoot/dark.png"]), list(range(13))).save(saida / "arqueiro_tiro.png")


def conjurador(cache, saida):
    roxo = (120, 70, 150)
    folha(juntar(cache, osso("walk") + ["torso/clothes/robe/female/walk/purple.png", ("hat/cloth/hood/adult/walk.png", roxo)]), ANDAR).save(saida / "conjurador_andar.png")
    folha(juntar(cache, osso("spellcast") + ["torso/clothes/robe/female/spellcast/purple.png", ("hat/cloth/hood/adult/spellcast.png", roxo)]), list(range(7))).save(saida / "conjurador_magia.png")


def chefe(cache, saida):
    # o rei morto: esqueleto escurecido, de coroa, com o dobro do tamanho
    escuro = (150, 120, 130)
    def corpo(acao):
        return [("body/bodies/skeleton/%s.png" % acao, escuro), ("head/heads/skeleton/adult/%s.png" % acao, escuro)]
    folha(juntar(cache, corpo("walk") + ["hat/formal/crown/adult/walk/gold.png"]), ANDAR, 2).save(saida / "chefe_andar.png")
    folha(juntar(cache, corpo("slash") + ["hat/formal/crown/adult/slash/gold.png"]), list(range(6)), 2).save(saida / "chefe_golpe.png")
    folha(juntar(cache, corpo("spellcast") + ["hat/formal/crown/adult/spellcast/gold.png"]), list(range(7)), 2).save(saida / "chefe_magia.png")


def horda(cache, saida):
    folha(juntar(cache, ["body/bodies/zombie/walk/zombie.png", "head/heads/zombie/adult/walk.png"]), ANDAR).save(saida / "zumbi_andar.png")


def grande(cache, camadas, colunas, cel=128):
    """folha em quadros de 128 x 128, com o corpo no meio: a arma grande dos Caidos nao cabe
    em 64 e seria cortada. Camadas de tras para a frente, como em juntar"""
    saida = Image.new("RGBA", (cel * len(colunas), cel * 4), (0, 0, 0, 0))
    for c in camadas:
        caminho, cor = c if isinstance(c, tuple) else (c, None)
        img = peca(cache, caminho)
        if cor:
            img = tingir(img, cor)
        e = img.height // 4
        m = (cel - e) // 2
        for l_jogo, l_lpc in enumerate(ORDEM):
            for c_jogo, c_lpc in enumerate(colunas):
                q = img.crop((c_lpc * e, l_lpc * e, (c_lpc + 1) * e, (l_lpc + 1) * e))
                quadro = Image.new("RGBA", (cel, cel), (0, 0, 0, 0))
                if m >= 0:
                    quadro.paste(q, (m, m))
                else:
                    quadro.paste(q.crop((-m, -m, e + m, e + m)), (0, 0))
                saida.alpha_composite(quadro, (c_jogo * cel, l_jogo * cel))
    return saida


def caidos(cache, saida):
    """os guerreiros que vieram antes: corpo acinzentado, de morto, e a cor de cada um na roupa"""
    cinza = (150, 165, 160)
    def corpo(acao, tipo="male", pes="male"):
        return [("body/bodies/%s/%s.png" % (tipo, acao), cinza), ("feet/boots/basic/%s/%s.png" % (pes, acao), (70, 62, 60))]
    def cabeca(acao, tipo="male"):
        return [("head/heads/human/%s/%s.png" % (tipo, acao), cinza)]

    def carrasco(a, arma_atras, arma):
        return [arma_atras] + corpo(a) + [("legs/pants/male/%s.png" % a, (60, 40, 42)), ("torso/armour/leather/male/%s.png" % a, (95, 45, 48))] + cabeca(a) + [("hat/cloth/hood/adult/%s.png" % a, (150, 40, 44)), arma]

    def batedor(a, arma_atras, arma):
        return [arma_atras] + corpo(a) + [("legs/pants/male/%s.png" % a, (45, 70, 80)), ("torso/armour/leather/male/%s.png" % a, (70, 135, 150))] + cabeca(a) + [("hat/cloth/hood/adult/%s.png" % a, (55, 150, 175)), arma]

    def sapador(a):
        return corpo(a) + [("legs/pants/male/%s.png" % a, (90, 62, 38)), ("torso/armour/leather/male/%s.png" % a, (190, 110, 45))] + cabeca(a) + [("hat/helmet/barbarian/adult/%s.png" % a, (210, 170, 120))]

    def sentinela(a, arma_atras, arma):
        return [arma_atras] + corpo(a, "female", "thin") + [("legs/armour/plate/thin/%s.png" % a, (205, 185, 130)), ("torso/armour/plate/female/%s.png" % a, (225, 200, 130))] + cabeca(a, "female") + [("hat/helmet/barbuta/female/%s.png" % a, (235, 210, 130)), arma]

    machado = "weapon/blunt/waraxe/"
    adaga = "weapon/sword/dagger/"
    alabarda = "weapon/polearm/halberd/"
    GOLPE = list(range(6))
    grande(cache, carrasco("walk", machado + "behind/walk/waraxe.png", machado + "walk/waraxe.png"), ANDAR).save(saida / "caido_carrasco_andar.png")
    grande(cache, carrasco("slash", machado + "attack_slash/behind/waraxe.png", machado + "attack_slash/waraxe.png"), GOLPE).save(saida / "caido_carrasco_golpe.png")
    grande(cache, batedor("walk", adaga + "behind/walk/dagger.png", adaga + "walk/dagger.png"), ANDAR).save(saida / "caido_batedor_andar.png")
    grande(cache, batedor("slash", adaga + "behind/slash/dagger.png", adaga + "slash/dagger.png"), GOLPE).save(saida / "caido_batedor_golpe.png")
    grande(cache, sapador("walk"), ANDAR).save(saida / "caido_sapador_andar.png")
    grande(cache, sapador("spellcast"), list(range(7))).save(saida / "caido_sapador_golpe.png")
    grande(cache, sentinela("walk", alabarda + "behind/walk/halberd.png", alabarda + "walk/halberd.png"), ANDAR).save(saida / "caido_sentinela_andar.png")
    grande(cache, sentinela("slash", alabarda + "attack_slash/behind/halberd.png", alabarda + "attack_slash/halberd.png"), GOLPE).save(saida / "caido_sentinela_golpe.png")


def projeteis(saida):
    """flecha e magia, feitas aqui mesmo: 32 x 32, apontando para a direita (o jogo gira)"""
    f = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    for x in range(6, 26):
        f.putpixel((x, 16), (120, 84, 48, 255))
        f.putpixel((x, 15), (90, 62, 36, 255))
    for x, y, cor in [(26, 15, (200, 200, 210)), (26, 16, (200, 200, 210)), (27, 15, (230, 230, 240)), (27, 16, (230, 230, 240)), (28, 15, (240, 240, 250)), (28, 16, (240, 240, 250)), (25, 14, (150, 150, 160)), (25, 17, (150, 150, 160)), (26, 14, (170, 170, 180)), (26, 17, (170, 170, 180))]:
        f.putpixel((x, y), cor + (255,))
    for x, y in [(6, 14), (7, 14), (8, 14), (6, 17), (7, 17), (8, 17), (5, 13), (5, 18)]:
        f.putpixel((x, y), (190, 40, 40, 255))
    f.save(saida / "flecha.png")


def principal():
    cache = pathlib.Path(sys.argv[1])
    saida = pathlib.Path(sys.argv[2])
    saida.mkdir(parents=True, exist_ok=True)
    arqueiro(cache, saida)
    conjurador(cache, saida)
    chefe(cache, saida)
    horda(cache, saida)
    caidos(cache, saida)
    projeteis(saida)


if __name__ == "__main__":
    principal()
