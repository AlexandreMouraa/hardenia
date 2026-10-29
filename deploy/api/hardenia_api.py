#!/usr/bin/env python3
"""API do Hardenia: ranking de vitorias, eventos de jogo (inicio, morte, sala
limpa) para o mapa de mortes, e opinioes dos jogadores.

Roda atras do Caddy, so em 127.0.0.1, com SQLite. So biblioteca padrao: nada
para instalar na VPS. IP do jogador nao e gravado; so fica em memoria para o
limite de requisicoes.

  GET  /api/saude
  GET  /api/ranking?limite=10
  POST /api/vitoria      {nome, tentativas, tempo_ms, plataforma, sessao}
  POST /api/evento       {tipo, sala, x, y, tentativa, tempo_ms, plataforma, sessao}
  GET  /api/estatisticas
  GET  /api/mortes?sala=Room1
  POST /api/opiniao      {tipo: "opiniao"|"bug", nota, texto, versao}

Com HARDENIA_DISCORD_WEBHOOK definido (arquivo /etc/hardenia/discord.env), cada
opiniao e bug tambem vai para um canal do Discord.
"""
import json
import os
import re
import sqlite3
import threading
import time
import urllib.request
from collections import defaultdict, deque
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

DB = os.environ.get("HARDENIA_DB", "/var/lib/hardenia/hardenia.db")
PORTA = int(os.environ.get("HARDENIA_PORTA", "8081"))
DISCORD = os.environ.get("HARDENIA_DISCORD_WEBHOOK", "")

SALAS = {"Room1": "Ruínas", "Room2": "Pátio", "Room3": "Cemitério"}
PLATAFORMAS = {"web", "windows"}
TIPOS_EVENTO = {"inicio", "morte", "sala"}
TIPOS_OPINIAO = {"opiniao", "bug"}
VERSAO_OK = re.compile(r"^[0-9][0-9.]{0,15}$")
# no maximo isto de mensagens por hora no Discord, para spam nao inundar o canal
DISCORD_POR_HORA = 30

# requisicoes por IP por minuto, por rota. Folgado de proposito: numa sala de
# aula a turma inteira sai pelo mesmo IP da rede da faculdade
LIMITES = {"/api/vitoria": 60, "/api/evento": 2000, "/api/opiniao": 60}

NOME_OK = re.compile(r"^[\w .\-]{1,16}$", re.UNICODE)
SESSAO_OK = re.compile(r"^[a-z0-9]{6,32}$")

ESQUEMA = """
CREATE TABLE IF NOT EXISTS vitorias (
    id INTEGER PRIMARY KEY,
    nome TEXT NOT NULL,
    tentativas INTEGER NOT NULL,
    tempo_ms INTEGER NOT NULL,
    plataforma TEXT NOT NULL,
    sessao TEXT NOT NULL,
    criado INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS eventos (
    id INTEGER PRIMARY KEY,
    tipo TEXT NOT NULL,
    sala TEXT NOT NULL,
    x REAL,
    y REAL,
    tentativa INTEGER,
    tempo_ms INTEGER,
    plataforma TEXT NOT NULL,
    sessao TEXT NOT NULL,
    criado INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS eventos_tipo_sala ON eventos (tipo, sala);
CREATE TABLE IF NOT EXISTS opinioes (
    id INTEGER PRIMARY KEY,
    nota INTEGER,
    texto TEXT NOT NULL,
    criado INTEGER NOT NULL
);
"""

# colunas que entraram depois do banco ja existir em producao
MIGRACOES = [
    ("opinioes", "tipo", "ALTER TABLE opinioes ADD COLUMN tipo TEXT NOT NULL DEFAULT 'opiniao'"),
    ("opinioes", "versao", "ALTER TABLE opinioes ADD COLUMN versao TEXT"),
]

# melhor resultado de cada nome (sem diferenciar maiusculas); empate de
# tentativas decide pelo tempo, depois por quem chegou primeiro
RANKING_SQL = """
SELECT nome, tentativas, tempo_ms, plataforma, criado, id FROM (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY lower(nome) ORDER BY tentativas, tempo_ms, id
    ) AS n FROM vitorias
) WHERE n = 1 ORDER BY tentativas, tempo_ms, id
"""


def conectar():
    con = sqlite3.connect(DB, timeout=10)
    con.row_factory = sqlite3.Row
    return con


def preparar_banco():
    os.makedirs(os.path.dirname(DB) or ".", exist_ok=True)
    with conectar() as con:
        con.execute("PRAGMA journal_mode=WAL")
        con.executescript(ESQUEMA)
        for tabela, coluna, sql in MIGRACOES:
            if coluna not in [c["name"] for c in con.execute(f"PRAGMA table_info({tabela})")]:
                con.execute(sql)


class Invalido(Exception):
    pass


def inteiro(dados, campo, minimo, maximo):
    valor = dados.get(campo)
    if isinstance(valor, bool) or not isinstance(valor, (int, float)):
        raise Invalido(campo)
    valor = int(valor)
    if not minimo <= valor <= maximo:
        raise Invalido(campo)
    return valor


def texto_opcao(dados, campo, opcoes):
    valor = dados.get(campo)
    if valor not in opcoes:
        raise Invalido(campo)
    return valor


def sessao(dados):
    valor = dados.get("sessao")
    if not isinstance(valor, str) or not SESSAO_OK.match(valor):
        raise Invalido("sessao")
    return valor


def limpar_nome(valor):
    if not isinstance(valor, str):
        raise Invalido("nome")
    nome = " ".join(valor.split())
    if not NOME_OK.match(nome):
        raise Invalido("nome")
    return nome


class Limitador:
    def __init__(self):
        self.trava = threading.Lock()
        self.janelas = defaultdict(deque)

    def permite(self, ip, rota):
        limite = LIMITES.get(rota)
        if limite is None:
            return True
        agora = time.monotonic()
        with self.trava:
            janela = self.janelas[(ip, rota)]
            while janela and agora - janela[0] > 60:
                janela.popleft()
            if len(janela) >= limite:
                return False
            janela.append(agora)
            return True


limitador = Limitador()


def ranking(con, limite):
    linhas = con.execute(RANKING_SQL + " LIMIT ?", (limite,)).fetchall()
    return [
        {"nome": l["nome"], "tentativas": l["tentativas"], "tempo_ms": l["tempo_ms"],
         "plataforma": l["plataforma"], "criado": l["criado"]}
        for l in linhas
    ]


def registrar_vitoria(con, dados):
    registro = (
        limpar_nome(dados.get("nome")),
        inteiro(dados, "tentativas", 1, 100000),
        # uma run inteira nao sai em menos de 10 s; acima de 24 h e lixo
        inteiro(dados, "tempo_ms", 10_000, 86_400_000),
        texto_opcao(dados, "plataforma", PLATAFORMAS),
        sessao(dados),
        int(time.time()),
    )
    cur = con.execute(
        "INSERT INTO vitorias (nome, tentativas, tempo_ms, plataforma, sessao, criado)"
        " VALUES (?, ?, ?, ?, ?, ?)", registro)
    novo = cur.lastrowid
    melhores = con.execute(RANKING_SQL).fetchall()
    total = len(melhores)
    # posicao do melhor resultado deste nome (pode nao ser o que acabou de entrar)
    nome = registro[0].lower()
    posicao = next(i for i, l in enumerate(melhores, 1) if l["nome"].lower() == nome)
    recorde = any(l["id"] == novo for l in melhores)
    return {"posicao": posicao, "total": total, "recorde_pessoal": recorde}


def registrar_evento(con, dados):
    tipo = texto_opcao(dados, "tipo", TIPOS_EVENTO)
    sala = texto_opcao(dados, "sala", SALAS.keys() | {"Room_Menu"})
    x = y = None
    if tipo == "morte":
        x = inteiro(dados, "x", 0, 10000)
        y = inteiro(dados, "y", 0, 10000)
    tentativa = inteiro(dados, "tentativa", 1, 100000) if "tentativa" in dados else None
    tempo = inteiro(dados, "tempo_ms", 0, 86_400_000) if "tempo_ms" in dados else None
    con.execute(
        "INSERT INTO eventos (tipo, sala, x, y, tentativa, tempo_ms, plataforma, sessao, criado)"
        " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        (tipo, sala, x, y, tentativa, tempo, texto_opcao(dados, "plataforma", PLATAFORMAS),
         sessao(dados), int(time.time())))
    return {"ok": True}


class AvisoDiscord:
    """Manda opinioes e bugs para um canal do Discord, fora da requisicao (o
    jogador nao espera o Discord responder). Sem webhook configurado, nao faz nada."""

    def __init__(self, url):
        self.url = url
        self.trava = threading.Lock()
        self.enviados = deque()

    def avisar(self, tipo, nota, texto, versao):
        if not self.url:
            return
        agora = time.monotonic()
        with self.trava:
            while self.enviados and agora - self.enviados[0] > 3600:
                self.enviados.popleft()
            if len(self.enviados) >= DISCORD_POR_HORA:
                return
            self.enviados.append(agora)
        titulo = "🐞 **Bug reportado**" if tipo == "bug" else "💬 **Opinião**"
        extras = [f"nota {nota}/5" if nota else "", f"versão {versao}" if versao else ""]
        linha = " · ".join(e for e in extras if e)
        corpo = "\n".join("> " + l for l in texto[:1500].splitlines() or [""])
        mensagem = f"{titulo}{' · ' + linha if linha else ''}\n{corpo}"
        threading.Thread(target=self._enviar, args=(mensagem,), daemon=True).start()

    def _enviar(self, mensagem):
        # allowed_mentions vazio: texto de jogador com @everyone nao marca ninguem
        dados = json.dumps({"content": mensagem, "allowed_mentions": {"parse": []}}).encode("utf-8")
        req = urllib.request.Request(self.url, data=dados, method="POST", headers={
            "Content-Type": "application/json",
            # o Discord recusa o User-Agent padrao do Python
            "User-Agent": "HardeniaAPI (https://hardenia.177-136-207-112.sslip.io, 1.0)",
        })
        try:
            urllib.request.urlopen(req, timeout=10).read()
        except OSError:
            pass


discord = AvisoDiscord(DISCORD)


def registrar_opiniao(con, dados):
    texto = dados.get("texto")
    if not isinstance(texto, str) or not 1 <= len(texto.strip()) <= 1000:
        raise Invalido("texto")
    nota = inteiro(dados, "nota", 1, 5) if dados.get("nota") is not None else None
    tipo = texto_opcao(dados, "tipo", TIPOS_OPINIAO) if "tipo" in dados else "opiniao"
    versao = dados.get("versao")
    if versao is not None and (not isinstance(versao, str) or not VERSAO_OK.match(versao)):
        raise Invalido("versao")
    con.execute("INSERT INTO opinioes (tipo, nota, texto, versao, criado) VALUES (?, ?, ?, ?, ?)",
                (tipo, nota, texto.strip(), versao, int(time.time())))
    discord.avisar(tipo, nota, texto.strip(), versao)
    return {"ok": True}


def estatisticas(con):
    um = lambda sql, *a: con.execute(sql, a).fetchone()[0]
    salas = []
    for codigo, nome in SALAS.items():
        salas.append({
            "sala": codigo,
            "nome": nome,
            "mortes": um("SELECT count(*) FROM eventos WHERE tipo='morte' AND sala=?", codigo),
            "vezes_limpa": um("SELECT count(*) FROM eventos WHERE tipo='sala' AND sala=?", codigo),
        })
    return {
        "partidas": um("SELECT count(*) FROM eventos WHERE tipo='inicio'"),
        "jogadores": um("SELECT count(DISTINCT sessao) FROM eventos WHERE tipo='inicio'"),
        "vitorias": um("SELECT count(*) FROM vitorias"),
        "mortes": um("SELECT count(*) FROM eventos WHERE tipo='morte'"),
        "media_tentativas_vitoria": um("SELECT round(avg(tentativas), 1) FROM vitorias"),
        "salas": salas,
    }


def mortes(con, sala):
    if sala not in SALAS:
        raise Invalido("sala")
    linhas = con.execute(
        "SELECT x, y FROM eventos WHERE tipo='morte' AND sala=? ORDER BY id DESC LIMIT 5000",
        (sala,)).fetchall()
    return {"sala": sala, "pontos": [[l["x"], l["y"]] for l in linhas]}


class Api(BaseHTTPRequestHandler):
    server_version = "HardeniaAPI"
    sys_version = ""

    def log_message(self, formato, *args):
        # sem IP no log: so metodo, caminho e status
        pass

    def responder(self, status, corpo):
        dados = json.dumps(corpo, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(dados)))
        self.end_headers()
        self.wfile.write(dados)

    def ip(self):
        # o Caddy e o unico cliente (porta so em 127.0.0.1) e preenche este cabecalho
        return self.headers.get("X-Forwarded-For", "").split(",")[-1].strip() or self.client_address[0]

    def do_GET(self):
        url = urlparse(self.path)
        qs = parse_qs(url.query)
        try:
            with conectar() as con:
                if url.path == "/api/saude":
                    return self.responder(200, {"ok": True})
                if url.path == "/api/ranking":
                    limite = max(1, min(50, int(qs.get("limite", ["10"])[0])))
                    return self.responder(200, {"ranking": ranking(con, limite)})
                if url.path == "/api/estatisticas":
                    return self.responder(200, estatisticas(con))
                if url.path == "/api/mortes":
                    return self.responder(200, mortes(con, qs.get("sala", [""])[0]))
        except (Invalido, ValueError) as e:
            return self.responder(400, {"erro": "invalido", "campo": str(e)})
        self.responder(404, {"erro": "nao_encontrado"})

    def do_POST(self):
        rota = urlparse(self.path).path
        acoes = {"/api/vitoria": registrar_vitoria, "/api/evento": registrar_evento,
                 "/api/opiniao": registrar_opiniao}
        if rota not in acoes:
            return self.responder(404, {"erro": "nao_encontrado"})
        if not limitador.permite(self.ip(), rota):
            return self.responder(429, {"erro": "muitas_requisicoes"})
        tamanho = int(self.headers.get("Content-Length") or 0)
        if not 0 < tamanho <= 4096:
            return self.responder(400, {"erro": "corpo"})
        try:
            # o GameMaker manda o JSON como form-urlencoded; o tipo nao importa
            try:
                dados = json.loads(self.rfile.read(tamanho).decode("utf-8"))
            except ValueError:
                raise Invalido("corpo")
            if not isinstance(dados, dict):
                raise Invalido("corpo")
            with conectar() as con:
                return self.responder(200, acoes[rota](con, dados))
        except Invalido as e:
            return self.responder(400, {"erro": "invalido", "campo": str(e)})


if __name__ == "__main__":
    preparar_banco()
    ThreadingHTTPServer(("127.0.0.1", PORTA), Api).serve_forever()
