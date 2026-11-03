# Créditos de arte e som de terceiros

Tudo o que veio de fora do grupo, com origem e licença. Asset novo: acrescente aqui no mesmo PR.

## Sons

| No jogo | Arquivo original | Pacote | Autor | Licença |
|---|---|---|---|---|
| `snd_acerto` | `impactPunch_medium_000.ogg` | [Impact Sounds](https://kenney.nl/assets/impact-sounds) | Kenney | CC0 |
| `snd_morte_inimigo` | `impactPunch_heavy_000.ogg` | [Impact Sounds](https://kenney.nl/assets/impact-sounds) | Kenney | CC0 |
| `snd_morte_jogador` | `impactBell_heavy_000.ogg` | [Impact Sounds](https://kenney.nl/assets/impact-sounds) | Kenney | CC0 |
| `snd_dash_negado` | `error_004.ogg` | [Interface Sounds](https://kenney.nl/assets/interface-sounds) | Kenney | CC0 |
| `snd_magia` | `impactGlass_heavy_000.ogg` | [Impact Sounds](https://kenney.nl/assets/impact-sounds) | Kenney | CC0 |
| `snd_escudo` | `impactMetal_light_000.ogg` | [Impact Sounds](https://kenney.nl/assets/impact-sounds) | Kenney | CC0 |
| `snd_arco_tensao` | `creak3.ogg` | [RPG Audio](https://kenney.nl/assets/rpg-audio) | Kenney | CC0 |

Convertidos para WAV, mono, 44,1 kHz. No `snd_acerto` entra por cima uma ponta seca feita em `tools/gerar_sons_combate.py`.

Os outros sons de combate (`snd_attack`, `snd_golpe_forte`, `snd_giro`, `snd_estocada`, `snd_inimigo_golpe`, `snd_flecha`, `snd_bomba_cai` e `snd_explosao`) foram gerados em `tools/gerar_sons_combate.py`, sem som de terceiros.

## Sprites

Inimigos montados com peças do [Universal LPC Spritesheet Character Generator](https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator), em `tools/gerar_sprites_lpc.py`. O projeto usa as peças sob CC-BY-SA 3.0, que é a licença comum a todas elas, e as folhas montadas ficam sob a mesma licença.

| Peça | Usada em | Autores | Licenças | Origem |
|---|---|---|---|---|
| Corpo e cabeça de esqueleto | arqueiro, conjurador, chefe | bluecarrot16, Napsio, JaidynReiman, Johannes Sjölund (wulax), Stephen Challener (Redshrike) | OGA-BY 3.0, CC-BY-SA 3.0, GPL 3.0 | [base](https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles), [fantasia medieval](https://opengameart.org/content/lpc-medieval-fantasy-character-sprites), [esqueleto](https://opengameart.org/content/lpc-skeleton), [bases](https://opengameart.org/content/lpc-character-bases) |
| Túnica | conjurador | Luke Mehl | CC-BY-SA 3.0, GPL 3.0 | [roupas de maga](https://opengameart.org/content/female-mage-clothing-set) |
| Capuz, tingido de roxo | conjurador | Johannes Sjölund (wulax), JaidynReiman | OGA-BY 3.0, CC-BY-SA 3.0, GPL 3.0 | [fantasia medieval](https://opengameart.org/content/lpc-medieval-fantasy-character-sprites), [chapéus](https://opengameart.org/content/lpc-expanded-hats-facial-helmets) |
| Coroa | chefe | DarkwallLKE, Charles Sanchez (CharlesGabriel) | CC-BY-SA 3.0, GPL 3.0 | [base](https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles), [coroa](https://opengameart.org/content/lpc-crown), [chapéus](https://opengameart.org/content/lpc-expanded-hats-facial-helmets) |
| Corpo e cabeça de zumbi | inimigo de horda | bluecarrot16, Benjamin K. Smith (BenCreating), Sander Frenken (castelonia), Stephen Challener (Redshrike) | CC-BY-SA 3.0, GPL 3.0 | [base](https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles), [zumbi](https://opengameart.org/content/lpc-zombie), [bases](https://opengameart.org/content/lpc-character-bases) |
| Arco e flecha | arqueiro | Johannes Sjölund (wulax), Pierre Vigier (pvigier) | OGA-BY 3.0, CC-BY-SA 3.0, GPL 3.0, CC-BY 4.0 | [fantasia medieval](https://opengameart.org/content/lpc-medieval-fantasy-character-sprites), [andar com arco](https://opengameart.org/content/lpc-walk-animations-for-bows) |

A flecha que voa (`spr_flecha`) foi desenhada em `tools/gerar_sprites_lpc.py`, e a bomba (`spr_bomba`), em `tools/gerar_bomba.py`.

Crédito obrigatório: quem publicar o jogo precisa manter esta lista acessível. Ela também aparece no site.
