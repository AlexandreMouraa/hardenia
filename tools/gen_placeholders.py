"""Gera os sprites provisorios de Hardenia usando SOMENTE a paleta oficial.

Arte 100% programatica e propria - nada baixado, nada gerado por IA.
Serve como marcador ate a arte real ficar pronta.

Uso:  python3 tools/gen_placeholders.py
"""
import struct
import zlib
from pathlib import Path

# Paleta oficial (extraida da biblia visual da equipe)
PALETA = {
    "K": (0x0A, 0x0B, 0x0D),  # vazio / contorno
    "A": (0x1B, 0x20, 0x27),  # ardosia
    "Z": (0x32, 0x3C, 0x49),  # azul-ardosia
    "C": (0x62, 0x62, 0x69),  # cinza
    "O": (0xA9, 0x98, 0x8E),  # osso
    "R": (0x90, 0x1B, 0x1D),  # sangue
    "B": (0xE8, 0xDE, 0xD9),  # branco-osso
    ".": None,                 # transparente
}

JOGADOR = [
    "................",
    ".....KKKKKK.....",
    "....KOOOOOOK....",
    "....KOKOOKOK....",
    "....KOOOOOOK....",
    "....KKOOOOKK....",
    "...RRKKKKKKRR...",
    "..RRRKAAAAKRRR..",
    "..RRRKAAAAKRRR..",
    "..RRRKAAAAKRRR..",
    "..RRKKAAAAKKRR..",
    "...RKOAAAAOKR...",
    "....KOAAAAOK..C.",
    "....KKAAAAKK..C.",
    ".....KAAAAK...C.",
    ".....KAAAAK...C.",
    ".....KKAAKK...C.",
    ".....KAAKAK.....",
    ".....KAAKAK.....",
    ".....KAAKAK.....",
    ".....KAAKAK.....",
    "....KKAKKAKK....",
    "....KOOKKOOK....",
    "....KKKK.KKK....",
]

INIMIGO = [
    "................",
    "................",
    ".....KKKKKK.....",
    "....KAAAAAAK....",
    "....KARAARAK....",
    "....KAAAAAAK....",
    "....KKAAAAKK....",
    "...KKKKKKKKKK...",
    "...KZZZZZZZZK...",
    "...KZZZZZZZZK...",
    "...KZZZZZZZZK...",
    "....KZZZZZZK....",
    "....KZZZZZZK....",
    ".....KZZZZK.....",
    ".....KZZZZK.....",
    ".....KKZZKK.....",
    ".....KZKKZK.....",
    ".....KZK.KZK....",
    ".....KZK.KZK....",
    "....KKZK.KZKK...",
    "....KAAK.KAAK...",
    "....KKKK.KKKK...",
    "................",
    "................",
]

TILE = [
    "AAAAAAAAAAAAAAAA",
    "AZZZZZZKAZZZZZZA",
    "AZZZZZZKAZZZZZZA",
    "AZZZZZZKAZZZZZZA",
    "AZZZZZZKAZZZZZZA",
    "AZZZZZZKAZZZZZZA",
    "AZZZZZZKAZZZZZZA",
    "AKKKKKKKKKKKKKKA",
    "AAKZZZZZZZZZZKAA",
    "AZZZZZZZZZZZZZZA",
    "AZZZZZZZZZZZZZZA",
    "AZZZZZZZZZZZZZZA",
    "AZZZZZZZZZZZZZZA",
    "AZZZZZZZZZZZZZZA",
    "AZZZZZZZZZZZZZZA",
    "AAAAAAAAAAAAAAAA",
]


def escrever_png(caminho: Path, linhas: list[str]) -> None:
    altura = len(linhas)
    largura = len(linhas[0])
    bruto = bytearray()
    for linha in linhas:
        bruto.append(0)  # filtro "None" por scanline
        for ch in linha:
            cor = PALETA[ch]
            if cor is None:
                bruto.extend((0, 0, 0, 0))
            else:
                bruto.extend((cor[0], cor[1], cor[2], 255))

    def chunk(tipo: bytes, dados: bytes) -> bytes:
        return (
            struct.pack(">I", len(dados))
            + tipo
            + dados
            + struct.pack(">I", zlib.crc32(tipo + dados) & 0xFFFFFFFF)
        )

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", largura, altura, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(bruto), 9))
    png += chunk(b"IEND", b"")
    caminho.write_bytes(png)
    print(f"{caminho.name}: {largura}x{altura}")


if __name__ == "__main__":
    destino = Path(__file__).resolve().parent.parent / "assets" / "sprites"
    destino.mkdir(parents=True, exist_ok=True)
    escrever_png(destino / "placeholder_jogador.png", JOGADOR)
    escrever_png(destino / "placeholder_inimigo.png", INIMIGO)
    escrever_png(destino / "placeholder_tile.png", TILE)
