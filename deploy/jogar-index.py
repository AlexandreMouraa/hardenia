"""Ajusta o index.html que o GameMaker gera para a versao web do Hardenia.

- encaixa o canvas de 1920x1080 na janela mantendo 16:9, fundo preto e sem
  barra de rolagem (setas e espaco rolariam a pagina). Vale tambem para o
  #loading_screen: o GameMaker cria esse segundo canvas so durante o
  carregamento, do tamanho do jogo e colado no canto, e sem a regra ele corta;
- botao de tela cheia e link de volta ao site, discretos, no canto de baixo
  a esquerda (em cima ficam o HUD e o aviso de F11 do menu). Sao div
  sem foco de proposito: um <button> focado dispararia de novo com o Espaco,
  que e o dash;
- clique direito em cima do jogo nao abre o menu do navegador (o jogo usa o
  mouse para mirar e atacar).

Uso: python3 -I jogar-index.py caminho/para/index.html
"""
import pathlib
import sys

MARCA = "hardenia-ajustes"

CABECA = """<style id="hardenia-ajustes">
html,body{margin:0!important;padding:0!important;width:100%;height:100%;overflow:hidden!important;background:#000!important}
#canvas,#loading_screen{position:fixed!important;inset:0!important;margin:auto!important;transform:none!important;width:min(100vw,177.78vh)!important;height:min(100vh,56.25vw)!important}
.hd-cantos{position:fixed;bottom:10px;left:10px;display:flex;gap:6px;z-index:10;opacity:.3;transition:opacity .2s;font:13px/1 system-ui,sans-serif}
.hd-cantos:hover{opacity:1}
.hd-cantos a,.hd-cantos div{color:#e9e2d6;background:rgba(21,12,13,.85);border:1px solid #3a1d1f;border-radius:4px;padding:7px 10px;text-decoration:none;cursor:pointer;user-select:none}
:fullscreen .hd-cantos{display:none}
</style>"""

CORPO = """<div class="hd-cantos">
  <a href="../" tabindex="-1">&larr; Site</a>
  <div id="hd-tela-cheia" role="button" aria-label="Tela cheia">&#x26F6; Tela cheia</div>
</div>
<script>
  // barra de carregamento: o GameMaker chama esta funcao pelo nome
  // (option_html5_loadingbar no projeto) a cada quadro ate terminar de baixar.
  // Fica onde depois aparece "PRESSIONE ENTER", em cima da capa
  function hardenia_carregando(ctx, w, h, total, atual, capa) {
    var p = total ? Math.min(1, atual / total) : 0;
    if (capa && capa.complete) ctx.drawImage(capa, 0, 0, w, h);
    else { ctx.fillStyle = "#0b0607"; ctx.fillRect(0, 0, w, h); }
    var bw = w * 0.3, bh = Math.max(4, Math.round(h * 0.006)), x = (w - bw) / 2, y = Math.round(h * 0.88);
    ctx.fillStyle = "rgba(0,0,0,.65)";
    ctx.fillRect(x - 3, y - 3, bw + 6, bh + 6);
    ctx.fillStyle = "#3a1d1f";
    ctx.fillRect(x, y, bw, bh);
    ctx.fillStyle = "#c4161c";
    ctx.fillRect(x, y, bw * p, bh);
    ctx.fillStyle = "#e9e2d6";
    ctx.font = Math.round(h * 0.022) + "px system-ui, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("Carregando " + Math.round(p * 100) + "%", w / 2, y - Math.round(h * 0.018));
  }

  document.addEventListener("contextmenu", function (e) {
    if (e.target.tagName === "CANVAS") e.preventDefault();
  });

  document.getElementById("hd-tela-cheia").addEventListener("click", function () {
    var el = document.documentElement;
    (el.requestFullscreen || el.webkitRequestFullscreen).call(el);
  });
</script>"""


def main(caminho):
    arquivo = pathlib.Path(caminho)
    html = arquivo.read_text(encoding="utf-8")
    if MARCA in html:
        return
    for marcador in ("</head>", "</body>"):
        if html.count(marcador) != 1:
            sys.exit(f"index.html inesperado: {marcador} aparece {html.count(marcador)} vezes")
    html = html.replace("</head>", CABECA + "\n</head>", 1)
    html = html.replace("</body>", CORPO + "\n</body>", 1)
    arquivo.write_text(html, encoding="utf-8")


if __name__ == "__main__":
    main(sys.argv[1])
