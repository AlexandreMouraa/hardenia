"""Gera os sons dos eventos e das tecnicas (issue #97): bau, portao, tecnica ganha, Furia,
fase do rei, vitoria e o som de cada tecnica. Tudo sai de senos e ruido filtrado, com
semente fixa: rodar de novo da os mesmos arquivos. So usa a biblioteca padrao do Python.

    python3 tools/gerar_sons_eventos.py pasta/de/saida
    python3 tools/importar_recurso.py som snd_nome pasta/de/saida/snd_nome.wav
"""
import math
import pathlib
import random
import sys
import wave

TAXA = 44100


def amostras(dur):
    return int(dur * TAXA)


def ruido(dur, semente):
    g = random.Random(semente)
    return [g.gauss(0, 1) for _ in range(amostras(dur))]


def curva(n, pontos):
    """valor que passa por (posicao de 0 a 1, valor), interpolando em oitavas (valores > 0)"""
    saida = []
    for i in range(n):
        p = i / max(1, n - 1)
        for k in range(len(pontos) - 1):
            (p0, v0), (p1, v1) = pontos[k], pontos[k + 1]
            if p <= p1 or k == len(pontos) - 2:
                u = 0 if p1 == p0 else min(1, max(0, (p - p0) / (p1 - p0)))
                saida.append(math.exp(math.log(v0) + u * (math.log(v1) - math.log(v0))))
                break
    return saida


def faixa(x, freq, q):
    """passa-faixa com a frequencia mudando amostra a amostra (variavel de estado)"""
    baixo = meio = 0.0
    amort = 1.0 / q
    saida = []
    for v, f0 in zip(x, freq):
        f = 2.0 * math.sin(math.pi * min(f0, TAXA / 6.0) / TAXA)
        baixo += f * meio
        alto = v - baixo - amort * meio
        meio += f * alto
        saida.append(meio)
    return saida


def passa_baixa(x, freq):
    y = 0.0
    saida = []
    for v, f in zip(x, freq):
        y += (1.0 - math.exp(-2.0 * math.pi * f / TAXA)) * (v - y)
        saida.append(y)
    return saida


def envelope(n, pico, queda):
    """sobe ate pico (de 0 a 1 da duracao) e cai exponencial; fecha sem estalo no fim"""
    saida = []
    for i in range(n):
        t = i / max(1, n - 1)
        sobe = min(1.0, t / pico) ** 2 if pico > 0 else 1.0
        desce = math.exp(-queda * max(0.0, t - pico))
        fim = min(1.0, (1 - t) / 0.06)
        saida.append(sobe * desce * fim)
    return saida


def tom(dur, freqs, queda, fase=0.0, ataque=0.004):
    """sino ou corda: soma de parciais (freq, peso) que caem com o tempo"""
    n = amostras(dur)
    saida = [0.0] * n
    for k, (f, peso) in enumerate(freqs):
        q = queda * (1 + 0.6 * k)
        for i in range(n):
            t = i / TAXA
            saida[i] += peso * math.sin(2 * math.pi * f * t + fase + 1.3 * k) * math.exp(-q * t)
    a = amostras(ataque)
    for i in range(min(a, n)):
        saida[i] *= i / a
    return saida


def varredura(dur, f0, f1, queda):
    """seno que desliza de f0 para f1: grave de impacto ou assobio"""
    n = amostras(dur)
    fs = curva(n, [(0, f0), (1, f1)])
    fase = 0.0
    saida = []
    for i, f in enumerate(fs):
        fase += 2 * math.pi * f / TAXA
        saida.append(math.sin(fase) * math.exp(-queda * i / TAXA))
    return saida


def mul(x, y):
    return [a * b for a, b in zip(x, y)]


def soma(*partes):
    n = max(len(p) for _, p in partes)
    saida = [0.0] * n
    for peso, p in partes:
        for i, v in enumerate(p):
            saida[i] += peso * v
    return saida


def atrasa(x, seg):
    return [0.0] * amostras(seg) + x


def satura(x, forca):
    m = max(abs(v) for v in x) or 1
    return [math.tanh(forca * v / m) for v in x]


def normaliza(x, pico_db):
    m = max(abs(v) for v in x) or 1
    alvo = 10 ** (pico_db / 20)
    return [v / m * alvo for v in x]


# ---- eventos ----

def bau_abrir():
    # trava que solta, madeira rangendo e um brilho curto: tem coisa la dentro
    trava = mul(ruido(0.04, 21), envelope(amostras(0.04), 0.02, 60))
    trava = faixa(trava, [2600] * len(trava), 3)
    n = amostras(0.42)
    ranger = faixa(ruido(0.42, 22), curva(n, [(0, 380), (1, 720)]), 6)
    pulsos = [0.55 + 0.45 * math.sin(2 * math.pi * 34 * i / TAXA) ** 2 for i in range(n)]
    ranger = mul(mul(ranger, pulsos), envelope(n, 0.3, 4))
    brilho = tom(0.6, [(1760, 1), (2640, 0.5), (3520, 0.25)], 7)
    return normaliza(soma((1.2, trava), (1.0, atrasa(ranger, 0.03)), (0.10, atrasa(brilho, 0.33))), -6)


def portao_abrir():
    # pedra pesada arrastando, com corrente batendo: grave e longo, sem tampar a musica
    dur = 1.15
    n = amostras(dur)
    arrasto = passa_baixa(ruido(dur, 31), curva(n, [(0, 160), (0.5, 260), (1, 120)]))
    tremor = [0.6 + 0.4 * math.sin(2 * math.pi * 11 * i / TAXA + 0.7 * math.sin(2 * math.pi * 3 * i / TAXA)) for i in range(n)]
    arrasto = mul(mul(arrasto, tremor), envelope(n, 0.25, 2.2))
    corrente = [0.0] * n
    g = random.Random(32)
    pos = 0.05
    while pos < dur - 0.1:
        ini = amostras(pos)
        f = g.uniform(2300, 3400)
        for i in range(amostras(0.05)):
            if ini + i < n:
                corrente[ini + i] += math.sin(2 * math.pi * f * i / TAXA) * math.exp(-90 * i / TAXA)
        pos += g.uniform(0.07, 0.16)
    baque = varredura(0.4, 70, 45, 9)
    return normaliza(soma((3.0, arrasto), (0.10, corrente), (0.6, atrasa(baque, dur - 0.4))), -7)


def tecnica_ganha():
    # sino claro de tres notas juntas. O jogo toca mais grave ou mais agudo para cada Caido
    sino = tom(1.0, [(660, 1), (990, 0.55), (1320, 0.35), (1822, 0.15)], 3.2)
    sopro = mul(faixa(ruido(1.0, 41), [2200] * amostras(1.0), 2), envelope(amostras(1.0), 0.15, 6))
    return normaliza(soma((1.0, sino), (0.08, sopro)), -6)


def furia_cheia():
    # sopro que sobe e fecha num anel: a barra encheu
    n = amostras(0.55)
    sopro = mul(faixa(ruido(0.55, 51), curva(n, [(0, 300), (1, 2600)]), 2.5), envelope(n, 0.85, 8))
    anel = tom(0.6, [(1100, 1), (1650, 0.6), (2200, 0.3)], 6)
    return normaliza(soma((1.0, sopro), (0.22, atrasa(anel, 0.45))), -6)


def furia_solta():
    # o golpe da Furia: estouro grave e um rugido de ar por baixo do som de cada arma
    dur = 0.75
    n = amostras(dur)
    estouro = varredura(dur, 95, 38, 5)
    rugido = mul(passa_baixa(ruido(dur, 61), curva(n, [(0, 2200), (0.3, 700), (1, 200)])), envelope(n, 0.05, 4.5))
    return normaliza(satura(soma((1.0, estouro), (2.2, rugido)), 1.8), -3)


def rei_fase():
    # gongo grave e longo: o rei muda de fase
    gongo = tom(2.2, [(82, 1), (164.5, 0.6), (226, 0.45), (443, 0.25), (611, 0.12)], 1.2, ataque=0.01)
    n = amostras(2.2)
    ronco = mul(passa_baixa(ruido(2.2, 71), [120] * n), envelope(n, 0.1, 2.5))
    return normaliza(soma((1.0, gongo), (2.5, ronco)), -3)


def vitoria():
    # quatro sinos subindo (do, mi, sol, do) e o ultimo fica soando
    notas = [523.25, 659.25, 783.99, 1046.5]
    partes = []
    for k, f in enumerate(notas):
        dur = 2.4 - 0.28 * k
        partes.append((1.0 if k < 3 else 1.3, atrasa(tom(dur, [(f, 1), (2 * f, 0.3), (2.76 * f, 0.12)], 1.6), 0.28 * k)))
    return normaliza(soma(*partes), -5)


# ---- tecnicas ----

def sangria():
    # gota curta e baixa: toca muitas vezes, entao precisa ser discreta
    gota = varredura(0.09, 1100, 320, 30)
    return normaliza(mul(gota, envelope(len(gota), 0.05, 6)), -14)


def execucao():
    # golpe de carrasco: baque grave, estalo seco e o anel do metal
    dur = 0.65
    baque = varredura(dur, 130, 48, 7)
    estalo = mul(ruido(dur, 81), [math.exp(-260 * i / TAXA) for i in range(amostras(dur))])
    anel = tom(dur, [(2210, 1), (3315, 0.6), (4980, 0.3)], 9)
    return normaliza(satura(soma((1.0, baque), (0.6, estalo), (0.18, anel)), 1.4), -3)


def passo_cortante():
    # corte rapido e agudo ao atravessar
    n = amostras(0.14)
    corte = mul(faixa(ruido(0.14, 91), curva(n, [(0, 2800), (1, 6500)]), 2.2), envelope(n, 0.2, 9))
    brilho = tom(0.14, [(5200, 1), (7400, 0.5)], 40)
    return normaliza(soma((1.0, corte), (0.12, brilho)), -8)


def ultimo_instante():
    # o tempo desacelerando: um sopro que cresce ao contrario e um grave que desce devagar
    dur = 1.0
    n = amostras(dur)
    inverso = [min(1.0, (i / n) / 0.35) ** 3 * math.exp(-5 * max(0, i / n - 0.35)) * min(1.0, (n - i) / (0.06 * n)) for i in range(n)]
    sopro = mul(faixa(ruido(dur, 101), curva(n, [(0, 1800), (0.35, 600), (1, 220)]), 2), inverso)
    grave = mul(varredura(dur, 420, 110, 1.5), inverso)
    batida = varredura(0.25, 60, 40, 18)
    return normaliza(soma((1.0, sopro), (0.5, grave), (0.6, atrasa(batida, 0.33))), -5)


def retribuicao():
    # onda de choque: baque grave e ar que se espalha
    dur = 0.55
    n = amostras(dur)
    baque = varredura(dur, 75, 40, 8)
    onda = mul(faixa(ruido(dur, 111), curva(n, [(0, 1600), (1, 280)]), 1.6), envelope(n, 0.08, 5))
    return normaliza(soma((1.0, baque), (1.1, onda)), -4)


SONS = {
    "snd_bau_abrir": bau_abrir,
    "snd_portao_abrir": portao_abrir,
    "snd_tecnica_ganha": tecnica_ganha,
    "snd_furia_cheia": furia_cheia,
    "snd_furia_solta": furia_solta,
    "snd_rei_fase": rei_fase,
    "snd_vitoria": vitoria,
    "snd_sangria": sangria,
    "snd_execucao": execucao,
    "snd_passo_cortante": passo_cortante,
    "snd_ultimo_instante": ultimo_instante,
    "snd_retribuicao": retribuicao,
}


def grava(pasta, nome, x):
    dados = bytearray()
    for v in x:
        dados += int(max(-1.0, min(1.0, v)) * 32767).to_bytes(2, "little", signed=True)
    with wave.open(str(pasta / (nome + ".wav")), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(TAXA)
        w.writeframes(bytes(dados))


def principal():
    pasta = pathlib.Path(sys.argv[1])
    pasta.mkdir(parents=True, exist_ok=True)
    so = set(sys.argv[2:])
    for nome, fazer in SONS.items():
        if not so or nome in so:
            grava(pasta, nome, fazer())
            print(nome)


if __name__ == "__main__":
    principal()
