"""Cria sprite ou som no projeto do GameMaker sem abrir a IDE, no mesmo formato que
ela grava: os arquivos do recurso e a linha no Hardenia.yyp.

    python3 tools/importar_recurso.py sprite spr_nome folha.png --quadro 64x64
    python3 tools/importar_recurso.py sprite spr_nome imagem.png --origem 0,0
    python3 tools/importar_recurso.py som snd_nome arquivo.wav
    python3 tools/importar_recurso.py musica snd_nome arquivo.mp3 --duracao 120.5

A folha e cortada em quadros iguais, da esquerda para a direita e de cima para baixo.
Com o recurso ja existente, ele e trocado e os ids continuam os mesmos (o id sai do
nome e do numero do quadro), entao reimportar nao suja o git a toa.
Sprite precisa de Pillow. Feche o projeto na IDE antes: ela salva por cima.
"""
import argparse
import math
import pathlib
import re
import shutil
import uuid
import wave

RAIZ = pathlib.Path(__file__).resolve().parent.parent / "Hardenia"
ESPACO = uuid.UUID("7d1f3a52-0c55-4d2f-9a53-68d2a7f0e6b1")


def guid(*partes):
    return str(uuid.uuid5(ESPACO, "/".join(str(p) for p in partes)))


def registrar(nome, pasta):
    yyp = RAIZ / "Hardenia.yyp"
    texto = yyp.read_text(encoding="utf-8")
    linha = '    {"id":{"name":"%s","path":"%s/%s/%s.yy",},},\n' % (nome, pasta, nome, nome)
    if linha in texto:
        return
    fim = texto.index("  ],\n", texto.index('"resources":['))
    yyp.write_text(texto[:fim] + linha + texto[fim:], encoding="utf-8", newline="\n")


def importar_sprite(nome, arquivo, quadro, origem):
    from PIL import Image

    folha = Image.open(arquivo).convert("RGBA")
    largura, altura = quadro or folha.size
    colunas = folha.width // largura
    linhas = folha.height // altura
    quadros = []
    for l in range(linhas):
        for c in range(colunas):
            quadros.append(folha.crop((c * largura, l * altura, (c + 1) * largura, (l + 1) * altura)))

    # caixa de colisao automatica: a uniao do que nao e transparente nos quadros
    caixa = None
    for q in quadros:
        b = q.getchannel("A").getbbox()
        if b:
            caixa = b if caixa is None else (min(caixa[0], b[0]), min(caixa[1], b[1]), max(caixa[2], b[2]), max(caixa[3], b[3]))
    caixa = caixa or (0, 0, largura, altura)

    pasta = RAIZ / "sprites" / nome
    if pasta.exists():
        shutil.rmtree(pasta)
    pasta.mkdir(parents=True)
    camada = guid(nome, "camada")
    ids = []
    for i, q in enumerate(quadros):
        id_q = guid(nome, "quadro", i)
        ids.append(id_q)
        q.save(pasta / (id_q + ".png"))
        (pasta / "layers" / id_q).mkdir(parents=True)
        q.save(pasta / "layers" / id_q / (camada + ".png"))

    # o modelo e um sprite do proprio projeto: so muda o que depende do sprite novo
    modelo = (RAIZ / "sprites/spr_portal/spr_portal.yy").read_text(encoding="utf-8")
    t = modelo.replace("spr_portal", nome)
    ox, oy = origem if origem else (largura // 2, altura // 2)
    # origin 4 = centro do quadro; 9 = personalizada
    codigo_origem = 4 if not origem else (0 if (ox, oy) == (0, 0) else 9)
    troca = {
        "bbox_bottom": caixa[3] - 1, "bbox_left": caixa[0], "bbox_right": caixa[2] - 1, "bbox_top": caixa[1],
        "height": altura, "width": largura, "origin": codigo_origem,
    }
    for campo, valor in troca.items():
        t = re.sub(r'^(  "%s":)\d+,' % campo, r"\g<1>%d," % valor, t, count=1, flags=re.M)
    t = re.sub(r'("length":)[\d.]+,', r"\g<1>%.1f," % len(quadros), t, count=1)
    t = re.sub(r'("xorigin":)\d+,', r"\g<1>%d," % ox, t, count=1)
    t = re.sub(r'("yorigin":)\d+,', r"\g<1>%d," % oy, t, count=1)
    t = re.sub(r'("\$GMImageLayer":"","%Name":")[^"]+(",.*?"name":")[^"]+(")', r"\g<1>%s\g<2>%s\g<3>" % (camada, camada), t, count=1)
    moldes = "".join(
        '    {"$GMSpriteFrame":"v1","%%Name":"%s","name":"%s","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},\n' % (i, i)
        for i in ids
    )
    t = re.sub(r'(  "frames":\[\n).*?(  \],\n  "gridX")', lambda m: m.group(1) + moldes + m.group(2), t, count=1, flags=re.S)
    chaves = "".join(
        '            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{\n'
        '                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"%s","path":"sprites/%s/%s.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},\n'
        '              },"Disabled":false,"id":"%s","IsCreationKey":false,"Key":%.1f,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},\n'
        % (i, nome, nome, guid(nome, "chave", n), n)
        for n, i in enumerate(ids)
    )
    t = re.sub(r'("Keyframes":\[\n)            \{"\$Keyframe<SpriteFrameKeyframe>".*?(          \],"resourceType":"KeyframeStore<SpriteFrameKeyframe>")',
               lambda m: m.group(1) + chaves + m.group(2), t, count=1, flags=re.S)
    (pasta / (nome + ".yy")).write_text(t, encoding="utf-8", newline="\n")
    registrar(nome, "sprites")
    print("%s: %d quadro(s) de %dx%d, caixa %s" % (nome, len(quadros), largura, altura, caixa))


def importar_som(nome, arquivo):
    arquivo = pathlib.Path(arquivo)
    pasta = RAIZ / "sounds" / nome
    pasta.mkdir(parents=True, exist_ok=True)
    destino = pasta / (nome + arquivo.suffix.lower())
    shutil.copyfile(arquivo, destino)
    with wave.open(str(destino)) as w:
        duracao = w.getnframes() / w.getframerate()
        taxa = w.getframerate()
        canais = w.getnchannels()
    t = (RAIZ / "sounds/snd_dash/snd_dash.yy").read_text(encoding="utf-8").replace("snd_dash", nome)
    t = re.sub(r'("duration":)[\d.]+,', r"\g<1>%.8f," % duracao, t, count=1)
    t = re.sub(r'("sampleRate":)\d+,', r"\g<1>%d," % taxa, t, count=1)
    t = re.sub(r'("channelFormat":)\d+,', r"\g<1>%d," % (canais - 1), t, count=1)
    (pasta / (nome + ".yy")).write_text(t, encoding="utf-8", newline="\n")
    registrar(nome, "sounds")
    print("%s: %.2f s, %d Hz, %d canal(is)" % (nome, duracao, taxa, canais))


def importar_musica(nome, arquivo, duracao):
    """toca do disco, sem carregar tudo na memoria, como as musicas que ja estavam no jogo"""
    arquivo = pathlib.Path(arquivo)
    pasta = RAIZ / "sounds" / nome
    pasta.mkdir(parents=True, exist_ok=True)
    destino = pasta / (nome + arquivo.suffix.lower())
    shutil.copyfile(arquivo, destino)
    t = (RAIZ / "sounds/snd_game_music/snd_game_music.yy").read_text(encoding="utf-8").replace("snd_game_music", nome)
    t = t.replace(nome + ".mp3", destino.name)
    t = re.sub(r'("duration":)[\d.]+,', r"\g<1>%.5f," % duracao, t, count=1)
    (pasta / (nome + ".yy")).write_text(t, encoding="utf-8", newline="\n")
    registrar(nome, "sounds")
    print("%s: %.1f s" % (nome, duracao))


def par(texto, separador):
    a, b = texto.split(separador)
    return int(a), int(b)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    s = p.add_subparsers(dest="tipo", required=True)
    sp = s.add_parser("sprite")
    sp.add_argument("nome")
    sp.add_argument("arquivo")
    sp.add_argument("--quadro", help="LxA de cada quadro; sem isso, a imagem inteira e um quadro")
    sp.add_argument("--origem", help="x,y; sem isso, o centro do quadro")
    so = s.add_parser("som")
    so.add_argument("nome")
    so.add_argument("arquivo", help="wav")
    sm = s.add_parser("musica")
    sm.add_argument("nome")
    sm.add_argument("arquivo", help="mp3 ou ogg")
    sm.add_argument("--duracao", type=float, required=True)
    a = p.parse_args()
    if a.tipo == "sprite":
        importar_sprite(a.nome, a.arquivo, par(a.quadro, "x") if a.quadro else None, par(a.origem, ",") if a.origem else None)
    elif a.tipo == "musica":
        importar_musica(a.nome, a.arquivo, a.duracao)
    else:
        importar_som(a.nome, a.arquivo)


if __name__ == "__main__":
    main()
