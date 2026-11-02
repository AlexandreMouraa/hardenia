"""Gera os sons de fundo de cada area e o coracao de vida baixa, sem amostra nenhuma.

    python3 tools/gerar_sons_ambiente.py PASTA_SAIDA

Cada ambiente da a volta sem emenda: o fim entra no comeco. Sem sorteio solto: a semente e fixa,
entao sair sempre igual nao suja o git. Precisa de numpy e ffmpeg.
"""
import pathlib
import subprocess
import sys

import numpy as np

TAXA = 22050
g = np.random.default_rng(7)


def passa_baixa(x, corte):
    # um polo so, ida e volta: som de vento nao precisa de mais que isso
    a = np.exp(-2 * np.pi * corte / TAXA)
    y = np.zeros_like(x)
    v = 0.0
    for i in range(len(x)):
        v = (1 - a) * x[i] + a * v
        y[i] = v
    return y


def lento(n, periodo, fase=0):
    return 0.5 + 0.5 * np.sin(2 * np.pi * np.arange(n) / (periodo * TAXA) + fase)


def em_volta(x, seg=2):
    n = seg * TAXA
    t = np.linspace(0, 1, n)
    x = x.copy()
    x[:n] = x[:n] * np.sqrt(t) + x[-n:] * np.sqrt(1 - t)
    return x[:-n]


def vento(seg, corte, forca):
    n = seg * TAXA
    a = passa_baixa(g.normal(0, 1, n), corte)
    b = passa_baixa(g.normal(0, 1, n), corte * 2.4)
    return (a * (0.6 + 0.4 * lento(n, 7.3)) + b * 0.45 * lento(n, 4.1, 2)) * forca


def gotas(x):
    # gota: um pio curto que desce, com um eco fraco, em lugares fixos pela semente
    n = len(x)
    for t0 in sorted(g.uniform(1, n / TAXA - 1.5, 7)):
        d = int(0.09 * TAXA)
        i = int(t0 * TAXA)
        t = np.arange(d) / TAXA
        f = 1300 + 900 * g.random()
        p = np.sin(2 * np.pi * (f * t - 2500 * t * t)) * np.exp(-t * 45) * 0.5
        x[i:i + d] += p
        e = i + int(0.23 * TAXA)
        if e + d < n:
            x[e:e + d] += p * 0.25
    return x


def fogo(seg):
    n = seg * TAXA
    x = passa_baixa(g.normal(0, 1, n), 420) * (0.7 + 0.3 * lento(n, 3.1))
    # estalos: pontas curtas de ruido
    for t0 in g.uniform(0, seg - 0.1, seg * 7):
        d = int(0.012 * TAXA)
        i = int(t0 * TAXA)
        x[i:i + d] += g.normal(0, 0.45, d) * np.exp(-np.arange(d) / (d / 4)) * g.random()
    return x


def coracao():
    # duas batidas graves e um silencio: 72 batidas por minuto, porque esta com medo
    seg = 60 / 72
    n = int(seg * TAXA)
    x = np.zeros(n)
    for t0, forca in ((0, 1), (0.22, 0.65)):
        d = int(0.16 * TAXA)
        i = int(t0 * TAXA)
        t = np.arange(d) / TAXA
        x[i:i + d] += forca * np.sin(2 * np.pi * (58 * t - 40 * t * t)) * np.exp(-t * 26)
    return x


def salvar(saida, nome, x, pico):
    x = x / max(1e-6, np.max(np.abs(x))) * pico
    crua = (np.clip(x, -1, 1) * 32767).astype(np.int16).tobytes()
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-f", "s16le", "-ac", "1", "-ar", str(TAXA), "-i", "-", "-b:a", "48k", str(saida / (nome + ".mp3"))], input=crua, check=True)
    print("%s: %.1f s" % (nome, len(x) / TAXA))


def main():
    saida = pathlib.Path(sys.argv[1])
    saida.mkdir(parents=True, exist_ok=True)
    salvar(saida, "snd_amb_noite", em_volta(vento(22, 180, 1)), 0.5)
    salvar(saida, "snd_amb_gotas", gotas(em_volta(vento(24, 70, 0.8))), 0.6)
    salvar(saida, "snd_amb_vento", em_volta(vento(22, 420, 1)), 0.6)
    salvar(saida, "snd_amb_fogo", em_volta(fogo(18)), 0.5)
    salvar(saida, "snd_coracao", coracao(), 0.9)


if __name__ == "__main__":
    main()
