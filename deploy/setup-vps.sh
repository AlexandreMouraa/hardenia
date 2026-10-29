#!/usr/bin/env bash
# Prepara uma VPS Ubuntu/Debian recem-criada para servir o Hardenia.
# Roda como root NA VPS (o deploy.sh envia e executa este arquivo sozinho):
#   bash setup-vps.sh hardenia.seudominio.com.br
# Instala o Caddy (HTTPS automatico via Let's Encrypt), libera 22/80/443
# e aponta o site para /srv/hardenia.
set -euo pipefail
DOMINIO="${1:?uso: setup-vps.sh <dominio>}"

export DEBIAN_FRONTEND=noninteractive
if ! command -v caddy >/dev/null; then
    apt-get update -q
    apt-get install -y -q debian-keyring debian-archive-keyring apt-transport-https curl gnupg rsync ufw
    curl -1sLf https://dl.cloudsmith.io/public/caddy/stable/gpg.key | gpg --dearmor --yes -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt > /etc/apt/sources.list.d/caddy-stable.list
    apt-get update -q
    apt-get install -y -q caddy
fi

mkdir -p /srv/hardenia /opt/hardenia

# API do ranking e dos eventos (o deploy.sh envia o .py para /tmp antes)
if [ -f /tmp/hardenia_api.py ]; then
    install -m 644 /tmp/hardenia_api.py /opt/hardenia/hardenia_api.py
fi
cat > /etc/systemd/system/hardenia-api.service <<'EOF'
[Unit]
Description=API do Hardenia (ranking, eventos e opinioes)
After=network.target

[Service]
ExecStart=/usr/bin/python3 -I /opt/hardenia/hardenia_api.py
Environment=HARDENIA_DB=/var/lib/hardenia/hardenia.db
Environment=HARDENIA_PORTA=8081
# opcional: HARDENIA_DISCORD_WEBHOOK=https://discord.com/api/webhooks/... manda
# opinioes e bugs para um canal (arquivo fora do deploy: contem um segredo)
EnvironmentFile=-/etc/hardenia/discord.env
DynamicUser=yes
StateDirectory=hardenia
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable hardenia-api >/dev/null 2>&1
systemctl restart hardenia-api

# DOMINIO pode ter varios nomes separados por virgula: o build de Windows
# aponta para o nome sslip.io, entao ele continua valendo quando houver dominio
cat > /etc/caddy/Caddyfile <<EOF
$DOMINIO {
    encode zstd gzip

    handle /api/* {
        reverse_proxy 127.0.0.1:8081
    }

    handle {
        root * /srv/hardenia
        file_server

        # o jogo web muda a cada deploy; a capa e o zip quase nunca
        header /jogar/* Cache-Control "no-cache"
        header /download/* Content-Disposition "attachment"
    }
}
EOF

ufw allow OpenSSH >/dev/null
ufw allow 80/tcp >/dev/null
ufw allow 443/tcp >/dev/null
# HTTP/3 (QUIC): o Caddy ja anuncia; aguenta melhor Wi-Fi com perda de pacote.
# Se a rede do jogador bloquear UDP, o navegador volta sozinho para o TCP
ufw allow 443/udp >/dev/null
ufw --force enable >/dev/null

systemctl enable --now caddy >/dev/null
systemctl reload caddy
echo "pronto: https://$DOMINIO"
