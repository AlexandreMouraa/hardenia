"""Gera a voz dos inimigos (#96): para cada tipo, um som ao notar o jogador, um antes do golpe
e uma morte. Rosnados e sopros saem de pulsos e ruido filtrados em formantes, com semente fixa,
entao rodar de novo da os mesmos arquivos. Ossos, armadura e vidro usam amostras do Kenney
(CC0, ver docs/CREDITOS_ASSETS.md), em WAV mono de 44,1 kHz.

    python3 tools/gerar_sons_vozes.py pasta/de/saida pasta/kenney-wav
    python3 tools/importar_recurso.py som snd_voz_x pasta/de/saida/snd_voz_x.wav

pasta/kenney-wav tem as subpastas impact-sounds e rpg-audio, com os .ogg dos dois pacotes
convertidos para WAV. Um nome no fim gera so aquele som:

    python3 tools/gerar_sons_vozes.py saida kenney-wav snd_voz_ghoul_notar

Precisa de numpy.
"""
import pathlib
import sys
import wave

import numpy as np

TAXA = 44100
KENNEY = None
_cache = {}


# ---------- pecas ----------
def n_de(dur):
    return int(dur * TAXA)


def rampa(n, pontos):
    """curva que passa por (posicao de 0 a 1, valor), interpolando na escala de oitavas"""
    pos = [p[0] for p in pontos]
    val = np.log([p[1] for p in pontos])
    return np.exp(np.interp(np.linspace(0, 1, n), pos, val))


def contorno(n, pontos):
    """volume ao longo do som: (posicao de 0 a 1, valor), em linha reta entre os pontos"""
    return np.interp(np.linspace(0, 1, n), [p[0] for p in pontos], [p[1] for p in pontos])


def lento(rng, n, hz):
    """ruido lento, de -1 a 1: um ponto sorteado a cada 1/hz s, ligados por curva suave"""
    k = max(2, int(n / TAXA * hz) + 2)
    pts = rng.uniform(-1, 1, k)
    pos = np.linspace(0, k - 1.001, n)
    i = np.floor(pos).astype(int)
    t = pos - i
    t = t * t * (3 - 2 * t)
    return pts[i] * (1 - t) + pts[i + 1] * t


def svf(x, freq, q, saida="faixa"):
    """filtro de variavel de estado; freq pode mudar amostra a amostra. A faixa sai com
    ganho 1 na ressonancia"""
    n = len(x)
    f = np.full(n, float(freq)) if np.isscalar(freq) else np.asarray(freq, dtype=float)
    fl = (2.0 * np.sin(np.pi * np.minimum(f, TAXA / 6.5) / TAXA)).tolist()
    xl = np.asarray(x, dtype=float).tolist()
    amort = 1.0 / q
    baixo = 0.0
    meio = 0.0
    out = [0.0] * n
    if saida == "faixa":
        for i in range(n):
            fi = fl[i]
            baixo += fi * meio
            alto = xl[i] - baixo - amort * meio
            meio += fi * alto
            out[i] = meio
        return np.array(out) * amort
    if saida == "baixa":
        for i in range(n):
            fi = fl[i]
            baixo += fi * meio
            alto = xl[i] - baixo - amort * meio
            meio += fi * alto
            out[i] = baixo
        return np.array(out)
    for i in range(n):
        fi = fl[i]
        baixo += fi * meio
        alto = xl[i] - baixo - amort * meio
        meio += fi * alto
        out[i] = alto
    return np.array(out)


def baixa(x, freq):
    return svf(x, freq, 0.707, "baixa")


def alta(x, freq):
    return svf(x, freq, 0.707, "alta")


def pente(x, atraso, ganho):
    """eco curto que realimenta: da o som oco de elmo, ou a cauda de uma sala"""
    y = np.array(x, dtype=float)
    for i in range(atraso, len(y), atraso):
        trecho = y[i:i + atraso]
        trecho += ganho * y[i - atraso:i][:len(trecho)]
    return y


def passa_tudo(x, atraso, ganho):
    y = np.zeros(len(x))
    for i in range(0, len(x), atraso):
        a = x[i:i + atraso]
        if i >= atraso:
            y[i:i + atraso] = -ganho * a + x[i - atraso:i][:len(a)] + ganho * y[i - atraso:i][:len(a)]
        else:
            y[i:i + atraso] = -ganho * a
    return y


def sala(x, cauda, mistura, escuro=3800):
    """reverberacao simples (4 pentes e 2 passa-tudo): cauda em segundos ate sumir"""
    xx = np.concatenate([x, np.zeros(n_de(cauda * 1.1))])
    # o grave fundo nao entra na sala: ele cai perto da ressonancia dos pentes e nao some mais
    entrada = alta(xx, 140)
    molhado = np.zeros(len(xx))
    for atraso in (1557, 1617, 1491, 1422):
        molhado += pente(entrada, atraso, 10 ** (-3.0 * atraso / TAXA / cauda))
    molhado = passa_tudo(passa_tudo(molhado / 4, 556, 0.5), 441, 0.5)
    molhado = baixa(molhado, escuro)
    return xx + mistura * molhado


def degraus(rng, n, hz):
    """ruido em degraus, de -1 a 1: um valor novo a cada 1/hz s (cada pulso da voz com o seu)"""
    k = max(2, int(n / TAXA * hz) + 2)
    return rng.uniform(-1, 1, k)[np.minimum((np.arange(n) * hz / TAXA).astype(int), k - 1)]


def rosnado(dur, f0, formantes, semente, aspereza=0.5, sopro=0.15, jitter=0.03, garra=2.0, teto=4500):
    """voz de bicho: pulsos graves irregulares passando por formantes.
    f0 e cada formante: lista de (posicao, Hz). formantes: (curva, q, ganho).
    aspereza: quanto um pulso difere do outro em forca e em tempo, e o quanto cada segundo
    pulso some (a voz "quebra" uma oitava abaixo); sem isso soa como motor. sopro: quanto de
    ar. garra: saturacao. teto: corta o chiado acima disso"""
    n = n_de(dur)
    rng = np.random.default_rng(semente)
    f = rampa(n, f0)
    f = f * (1 + jitter * lento(rng, n, 13) + 0.10 * aspereza * degraus(rng, n, float(np.mean(f))))
    fase = np.cumsum(f) / TAXA
    ciclo = np.floor(fase).astype(int)
    frac = fase - ciclo
    pulso = (1 - frac) ** 3 - 0.25
    forca = 1 + 0.4 * aspereza * rng.normal(0, 1, ciclo[-1] + 2)
    dobra = 1 - 0.55 * aspereza * (ciclo % 2)
    fonte = pulso * forca[ciclo] * dobra
    fonte = (1 - sopro) * fonte + sopro * 0.6 * rng.normal(0, 1, n) * (0.4 + 0.6 * (1 - frac))
    y = np.zeros(n)
    for curva, q, ganho in formantes:
        y += ganho * svf(fonte, rampa(n, curva), q)
    y = y / np.max(np.abs(y))
    return baixa(np.tanh(garra * y) / np.tanh(garra), teto)


def sopro_faixa(dur, freq, q, semente):
    """ar: ruido numa faixa que anda (chiado, sussurro, vento)"""
    n = n_de(dur)
    x = np.random.default_rng(semente).normal(0, 1, n)
    y = svf(x, rampa(n, freq), q)
    return y / np.max(np.abs(y))


def amostra(pacote, nome):
    chave = pacote + "/" + nome
    if chave not in _cache:
        with wave.open(str(KENNEY / pacote / (nome + ".wav"))) as w:
            assert w.getframerate() == TAXA and w.getnchannels() == 1 and w.getsampwidth() == 2, chave
            x = np.frombuffer(w.readframes(w.getnframes()), dtype="<i2").astype(float) / 32768.0
        _cache[chave] = x / np.max(np.abs(x))
    return _cache[chave]


def afinar(x, fator):
    """fator acima de 1: mais agudo e mais curto"""
    n = int(len(x) / fator)
    return np.interp(np.arange(n) * fator, np.arange(len(x)), x)


def aparar(x, dur, some=0.02):
    """corta em dur, sumindo no fim"""
    y = np.array(x[:n_de(dur)], dtype=float)
    k = min(len(y), n_de(some))
    y[-k:] *= np.linspace(1, 0, k)
    return y


def camadas(dur, itens):
    """soma os sons, cada um comecando em inicio (s) com o seu ganho"""
    y = np.zeros(n_de(dur))
    for inicio, s, ganho in itens:
        a = n_de(inicio)
        b = min(len(y), a + len(s))
        if b > a:
            y[a:b] += ganho * s[:b - a]
    return y


def depois_do_sino(x):
    """o Caido e o rei falam ao entrar em cena, junto do sino: a voz espera a batida passar"""
    return np.concatenate([np.zeros(n_de(0.35)), x])


def acabar(x, pico_db, entra_ms=2, sai_ms=30, rms_db=None):
    """tira o desvio e o silencio do fim, some nas pontas (sem estalo) e leva ao pico pedido.
    rms_db: teto do volume medio; voz sustentada com o mesmo pico de um estalo soa bem mais alta"""
    y = x - np.mean(x)
    y = y / np.max(np.abs(y))
    # o que sobra abaixo de -52 dB no fim (cauda da sala) so pesa no arquivo
    alto = np.nonzero(np.abs(y) > 0.0025)[0]
    y = y[:min(len(y), alto[-1] + n_de(0.03))]
    a = n_de(entra_ms / 1000)
    b = min(len(y), n_de(sai_ms / 1000))
    y[:a] *= np.linspace(0, 1, a)
    y[-b:] *= np.linspace(1, 0, b) ** 2
    y = y / np.max(np.abs(y)) * 10 ** (pico_db / 20)
    if rms_db is not None:
        rms = 20 * np.log10(np.sqrt(np.mean(y ** 2)))
        if rms > rms_db:
            y *= 10 ** ((rms_db - rms) / 20)
    return y


def osso(k, tom):
    """um osso batendo: a madeira leve do Kenney sem o grave, afinada"""
    return alta(afinar(amostra("impact-sounds", "impactWood_light_00%d" % (k % 5)), tom), 420)


# ---------- esqueleto: ossos ----------
def esqueleto_notar():
    # o queixo bate: cinco estalos acelerando e subindo, como um "ei!"
    tempos = [0.0, 0.075, 0.135, 0.18, 0.215, 0.24]
    itens = [(t, aparar(osso(i, 1.45 + 0.13 * i), 0.09), 0.55 + 0.09 * i) for i, t in enumerate(tempos)]
    return acabar(camadas(0.36, itens), -6)


def esqueleto_aviso():
    # os ossos retesam: rolo curto de estalos descendo, e um rangido por baixo
    itens = [(0.028 * i, aparar(osso(i + 2, 2.1 - 0.12 * i), 0.06), 0.35 + 0.08 * i) for i in range(7)]
    range_ = aparar(afinar(amostra("rpg-audio", "creak3"), 1.25), 0.3)
    itens.append((0.0, range_, 0.5))
    return acabar(camadas(0.33, itens), -8)


def esqueleto_morte():
    # desmonta: estalos espalhados caindo de tom, os ultimos graves (tabua)
    tempos = [0.04, 0.09, 0.15, 0.19, 0.26, 0.31, 0.39, 0.47]
    itens = [(t, aparar(osso(i + 1, 1.9 - 0.14 * i), 0.12), 0.9 - 0.07 * i) for i, t in enumerate(tempos)]
    tabua = alta(afinar(amostra("impact-sounds", "impactPlank_medium_001"), 1.3), 250)
    itens.append((0.20, aparar(tabua, 0.3, 0.1), 0.5))
    itens.append((0.43, aparar(afinar(tabua, 0.8), 0.25, 0.1), 0.35))
    return acabar(camadas(0.72, itens), -5, sai_ms=60)


# ---------- ghoul: rosnado molhado ----------
def ghoul_notar():
    # rosnado curto que sobe: "grrah"
    n = n_de(0.46)
    v = rosnado(0.46, [(0, 88), (0.45, 150), (1, 118)],
                [([(0, 560), (0.5, 780), (1, 640)], 5, 1.0), ([(0, 1150), (0.5, 1550), (1, 1300)], 7, 0.7), ([(0, 2700), (1, 2900)], 8, 0.3)],
                11, aspereza=0.75, sopro=0.2, garra=2.6)
    v *= contorno(n, [(0, 0), (0.07, 1), (0.55, 0.9), (1, 0)])
    chiado = sopro_faixa(0.46, [(0, 2600), (1, 4200)], 2.5, 12) * contorno(n, [(0, 0), (0.3, 0.5), (0.8, 0.25), (1, 0)])
    return acabar(v + 0.16 * chiado, -5, rms_db=-21)


def ghoul_aviso():
    # puxa o ar antes do bote: chiado e voz subindo depressa
    n = n_de(0.36)
    v = rosnado(0.36, [(0, 150), (0.8, 330), (1, 380)],
                [([(0, 700), (1, 1050)], 5, 1.0), ([(0, 1700), (1, 2300)], 7, 0.8), ([(0, 3100), (1, 3500)], 8, 0.4)],
                13, aspereza=0.85, sopro=0.35, garra=2.4)
    v *= contorno(n, [(0, 0), (0.25, 0.35), (0.85, 1), (1, 0)])
    ar = sopro_faixa(0.36, [(0, 1400), (1, 4600)], 3, 14) * contorno(n, [(0, 0), (0.6, 0.7), (0.9, 1), (1, 0)])
    return acabar(0.8 * v + 0.35 * ar, -7, rms_db=-22)


def ghoul_morte():
    # gorgolejo caindo: a voz desce e borbulha
    n = n_de(0.62)
    v = rosnado(0.62, [(0, 165), (0.3, 120), (1, 52)],
                [([(0, 700), (1, 340)], 5, 1.0), ([(0, 1400), (1, 800)], 6, 0.7), ([(0, 2600), (1, 1900)], 8, 0.2)],
                15, aspereza=0.9, sopro=0.25, garra=2.8)
    rng = np.random.default_rng(16)
    bolha = 0.55 + 0.45 * np.sign(lento(rng, n, 21)) * contorno(n, [(0, 0.2), (0.4, 1), (1, 1)])
    bolha = baixa(bolha, 90)
    v *= bolha * contorno(n, [(0, 0), (0.05, 1), (0.5, 0.75), (1, 0)])
    corpo = aparar(baixa(amostra("impact-sounds", "impactSoft_heavy_001"), 900), 0.4, 0.2)
    return acabar(camadas(0.62, [(0, v, 1.0), (0.3, corpo, 0.3)]), -5, sai_ms=80, rms_db=-21)


# ---------- wight: sopro frio ----------
def wight_notar():
    # gemido grave e lento, com vento por cima
    n = n_de(0.85)
    v = rosnado(0.85, [(0, 80), (0.45, 93), (1, 74)],
                [([(0, 290), (0.5, 340), (1, 280)], 5, 1.0), ([(0, 680), (0.5, 760), (1, 640)], 6, 0.55), ([(0, 2300), (1, 2200)], 8, 0.08)],
                21, aspereza=0.3, sopro=0.3, jitter=0.02, garra=1.6)
    v *= contorno(n, [(0, 0), (0.22, 0.8), (0.55, 1), (1, 0)])
    vento = sopro_faixa(0.85, [(0, 520), (0.5, 900), (1, 600)], 2.2, 22) * contorno(n, [(0, 0), (0.4, 0.6), (0.7, 0.5), (1, 0)])
    return acabar(sala(v + 0.3 * vento, 0.5, 0.2), -6, entra_ms=20, sai_ms=120, rms_db=-22)


def wight_aviso():
    # inspira fundo antes da varredura: o ar sobe e a voz vem junto
    n = n_de(0.62)
    ar = sopro_faixa(0.62, [(0, 300), (0.8, 1300), (1, 1500)], 2.6, 23) * contorno(n, [(0, 0), (0.5, 0.45), (0.9, 1), (1, 0)])
    v = rosnado(0.62, [(0, 62), (1, 108)],
                [([(0, 300), (1, 420)], 5, 1.0), ([(0, 700), (1, 950)], 6, 0.5)],
                24, aspereza=0.35, sopro=0.3, jitter=0.02, garra=1.6)
    v *= contorno(n, [(0, 0), (0.4, 0.4), (0.92, 1), (1, 0)])
    return acabar(0.75 * ar + 0.6 * v, -8, entra_ms=20, rms_db=-23)


def wight_morte():
    # solta o ar de vez: gemido que cai e se desfaz
    n = n_de(0.95)
    v = rosnado(0.95, [(0, 108), (0.2, 96), (1, 44)],
                [([(0, 430), (1, 250)], 5, 1.0), ([(0, 900), (1, 600)], 6, 0.5), ([(0, 2300), (1, 1800)], 8, 0.08)],
                25, aspereza=0.45, sopro=0.45, jitter=0.03, garra=1.8)
    v *= contorno(n, [(0, 0), (0.05, 1), (0.4, 0.7), (1, 0)])
    vento = sopro_faixa(0.95, [(0, 1100), (1, 380)], 2.0, 26) * contorno(n, [(0, 0), (0.15, 0.7), (1, 0)])
    return acabar(sala(v + 0.35 * vento, 0.7, 0.25), -5, sai_ms=150, rms_db=-21)


# ---------- conjurador: sussurro e vidro ----------
def brilho(dur, freqs, semente):
    """parciais agudas que tremem: a magia dele"""
    n = n_de(dur)
    t = np.arange(n) / TAXA
    s = np.zeros(n)
    for k, f in enumerate(freqs):
        s += np.sin(2 * np.pi * f * t + 1.9 * k + semente) * (0.6 + 0.4 * np.sin(2 * np.pi * (5.5 + 1.3 * k) * t)) / (k + 1)
    return s / np.max(np.abs(s))


def conjurador_notar():
    # sussurro: "sshaa", com um brilho no fim
    n = n_de(0.5)
    s = alta(sopro_faixa(0.5, [(0, 5200), (1, 4200)], 1.2, 31), 3000) * contorno(n, [(0, 0), (0.08, 1), (0.3, 0.3), (1, 0)])
    a1 = sopro_faixa(0.5, [(0, 520), (0.6, 880), (1, 760)], 6, 32)
    a2 = sopro_faixa(0.5, [(0, 1900), (0.6, 1350), (1, 1250)], 7, 33)
    a = (a1 + 0.8 * a2) * contorno(n, [(0, 0), (0.25, 0.2), (0.5, 1), (1, 0)])
    b = brilho(0.5, [2093, 3136, 4186], 3) * contorno(n, [(0, 0), (0.5, 0), (0.75, 1), (1, 0)])
    return acabar(0.5 * s + 1.0 * a + 0.12 * b, -9, entra_ms=8, sai_ms=80)


def conjurador_aviso():
    # entoa duas silabas graves, e o brilho cresce por cima (a bomba ja tem o proprio assobio)
    n = n_de(0.48)
    v = rosnado(0.48, [(0, 112), (0.5, 108), (1, 124)],
                [([(0, 380), (0.45, 400), (0.55, 720), (1, 760)], 6, 1.0), ([(0, 820), (0.45, 850), (0.55, 1250), (1, 1300)], 7, 0.6)],
                34, aspereza=0.15, sopro=0.3, jitter=0.015, garra=1.4)
    v *= contorno(n, [(0, 0), (0.1, 0.9), (0.42, 0.5), (0.5, 0.25), (0.6, 1), (1, 0)])
    b = brilho(0.48, [1760, 2637, 3520], 5) * contorno(n, [(0, 0), (0.7, 0.6), (0.95, 1), (1, 0)])
    return acabar(v + 0.14 * b, -9, entra_ms=8)


def conjurador_morte():
    # grito fino que cai, o vidro quebra e sobra um sussurro
    n = n_de(0.7)
    g = rosnado(0.34, [(0, 1050), (1, 360)],
                [([(0, 1200), (1, 800)], 5, 1.0), ([(0, 2600), (1, 1900)], 6, 0.7)],
                35, aspereza=0.35, sopro=0.3, garra=1.8)
    g *= contorno(len(g), [(0, 0), (0.06, 1), (0.6, 0.7), (1, 0)])
    vidro = aparar(afinar(amostra("impact-sounds", "impactGlass_medium_002"), 1.15), 0.4, 0.15)
    s = sopro_faixa(0.45, [(0, 2400), (1, 900)], 3, 36) * contorno(n_de(0.45), [(0, 0), (0.2, 1), (1, 0)])
    return acabar(camadas(0.7, [(0, g, 0.8), (0.08, vidro, 0.6), (0.22, s, 0.3)]), -6, sai_ms=90)


# ---------- horda: leve, para tocar muitas vezes ----------
def horda_notar():
    # dois guinchos curtos
    def guincho(semente, f_a, f_b):
        v = rosnado(0.07, [(0, f_a), (1, f_b)], [([(0, 1300), (1, 1700)], 5, 1.0), ([(0, 2800), (1, 3100)], 7, 0.5)],
                    semente, aspereza=0.5, sopro=0.3, garra=2.0)
        return v * contorno(len(v), [(0, 0), (0.15, 1), (0.6, 0.7), (1, 0)])
    return acabar(camadas(0.2, [(0, guincho(41, 420, 620), 0.8), (0.1, guincho(42, 480, 700), 1.0)]), -12, sai_ms=15)


def horda_morte():
    # estouro miudo: a voz despenca e um ossinho estala
    v = rosnado(0.1, [(0, 520), (1, 170)], [([(0, 1200), (1, 600)], 5, 1.0), ([(0, 2500), (1, 1500)], 7, 0.4)],
                43, aspereza=0.6, sopro=0.3, garra=2.2)
    v *= contorno(len(v), [(0, 0), (0.1, 1), (1, 0)])
    return acabar(camadas(0.16, [(0, v, 0.9), (0.02, aparar(osso(3, 2.3), 0.06), 0.5)]), -12, sai_ms=15)


# ---------- Caidos: gente de armadura. O jogo toca cada um num tom (scr_vozes) ----------
def elmo(x):
    """a voz por dentro do elmo: oca"""
    return 0.6 * x + 0.4 * pente(x, 96, 0.55) / 1.6


def caido_notar():
    # a armadura assenta e ele respira fundo
    placa = aparar(afinar(amostra("impact-sounds", "impactPlate_heavy_000"), 0.82), 0.45, 0.2)
    metal = aparar(afinar(amostra("impact-sounds", "impactMetal_heavy_001"), 0.7), 0.4, 0.2)
    n = n_de(0.62)
    v = rosnado(0.62, [(0, 70), (0.4, 64), (1, 56)],
                [([(0, 400), (1, 340)], 5, 1.0), ([(0, 980), (1, 860)], 6, 0.5), ([(0, 2400), (1, 2200)], 8, 0.1)],
                51, aspereza=0.55, sopro=0.4, garra=2.0)
    v = elmo(v) * contorno(n, [(0, 0), (0.2, 1), (0.6, 0.7), (1, 0)])
    return depois_do_sino(acabar(sala(camadas(0.9, [(0, placa, 0.55), (0.03, metal, 0.3), (0.16, v, 0.9)]), 0.5, 0.18), -5, sai_ms=120, rms_db=-21))


def caido_aviso():
    # o esforco antes do golpe, e o ferro raspando
    n = n_de(0.32)
    v = rosnado(0.32, [(0, 92), (0.5, 132), (1, 100)],
                [([(0, 520), (0.5, 700), (1, 560)], 5, 1.0), ([(0, 1150), (0.5, 1400), (1, 1200)], 6, 0.6), ([(0, 2500), (1, 2600)], 8, 0.15)],
                52, aspereza=0.65, sopro=0.3, garra=2.4)
    v = elmo(v) * contorno(n, [(0, 0), (0.12, 1), (0.6, 0.8), (1, 0)])
    raspa = amostra("rpg-audio", "drawKnife3")
    raspa = aparar(afinar(raspa, 0.9), 0.38, 0.1)
    return acabar(camadas(0.4, [(0, v, 0.9), (0.02, raspa, 0.55)]), -8, rms_db=-22)


def caido_morte():
    # a armadura desaba em tres tempos e o ar sai
    placa = aparar(afinar(amostra("impact-sounds", "impactPlate_heavy_001"), 0.8), 0.4, 0.2)
    metal = aparar(afinar(amostra("impact-sounds", "impactMetal_heavy_001"), 0.62), 0.5, 0.25)
    media = aparar(afinar(amostra("impact-sounds", "impactPlate_medium_002"), 0.9), 0.35, 0.15)
    panela = aparar(afinar(amostra("rpg-audio", "metalPot2"), 0.75), 0.6, 0.3)
    n = n_de(0.85)
    v = rosnado(0.85, [(0, 104), (0.25, 88), (1, 46)],
                [([(0, 520), (1, 300)], 5, 1.0), ([(0, 1100), (1, 700)], 6, 0.5), ([(0, 2400), (1, 1900)], 8, 0.1)],
                53, aspereza=0.6, sopro=0.45, garra=2.0)
    v = elmo(v) * contorno(n, [(0, 0), (0.06, 1), (0.45, 0.65), (1, 0)])
    mix = camadas(1.15, [(0.03, v, 0.85), (0.05, placa, 0.5), (0.07, metal, 0.3), (0.3, media, 0.4), (0.5, panela, 0.3)])
    return acabar(sala(mix, 0.6, 0.2), -4, sai_ms=150, rms_db=-20)


# ---------- o rei morto ----------
def rei_notar():
    # rugido fundo, que enche a sala do trono
    n = n_de(1.35)
    v = rosnado(1.35, [(0, 58), (0.3, 86), (0.6, 72), (1, 46)],
                [([(0, 430), (0.3, 660), (1, 400)], 4, 1.0), ([(0, 950), (0.3, 1300), (1, 850)], 5, 0.75), ([(0, 2400), (0.3, 2700), (1, 2300)], 7, 0.25)],
                61, aspereza=0.85, sopro=0.3, jitter=0.04, garra=3.0)
    v *= contorno(n, [(0, 0), (0.1, 0.8), (0.3, 1), (0.7, 0.7), (1, 0)])
    t = np.arange(n) / TAXA
    fundo = np.sin(2 * np.pi * np.cumsum(rampa(n, [(0, 34), (0.3, 46), (1, 28)])) / TAXA) * contorno(n, [(0, 0), (0.25, 1), (1, 0)])
    return depois_do_sino(acabar(sala(v + 0.5 * fundo, 1.0, 0.3, escuro=3000), -3, entra_ms=15, sai_ms=250, rms_db=-19))


def rei_aviso():
    # ameaca curta e grave antes de cada golpe
    n = n_de(0.5)
    v = rosnado(0.5, [(0, 50), (0.7, 66), (1, 60)],
                [([(0, 300), (1, 420)], 4, 1.0), ([(0, 650), (1, 900)], 5, 0.6), ([(0, 2200), (1, 2400)], 7, 0.12)],
                62, aspereza=0.8, sopro=0.25, garra=2.6)
    v *= contorno(n, [(0, 0), (0.3, 0.5), (0.85, 1), (1, 0)])
    fundo = np.sin(2 * np.pi * np.cumsum(rampa(n, [(0, 30), (1, 44)])) / TAXA) * contorno(n, [(0, 0), (0.8, 1), (1, 0)])
    return acabar(sala(v + 0.45 * fundo, 0.5, 0.2, escuro=3000), -6, entra_ms=15, sai_ms=120, rms_db=-22)


def rei_morte():
    # o rugido cai, treme e se desfaz, com a armadura e os ossos indo junto
    n = n_de(2.0)
    v = rosnado(2.0, [(0, 92), (0.15, 80), (1, 30)],
                [([(0, 620), (1, 280)], 4, 1.0), ([(0, 1250), (1, 620)], 5, 0.7), ([(0, 2600), (1, 1700)], 7, 0.2)],
                63, aspereza=0.9, sopro=0.35, jitter=0.05, garra=3.0)
    t = np.arange(n) / TAXA
    treme = 1 - contorno(n, [(0, 0), (0.4, 0.15), (1, 0.6)]) * (0.5 + 0.5 * np.sin(2 * np.pi * 9 * t))
    v *= treme * contorno(n, [(0, 0), (0.04, 1), (0.5, 0.7), (1, 0)])
    fundo = np.sin(2 * np.pi * np.cumsum(rampa(n, [(0, 48), (1, 24)])) / TAXA) * contorno(n, [(0, 0), (0.1, 1), (1, 0)])
    placa = aparar(afinar(amostra("impact-sounds", "impactPlate_heavy_000"), 0.6), 0.6, 0.3)
    metal = aparar(afinar(amostra("impact-sounds", "impactMetal_heavy_001"), 0.5), 0.7, 0.3)
    tabua = aparar(alta(afinar(amostra("impact-sounds", "impactPlank_medium_000"), 0.8), 200), 0.5, 0.2)
    mix = camadas(2.0, [(0, v, 1.0), (0, fundo, 0.45), (0.7, placa, 0.3), (1.0, tabua, 0.3), (1.25, metal, 0.25), (1.5, aparar(osso(2, 0.9), 0.2), 0.25)])
    return acabar(sala(mix, 1.2, 0.3, escuro=3000), -3, entra_ms=10, sai_ms=350, rms_db=-19)


SONS = {
    "snd_voz_esqueleto_notar": esqueleto_notar,
    "snd_voz_esqueleto_aviso": esqueleto_aviso,
    "snd_voz_esqueleto_morte": esqueleto_morte,
    "snd_voz_ghoul_notar": ghoul_notar,
    "snd_voz_ghoul_aviso": ghoul_aviso,
    "snd_voz_ghoul_morte": ghoul_morte,
    "snd_voz_wight_notar": wight_notar,
    "snd_voz_wight_aviso": wight_aviso,
    "snd_voz_wight_morte": wight_morte,
    "snd_voz_conjurador_notar": conjurador_notar,
    "snd_voz_conjurador_aviso": conjurador_aviso,
    "snd_voz_conjurador_morte": conjurador_morte,
    "snd_voz_horda_notar": horda_notar,
    "snd_voz_horda_morte": horda_morte,
    "snd_voz_caido_notar": caido_notar,
    "snd_voz_caido_aviso": caido_aviso,
    "snd_voz_caido_morte": caido_morte,
    "snd_voz_rei_notar": rei_notar,
    "snd_voz_rei_aviso": rei_aviso,
    "snd_voz_rei_morte": rei_morte,
}


def grava(pasta, nome, x):
    dados = (np.clip(x, -1, 1) * 32767).astype(np.int16)
    with wave.open(str(pasta / (nome + ".wav")), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(TAXA)
        w.writeframes(dados.tobytes())


def principal():
    global KENNEY
    pasta = pathlib.Path(sys.argv[1])
    KENNEY = pathlib.Path(sys.argv[2])
    pasta.mkdir(parents=True, exist_ok=True)
    quais = sys.argv[3:] or list(SONS)
    for nome in quais:
        x = SONS[nome]()
        grava(pasta, nome, x)
        print("%s: %.2f s" % (nome, len(x) / TAXA))


if __name__ == "__main__":
    principal()
