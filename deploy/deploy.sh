#!/usr/bin/env bash
# Publica o Hardenia na VPS. Roda no WSL, a partir desta pasta.
#
#   ./deploy.sh root@IP DOMINIO [PASTA_HTML5]
#
# DOMINIO: o nome que vai abrir o site. Sem dominio proprio ainda, use
#   hardenia.<IP-com-tracos>.sslip.io  (ex.: hardenia.200-10-20-30.sslip.io)
#   que ja resolve para o IP e ganha HTTPS do mesmo jeito. Com dominio proprio,
#   passe os dois separados por virgula, o principal primeiro:
#   "hardenia.com.br, hardenia.177-136-207-112.sslip.io" (o build de Windows
#   fala com a API pelo nome sslip.io, entao ele precisa continuar valendo).
# PASTA_HTML5: saida do tools/build-web.ps1 (a que tem index.html e html5game/).
#   Sem ela o site sobe so com o download para Windows; o botao "Jogar no
#   navegador" acende sozinho quando um deploy posterior incluir a pasta.
# ZIP: build de Windows oferecido para download (padrao: o gerado pelo
#   tools/build-windows.ps1; se nao existir, o zip original em Downloads).
set -euo pipefail
cd "$(dirname "$0")"

ALVO="${1:?uso: ./deploy.sh root@IP DOMINIO [PASTA_HTML5]}"
DOMINIO="${2:?informe o dominio}"
WEB="${3:-}"
PRINCIPAL="$(echo "$DOMINIO" | cut -d, -f1 | tr -d ' ')"
ZIP_NOSSO=/mnt/c/Users/alexandre.moura/HardeniaWeb-win/Hardenia-windows.zip
ZIP_ORIGINAL=/mnt/c/Users/alexandre.moura/Downloads/Hardenia-jogo.zip
ZIP="${ZIP:-$([ -f "$ZIP_NOSSO" ] && echo "$ZIP_NOSSO" || echo "$ZIP_ORIGINAL")}"

DIST="$(mktemp -d)"
trap 'rm -rf "$DIST"' EXIT

cp -r site/. "$DIST/"
mkdir -p "$DIST/download"
cp "$ZIP" "$DIST/download/Hardenia-windows.zip"
echo "zip: $ZIP"

if [ -n "$WEB" ]; then
    [ -f "$WEB/index.html" ] || { echo "sem index.html em $WEB"; exit 1; }
    mkdir -p "$DIST/jogar"
    cp -r "$WEB/." "$DIST/jogar/"
    # a tela de carregamento do GameMaker usa este arquivo: troca pela capa, no
    # tamanho exato do canvas (1920x1080), senao ele amplia e corta
    cp carregando.jpg "$DIST/jogar/html5game/splash.png"
    python3 -I jogar-index.py "$DIST/jogar/index.html"
    # texturas recomprimidas sem mudar pixel: ~17% menos para cada jogador baixar
    python3 -I otimizar-png.py "$DIST"/jogar/html5game/*.png
fi

# links absolutos (previa do WhatsApp, QR) apontam para o dominio principal;
# a versao vem do arquivo VERSAO (a mesma do VERSAO_JOGO em scr_rede)
VERSAO="$(tr -d ' \n' < VERSAO)"
find "$DIST" -maxdepth 2 -name '*.html' -exec sed -i -e "s#__SITE__#https://$PRINCIPAL#g" -e "s#__VERSAO__#$VERSAO#g" {} +
echo "versao: $VERSAO"

echo "== preparando a VPS ($ALVO)"
scp -q setup-vps.sh api/hardenia_api.py "$ALVO:/tmp/"
ssh "$ALVO" "bash /tmp/setup-vps.sh '$DOMINIO'"

echo "== enviando arquivos"
rsync -rlz --delete --chmod=D755,F644 "$DIST/" "$ALVO:/srv/hardenia/"

echo "== conferindo"
sleep 2
curl -fsS -o /dev/null -w "site: %{http_code}\n" "https://$PRINCIPAL/" || echo "HTTPS ainda nao respondeu: confira se o DNS de $PRINCIPAL aponta para a VPS"
curl -fsS -w "  api: %{http_code}\n" "https://$PRINCIPAL/api/saude" || echo "API nao respondeu: journalctl -u hardenia-api na VPS"
[ -n "$WEB" ] && curl -fsS -o /dev/null -w "jogo: %{http_code}\n" "https://$PRINCIPAL/jogar/" || true
echo "https://$PRINCIPAL"
