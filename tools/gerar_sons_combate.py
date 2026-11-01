"""Gera os sons de combate do jogo: golpes, flecha, bomba e explosao. Saem de ruido
filtrado e senos, com semente fixa, entao rodar de novo da os mesmos arquivos. So o
snd_acerto usa um som de fora: o impactPunch_medium_000 do Kenney, em WAV mono de 44,1 kHz.

    python3 tools/gerar_sons_combate.py pasta/de/saida impactPunch_medium_000.wav
    python3 tools/importar_recurso.py som snd_nome pasta/de/saida/snd_nome.wav

Precisa de numpy.
"""
import pathlib
import sys
import wave

import numpy as np

TAXA = 44100


def tempo(dur):
    return np.arange(int(dur * TAXA)) / TAXA


def ruido(dur, semente):
    return np.random.default_rng(semente).normal(0, 1, int(dur * TAXA))


def faixa(x, freq, q):
    """filtro passa-faixa com a frequencia mudando amostra a amostra (variavel de estado)"""
    baixo = 0.0
    meio = 0.0
    saida = np.zeros(len(x))
    amort = 1.0 / q
    for i, v in enumerate(x):
        f = 2.0 * np.sin(np.pi * min(freq[i], TAXA / 6.0) / TAXA)
        baixo += f * meio
        alto = v - baixo - amort * meio
        meio += f * alto
        saida[i] = meio
    return saida


def passa_baixa(x, freq):
    y = 0.0
    saida = np.zeros(len(x))
    for i, v in enumerate(x):
        a = 1.0 - np.exp(-2.0 * np.pi * freq[i] / TAXA)
        y += a * (v - y)
        saida[i] = y
    return saida


def rampa(n, pontos):
    """curva que passa por (posicao de 0 a 1, valor), interpolando na escala de oitavas"""
    pos = [p[0] for p in pontos]
    val = np.log([p[1] for p in pontos])
    return np.exp(np.interp(np.linspace(0, 1, n), pos, val))


def envelope(n, pico, queda):
    """sobe rapido ate pico (de 0 a 1) e cai exponencial; queda maior = some mais rapido"""
    t = np.linspace(0, 1, n)
    sobe = np.clip(t / pico, 0, 1) ** 2
    desce = np.exp(-queda * np.clip(t - pico, 0, None))
    fim = np.clip((1 - t) / 0.08, 0, 1)
    return sobe * desce * fim


def corte(dur, pontos, q, pico, queda, semente):
    """o ar cortado por um golpe: ruido numa faixa que sobe e desce"""
    x = ruido(dur, semente)
    return faixa(x, rampa(len(x), pontos), q) * envelope(len(x), pico, queda)


def lamina(dur, inicio, freqs, queda, semente):
    """brilho curto de metal: parciais que nao sao multiplos uma da outra"""
    t = tempo(dur)
    s = np.zeros(len(t))
    for k, f in enumerate(freqs):
        fase = 1.7 * k + semente
        s += np.sin(2 * np.pi * f * t + fase) / (k + 1)
    env = np.exp(-queda * np.clip(t - inicio, 0, None)) * (t >= inicio)
    return s * env


def corpo(dur, f0, f1, queda):
    """grave que da peso: seno que desce de f0 para f1"""
    t = tempo(dur)
    f = rampa(len(t), [(0, f0), (1, f1)])
    fase = 2 * np.pi * np.cumsum(f) / TAXA
    return np.sin(fase) * np.exp(-queda * t)


def normaliza(x, pico_db):
    return x / np.max(np.abs(x)) * 10 ** (pico_db / 20)


def golpe():
    # golpe comum: corte curto, para combinar com o ritmo do combo
    a = corte(0.17, [(0, 700), (0.4, 2600), (1, 900)], 1.3, 0.35, 7, 1)
    b = lamina(0.17, 0.05, [3100, 4700, 6300], 45, 1)
    return normaliza(a + 0.10 * b, -7)


def golpe_forte():
    # terceiro golpe e golpe carregado: mais longo, mais grave, com peso no fim
    a = corte(0.30, [(0, 350), (0.45, 1800), (1, 450)], 1.0, 0.4, 5, 2)
    b = lamina(0.30, 0.10, [2400, 3700, 5200], 30, 2)
    c = corpo(0.30, 130, 70, 8)
    return normaliza(a + 0.10 * b + 0.45 * c, -4)


def giro():
    # giro: duas passadas seguidas, como uma lamina dando a volta
    x = ruido(0.44, 3)
    f = rampa(len(x), [(0, 450), (0.25, 1900), (0.5, 600), (0.75, 2100), (1, 500)])
    t = np.linspace(0, 1, len(x))
    lobos = np.sin(np.pi * np.clip(t * 2, 0, 1)) ** 2 + 0.9 * np.sin(np.pi * np.clip(t * 2 - 1, 0, 1)) ** 2
    c = corpo(0.44, 110, 75, 6)
    return normaliza(faixa(x, f, 1.1) * lobos + 0.3 * c, -5)


def estocada():
    # estocada: risco agudo e direto, com um brilho de metal
    a = corte(0.13, [(0, 1500), (1, 4300)], 2.0, 0.25, 8, 4)
    b = lamina(0.13, 0.015, [3400, 5100, 7300], 40, 4)
    return normaliza(a + 0.2 * b, -6)


def inimigo_golpe():
    # golpe de inimigo: mais grave e abafado que o do jogador, para o ouvido separar os dois
    a = corte(0.24, [(0, 260), (0.4, 1000), (1, 320)], 0.9, 0.4, 6, 5)
    c = corpo(0.24, 95, 60, 10)
    return normaliza(a + 0.35 * c, -8)


def flecha():
    # corda solta (grave que vibra e some) e a flecha cortando o ar
    t = tempo(0.22)
    f = rampa(len(t), [(0, 240), (1, 170)])
    fase = 2 * np.pi * np.cumsum(f) / TAXA
    corda = sum(np.sin(k * fase) / k for k in range(1, 6)) * np.exp(-26 * t)
    estalo = ruido(0.22, 6) * np.exp(-420 * t)
    ar = corte(0.22, [(0, 3200), (1, 1200)], 1.6, 0.12, 9, 7)
    return normaliza(corda + 0.5 * estalo + 0.45 * ar, -6)


def bomba_cai():
    # assobio que desce, ficando mais forte ate a queda. Termina antes do chao: o estouro e outro som
    dur = 0.92
    t = tempo(dur)
    f = rampa(len(t), [(0, 1700), (1, 520)])
    fase = 2 * np.pi * np.cumsum(f) / TAXA
    forca = (t / dur) ** 1.6 * np.clip((dur - t) / 0.03, 0, 1)
    ar = faixa(ruido(dur, 8), f, 3) * forca
    return normaliza(np.sin(fase) * forca + 0.25 * ar, -11)


def explosao():
    # estouro seco, massa grave e cauda que abafa. tanh: saturacao, como um estouro de verdade
    dur = 0.85
    t = tempo(dur)
    n = len(t)
    baque = corpo(dur, 105, 38, 6)
    corpo_ruido = passa_baixa(ruido(dur, 9), rampa(n, [(0, 3400), (0.25, 900), (1, 180)])) * np.exp(-4.8 * t)
    estalo = ruido(dur, 10) * np.exp(-240 * t)
    x = baque + 2.4 * corpo_ruido + 0.5 * estalo
    x = np.tanh(1.6 * x / np.max(np.abs(x)))
    x *= np.clip((dur - t) / 0.05, 0, 1)
    return normaliza(x, -1.5)


def acerto(base):
    # o impacto do Kenney com uma ponta seca por cima: som de corte, e nao so de soco
    with wave.open(str(base)) as w:
        x = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16) / 32768.0
    t = np.arange(len(x)) / TAXA
    ponta = np.random.default_rng(11).normal(0, 1, len(x)) * np.exp(-150 * t)
    # so o agudo da ponta: a diferenca de uma amostra para a outra
    ponta = np.diff(ponta, prepend=0.0)
    return normaliza(x / np.max(np.abs(x)) + 0.28 * ponta, -3.5)


def grava(pasta, nome, x):
    dados = (np.clip(x, -1, 1) * 32767).astype(np.int16)
    with wave.open(str(pasta / (nome + ".wav")), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(TAXA)
        w.writeframes(dados.tobytes())


def principal():
    pasta = pathlib.Path(sys.argv[1])
    pasta.mkdir(parents=True, exist_ok=True)
    grava(pasta, "snd_attack", golpe())
    grava(pasta, "snd_golpe_forte", golpe_forte())
    grava(pasta, "snd_giro", giro())
    grava(pasta, "snd_estocada", estocada())
    grava(pasta, "snd_inimigo_golpe", inimigo_golpe())
    grava(pasta, "snd_flecha", flecha())
    grava(pasta, "snd_bomba_cai", bomba_cai())
    grava(pasta, "snd_explosao", explosao())
    grava(pasta, "snd_acerto", acerto(sys.argv[2]))


if __name__ == "__main__":
    principal()
