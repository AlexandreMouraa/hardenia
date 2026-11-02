"""Gera as folhas das duas fontes do jogo, a partir de TTFs livres (SIL OFL 1.1, em
docs/CREDITOS_ASSETS.md). Cada letra vira um quadro, e o scr_fonte monta a fonte com
font_add_sprite_ext: funciona igual no Windows e no navegador, e tem acento.

    python3 tools/gerar_fontes.py PASTA_CACHE PASTA_SAIDA

Baixa os TTFs so se faltarem. Depois importe as folhas com importar_recurso.py, com o tamanho
de quadro que este script imprime. Precisa de Pillow.

O GameMaker corta o vazio em volta de cada quadro e usa o que sobra como largura da letra.
Por isso cada quadro leva dois pontos quase invisiveis nos cantos da caixa da letra: a largura
fica a do desenho da fonte (com a folga dos lados), e a altura fica a mesma em todas.
A ordem das letras tem de ser a mesma do FONTE_LETRAS, em scr_fonte.
"""
import pathlib
import sys
import urllib.request

from PIL import Image, ImageDraw, ImageFont

BASE = "https://raw.githubusercontent.com/google/fonts/main/ofl/"
ACENTOS = "ÀÁÂÃÇÉÊÍÓÔÕÚÜàáâãçéêíóôõúü"
LETRAS = "".join(chr(c) for c in range(32, 127)) + ACENTOS
FONTES = [
    # nome, arquivo no Google Fonts, peso, tamanho em pontos
    ("spr_fonte_texto", "grenze/Grenze%5Bwght%5D.ttf", 500, 34),
    ("spr_fonte_titulo", "grenzegotisch/GrenzeGotisch%5Bwght%5D.ttf", 700, 96),
]


def fonte(cache, caminho, peso, tamanho):
    arquivo = cache / caminho.split("/")[-1].replace("%5B", "[").replace("%5D", "]")
    if not arquivo.exists():
        arquivo.parent.mkdir(parents=True, exist_ok=True)
        urllib.request.urlretrieve(BASE + caminho, arquivo)
    f = ImageFont.truetype(str(arquivo), tamanho)
    f.set_variation_by_axes([peso])
    return f


def folha(f):
    sobe, desce = f.getmetrics()
    altura = sobe + desce + 4
    largura = max(max(1, round(f.getlength(c))) for c in LETRAS) + 8
    # 121 letras em 11 x 11: sem quadro vazio no fim
    colunas = 11
    linhas = 11
    img = Image.new("RGBA", (colunas * largura, linhas * altura), (0, 0, 0, 0))
    for i, c in enumerate(LETRAS):
        x0 = (i % colunas) * largura
        y0 = (i // colunas) * altura
        q = Image.new("L", (largura, altura), 0)
        # 2 px de folga na frente: letra que passa um pouco da caixa (j, f) nao e cortada
        ImageDraw.Draw(q).text((2, 2), c, font=f, fill=255)
        img.paste((255, 255, 255, 255), (x0, y0), q)
        fim = min(largura - 1, 2 + max(1, round(f.getlength(c))) - 1)
        for ponto in ((x0 + 2, y0), (x0 + fim, y0 + altura - 1)):
            if img.getpixel(ponto)[3] == 0:
                img.putpixel(ponto, (255, 255, 255, 1))
    return img, largura, altura


def main():
    cache = pathlib.Path(sys.argv[1])
    saida = pathlib.Path(sys.argv[2])
    saida.mkdir(parents=True, exist_ok=True)
    for nome, caminho, peso, tamanho in FONTES:
        img, largura, altura = folha(fonte(cache, caminho, peso, tamanho))
        img.save(saida / (nome + ".png"))
        print("%s: %dx%d, %d letras" % (nome, largura, altura, len(LETRAS)))


if __name__ == "__main__":
    main()
