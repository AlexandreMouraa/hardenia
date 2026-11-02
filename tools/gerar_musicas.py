"""Corta e deixa em loop as musicas de area, a partir dos MP3 originais de Kevin MacLeod
(incompetech.com, CC BY 4.0; a lista esta em docs/CREDITOS_ASSETS.md).

    python3 tools/gerar_musicas.py PASTA_CACHE PASTA_SAIDA

Baixa so o que falta. Cada faixa sai com o trecho escolhido, o fim entrando no comeco em 4 s (para
dar a volta sem emenda), todas no mesmo volume, e leve: 2 min em 80 kbps. Precisa de numpy e ffmpeg.
"""
import pathlib
import subprocess
import sys
import urllib.parse
import urllib.request

import numpy as np

BASE = "https://incompetech.com/music/royalty-free/mp3-royaltyfree/"
TAXA = 44100
CRUZA = 4
# nome no jogo, faixa, inicio e fim do trecho em segundos, volume medio (RMS), da a volta?
FAIXAS = [
    ("snd_musica_catacumbas", "Ossuary 1 - A Beginning", 0, 130, 0.075, True),
    ("snd_musica_patio", "Gathering Darkness", 0, 110, 0.085, True),
    ("snd_musica_cemiterio", "Ossuary 6 - Air", 60, 190, 0.07, True),
    ("snd_musica_duelo", "Unholy Knight", 20, 120, 0.14, True),
    ("snd_musica_rei", "Five Armies", 20, 150, 0.15, True),
    ("snd_musica_final", "Lost Time", 0, 110, 0.08, False),
]


def ler(arquivo):
    saida = subprocess.run(["ffmpeg", "-v", "error", "-i", str(arquivo), "-ac", "2", "-ar", str(TAXA), "-f", "s16le", "-"], capture_output=True, check=True).stdout
    return np.frombuffer(saida, dtype=np.int16).reshape(-1, 2).astype(float) / 32768


def main():
    cache = pathlib.Path(sys.argv[1])
    destino = pathlib.Path(sys.argv[2])
    destino.mkdir(parents=True, exist_ok=True)
    for nome, faixa, ini, fim, rms, volta in FAIXAS:
        original = cache / (faixa + ".mp3")
        if not original.exists():
            urllib.request.urlretrieve(BASE + urllib.parse.quote(faixa) + ".mp3", original)
        a = ler(original)[ini * TAXA:fim * TAXA]
        if volta:
            n = CRUZA * TAXA
            t = np.linspace(0, 1, n)[:, None]
            # o comeco ganha o fim por cima, em potencia constante, e o fim sai da faixa
            a[:n] = a[:n] * np.sqrt(t) + a[-n:] * np.sqrt(1 - t)
            a = a[:-n]
        else:
            n = 6 * TAXA
            a[-n:] *= np.linspace(1, 0, n)[:, None]
        a *= rms / np.sqrt(np.mean(a ** 2))
        a = np.clip(a, -0.99, 0.99)
        crua = (a * 32767).astype(np.int16).tobytes()
        subprocess.run(["ffmpeg", "-y", "-v", "error", "-f", "s16le", "-ac", "2", "-ar", str(TAXA), "-i", "-", "-b:a", "80k", str(destino / (nome + ".mp3"))], input=crua, check=True)
        print("%s: %.1f s" % (nome, len(a) / TAXA))


if __name__ == "__main__":
    main()
