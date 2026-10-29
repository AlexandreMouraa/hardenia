"""Recomprime as texturas PNG do jogo web sem mudar nenhum pixel.

O GameMaker grava as paginas de textura com compressao baixa. Aqui so o fluxo
zlib do IDAT e refeito no nivel maximo (testando duas estrategias): as linhas
filtradas continuam byte a byte iguais, e os outros chunks (cHRM, bKGD...) nao
sao tocados. Antes de gravar, descomprime o resultado e confere que e identico
ao original; se nao for menor, deixa o arquivo como estava.

Nas texturas da v0.4: 12,4 MB -> 10,2 MB por jogador (-17%).

Uso: python3 -I otimizar-png.py arquivo.png [...]
"""
import struct
import sys
import zlib

ASSINATURA = b"\x89PNG\r\n\x1a\n"


def chunks(dados):
    pos = len(ASSINATURA)
    while pos < len(dados):
        n, tipo = struct.unpack(">I4s", dados[pos:pos + 8])
        yield tipo, dados[pos + 8:pos + 8 + n]
        pos += 12 + n


def chunk(tipo, corpo):
    return struct.pack(">I", len(corpo)) + tipo + corpo + struct.pack(">I", zlib.crc32(tipo + corpo))


def comprimir(cru):
    melhor = None
    for estrategia in (zlib.Z_DEFAULT_STRATEGY, zlib.Z_FILTERED):
        c = zlib.compressobj(9, zlib.DEFLATED, 15, 9, estrategia)
        z = c.compress(cru) + c.flush()
        if melhor is None or len(z) < len(melhor):
            melhor = z
    return melhor


def otimizar(caminho):
    dados = open(caminho, "rb").read()
    if not dados.startswith(ASSINATURA):
        return f"{caminho}: nao e PNG, ignorado"
    lista = list(chunks(dados))
    cru = zlib.decompress(b"".join(c for t, c in lista if t == b"IDAT"))
    novo_idat = comprimir(cru)
    if zlib.decompress(novo_idat) != cru:
        sys.exit(f"{caminho}: recompressao diferente do original, abortado")

    saida, idat_feito = [ASSINATURA], False
    for tipo, corpo in lista:
        if tipo == b"IDAT":
            if not idat_feito:
                saida.append(chunk(b"IDAT", novo_idat))
                idat_feito = True
        else:
            saida.append(chunk(tipo, corpo))
    novo = b"".join(saida)

    if len(novo) >= len(dados):
        return f"{caminho}: ja estava otimizado"
    open(caminho, "wb").write(novo)
    return f"{caminho}: {len(dados) / 1e6:.2f} -> {len(novo) / 1e6:.2f} MB"


if __name__ == "__main__":
    for caminho in sys.argv[1:]:
        print(otimizar(caminho))
