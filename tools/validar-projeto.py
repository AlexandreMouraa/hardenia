"""Verifica recursos, delimitadores GML e caminhos do Patio, sem GameMaker.

    python3 tools/validar-projeto.py

Nao e um compilador GML. A compilacao e o robo continuam obrigatorios antes do PR.
"""
import json
import math
import re
from collections import deque
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
JOGO = RAIZ / "Hardenia"


def ler(path):
    return json.loads(re.sub(r",\s*([}\]])", r"\1", path.read_text()))


def validar():
    projeto = ler(JOGO / "Hardenia.yyp")
    nomes = set()
    eventos = {0: "Create", 3: "Step", 8: "Draw", 12: "CleanUp"}
    for recurso in projeto["resources"]:
        nome = recurso["id"]["name"]
        assert nome not in nomes, f"Recurso repetido: {nome}"
        nomes.add(nome)
        p = JOGO / recurso["id"]["path"]
        assert p.is_file(), f"Recurso ausente: {p}"
        d = ler(p)
        assert d["name"] == nome
        if nome in {"obj_arvore", "obj_patio", "obj_perigo_patio", "obj_enemy_defensor", "obj_enemy_curandeiro"}:
            for ev in d["eventList"]:
                arquivo = f'{eventos[ev["eventType"]]}_{ev["eventNum"]}.gml'
                assert (p.parent / arquivo).is_file(), f"Evento ausente: {nome}/{arquivo}"
    # Retira strings e comentarios antes de conferir referencias e delimitadores.
    for p in JOGO.rglob("*.gml"):
        codigo = re.sub(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*[\s\S]*?\*/', "", p.read_text())
        pilha = []
        for c in codigo:
            if c in "({[":
                pilha.append(c)
            elif c in ")}]":
                assert pilha and pilha.pop() == dict(zip(")}]", "({["))[c], f"Delimitador: {p}"
        assert not pilha, f"Bloco aberto: {p}"
        for nome in re.findall(r"\b(?:obj_|spr_|snd_|Room_)[A-Za-z0-9_]+\b", codigo):
            assert nome in nomes, f"Referencia desconhecida {nome}: {p}"

    sala = ler(JOGO / "rooms/Room2/Room2.yy")
    instancias = sala["layers"][0]["instances"]
    ordem = [i["name"] for i in sala["instanceCreationOrder"]]
    assert set(ordem) == {i["name"] for i in instancias}
    assert len(ordem) == len(set(ordem))
    paredes = []
    for i in instancias:
        if i["objectId"]["name"] == "obj_wall":
            paredes.append((i["x"], i["y"], i["x"] + 64 * i["scaleX"], i["y"] + 64 * i["scaleY"]))
    # Grade conservadora, inflada como a do robo: 8 px laterais e 14 px verticais.
    passo = 8
    w, h = 1536 // passo, 1024 // passo
    bloqueadas = set()
    for x1, y1, x2, y2 in paredes:
        for cy in range(max(0, math.floor((y1 - 14) / passo)), min(h, math.ceil((y2 + 14) / passo))):
            for cx in range(max(0, math.floor((x1 - 8) / passo)), min(w, math.ceil((x2 + 8) / passo))):
                bloqueadas.add((cx, cy))
    jogador = next(i for i in instancias if i["objectId"]["name"] == "obj_player")
    inicio = (int(jogador["x"]) // passo, int(jogador["y"]) // passo)
    assert inicio not in bloqueadas
    visitadas = {inicio}
    fila = deque([inicio])
    while fila:
        x, y = fila.popleft()
        for destino in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]:
            cx, cy = destino
            if 0 <= cx < w and 0 <= cy < h and destino not in bloqueadas and destino not in visitadas:
                visitadas.add(destino)
                fila.append(destino)
    alvos = [(i["objectId"]["name"], i["x"], i["y"]) for i in instancias if i["objectId"]["name"] != "obj_wall"]
    fonte = (JOGO / "scripts/scr_variacao/scr_variacao.gml").read_text()
    trecho = fonte.split("{ sala: Room2, lista: [", 1)[1].split("{ sala: Room3", 1)[0]
    alvos += [(n, int(x), int(y)) for n, x, y in re.findall(r"\[(obj_\w+), (\d+), (\d+)\]", trecho)]
    # Le as posicoes dos perigos diretamente do controlador, sem duplicar a geometria.
    fonte = (JOGO / "objects/obj_patio/Create_0.gml").read_text()
    alvos += [("perigo", int(x), int(y)) for x, y in re.findall(r"\[(\d+), (\d+)\]", fonte)]
    for nome, x, y in alvos:
        assert (int(x) // passo, int(y) // passo) in visitadas, f"Alvo sem caminho: {nome} ({x}, {y})"
    assert "obj_enemy_defensor" in {i["objectId"]["name"] for i in instancias}
    assert sum(i["objectId"]["name"] == "obj_enemy_curandeiro" for i in instancias) == 1
    assert trecho.count("obj_enemy_curandeiro") == 2, "Um curandeiro em cada arranjo alternativo"
    print(f"OK: {len(nomes)} recursos, referencias e delimitadores GML; {len(alvos)} destinos acessiveis no Patio.")


if __name__ == "__main__":
    validar()
