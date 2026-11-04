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

## Fontes

| No jogo | Fonte | Autores | Licença |
|---|---|---|---|
| `spr_fonte_texto` | [Grenze](https://github.com/Omnibus-Type/Grenze), peso 500 | The Grenze Project Authors | SIL OFL 1.1 |
| `spr_fonte_titulo` | [Grenze Gotisch](https://github.com/Omnibus-Type/Grenze-Gotisch), peso 700 | The Grenze Gotisch Project Authors | SIL OFL 1.1 |

As folhas de letras saem de `tools/gerar_fontes.py`.

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

Os quatro Caídos (`spr_caido_*`) saem da mesma ferramenta, tingidos:

| Peça | Usada em | Autores | Licenças | Origem |
|---|---|---|---|---|
| Corpo e cabeça de homem e de mulher | todos | bluecarrot16, JaidynReiman, Benjamin K. Smith (BenCreating), Evert, Eliza Wyatt (ElizaWy), TheraHedwig, MuffinElZangano, Durrani, Pierre Vigier (pvigier), Matthew Krohn (makrohn), Johannes Sjölund (wulax), Stephen Challener (Redshrike) | OGA-BY 3.0, CC-BY-SA 3.0, GPL 3.0 | [base](https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles) |
| Botas e calça | todos, menos a Sentinela na calça | JaidynReiman, bluecarrot16, Nila122, ElizaWy, Matthew Krohn (makrohn), Johannes Sjölund (wulax), Stephen Challener (Redshrike) | OGA-BY 3.0, CC-BY-SA 3.0, GPL 2.0, GPL 3.0 | [roupas](https://opengameart.org/content/lpc-clothes-and-hair) |
| Armadura de couro | Carrasco, Batedor, Sapador | Johannes Sjölund (wulax), bluecarrot16, JaidynReiman | OGA-BY 3.0, CC-BY-SA 3.0, GPL 3.0 | [fantasia medieval](https://opengameart.org/content/lpc-medieval-fantasy-character-sprites) |
| Armadura e pernas de placas | Sentinela | JaidynReiman, bluecarrot16, Michael Whitlock (bigbeargames), Matthew Krohn (makrohn), Johannes Sjölund (wulax) | OGA-BY 3.0, CC-BY-SA 3.0, GPL 3.0 | [fantasia medieval](https://opengameart.org/content/lpc-medieval-fantasy-character-sprites) |
| Elmos | Sapador, Sentinela | bluecarrot16, JaidynReiman, Napsio (Vitruvian Studio) | OGA-BY 3.0, CC-BY 3.0, CC-BY 4.0, GPL 2.0, GPL 3.0 | [elmos](https://opengameart.org/content/lpc-helmets) |
| Machado e alabarda | Carrasco, Sentinela | Benjamin K. Smith (BenCreating), bluecarrot16, Sander Frenken (castelonia) | CC-BY-SA 3.0, GPL 3.0 | [armas](https://opengameart.org/content/lpc-medieval-weapons) |
| Adaga | Batedor | bluecarrot16, Johannes Sjölund (wulax), Matthew Krohn (makrohn) | OGA-BY 3.0, CC-BY-SA 3.0, GPL 3.0 | [fantasia medieval](https://opengameart.org/content/lpc-medieval-fantasy-character-sprites) |

A flecha que voa (`spr_flecha`) foi desenhada em `tools/gerar_sprites_lpc.py`, e a bomba (`spr_bomba`), em `tools/gerar_bomba.py`.

Crédito obrigatório: quem publicar o jogo precisa manter esta lista acessível. Ela também aparece no site.
