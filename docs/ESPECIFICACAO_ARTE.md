# Especificação de Arte — Hardenia: O Último Guerreiro

Documento de referência técnica para a equipe de arte (personagens, efeitos de ataque e mapas). Todas as medidas aqui já batem com o que está implementado no GameMaker — seguir esses padrões evita retrabalho na hora de importar.

## Engine

O jogo está sendo feito em **GameMaker** (versão gratuita, GML Code). Pontos que isso implica pra quem for gerar a arte:

- Sprites com múltiplas poses/quadros devem ser entregues como **spritesheet em grade única** (um PNG só por animação, com todos os quadros organizados em linhas/colunas) — é assim que o GameMaker importa (função "Import Strip" com grade de linhas x colunas).
- Cada quadro da grade precisa ter **exatamente o mesmo tamanho** (mesma largura e altura) — o importador corta a imagem em fatias iguais.
- Mapas/cenários podem ser uma única imagem estática (não precisa ser feito em ferramenta de tilemap como Tiled — o projeto não usa esse fluxo).
- Formato de arquivo: **PNG**, com transparência real (canal alfa), não fundo branco "removido" por engano.

## Estilo visual geral

- **Pixel art top-down** (visão de cima, estilo Hero Siege / RPG clássico).
- **Tom sombrio/gótico**: paletas escuras, vermelho sangue como cor de destaque, alto contraste — mesmo clima da arte do menu (título "HARDENIA") e do cenário da Fase 1 (ruínas, tochas, lua vermelha).
- Manter a **mesma densidade de pixel** entre personagens e cenário (um personagem não pode parecer "HD" num fundo pixelado, ou vice-versa).
- Fundo **transparente** (PNG) em todo sprite de personagem/efeito — nunca fundo branco ou colorido sólido.

## Personagem principal (jogador)

Já implementado no jogo com estas medidas:

| Item | Valor |
|---|---|
| Tamanho do quadro | **40 x 48 px** |
| Origem (ponto de referência) | Centro — **20 x 24** |
| Formato do arquivo | Spritesheet em grade (PNG), 1 arquivo por animação |

**Estrutura da grade**: 4 linhas (uma por direção) × N colunas (quadros de animação). Ordem das linhas (de cima pra baixo):

| Linha | Direção |
|---|---|
| 1 | Esquerda |
| 2 | Direita |
| 3 | Cima |
| 4 | Baixo |

Animações necessárias pro jogador:

| Animação | Quadros por direção | Tamanho do arquivo final (grade completa) |
|---|---|---|
| Parado (Idle) | 4 | 160 x 192 px |
| Andando (Walk) | 4 | 160 x 192 px |
| Ataque de espada (Slash) | 6 | 240 x 192 px |

*(Isso já existe pronto — é só referência de padrão pra próximas armas/habilidades do jogador, se houver.)*

## Inimigos

Ainda usando placeholder (quadrado colorido) — arte real é a prioridade atual da equipe.

**Seguir a mesma convenção do jogador** (40x48 por quadro, grade de 4 direções, origem centralizada) pra manter consistência visual e facilitar a importação. Se um inimigo específico for maior/menor que o padrão, avisar antes pra ajustar a máscara de colisão no código.

Cada inimigo precisa de, no mínimo, estas poses/animações (o inimigo já tem uma máquina de estados no código que espera essas fases):

| Estado no jogo | O que a arte precisa comunicar |
|---|---|
| Patrulha / perseguição | Andando normalmente (like o Walk do jogador) |
| Aviso de ataque (telegraph) | Pose de preparação clara e distinta — o jogador precisa perceber que um ataque vai vir |
| Atacando | Pose de golpe/ataque de fato |

Recomendo: 4 quadros pra andar, 2-3 pra aviso, 2-4 pra ataque — mas pode ajustar, só me avisar a contagem final de cada spritesheet antes de eu configurar no jogo.

## Efeitos de ataque (slash/hitbox visual)

| Item | Valor |
|---|---|
| Tamanho do quadro | 32 x 32 px |
| Origem | Centro — 16 x 16 |
| Quadros | Curto, 3-6 quadros (efeito rápido, tipo "corte de espada" ou "impacto") |

Hoje o efeito do jogador é invisível (a animação de ataque do próprio personagem já cobre isso visualmente) — esse efeito de 32x32 é usado principalmente **na arma do inimigo**, pra mostrar o golpe dele vindo. Se a equipe de arte quiser fazer um efeito visual pro ataque do jogador também (tipo um rastro de espada), dá pra reativar.

## Mapas / Cenários

- **Resolução por fase**: sem tamanho fixo obrigatório, mas a Fase 1 atual é **960 x 640 px**. Fases futuras podem ter outro tamanho, só me avisar as dimensões exatas de cada uma antes de configurar a sala no jogo.
- Pode ser entregue como **uma imagem única pré-renderizada** (como foi a Fase 1) — não precisa ser feito em tileset/grade de tiles, o jogo não depende disso.
- Elementos de colisão (paredes, pilares, obstáculos) não precisam ser marcados separadamente pela arte — isso é resolvido no código a partir da imagem.
- Portões/entradas de fase (como o portão de cima e de baixo da Fase 1) devem ficar visualmente claros na arte, já que vão virar pontos de transição entre fases.

## Arte de menu / tela de título

| Item | Valor |
|---|---:|
| Resolução | **1920 x 1080 px** (Full HD, 16:9) — a atual ficou em 1672x941, também funciona mas o ideal é exato 1920x1080 |
| Formato | PNG ou JPG |

Manter o mesmo estilo já usado na arte atual (guerreiro de costas, capa vermelha, lua sangrenta, ruínas góticas, título "HARDENIA" em fonte rachada/desgastada) — é a identidade visual do jogo agora.

## Checklist rápido pra cada entrega

- [ ] PNG com fundo transparente (exceto mapas e telas de menu, que são opacos)
- [ ] Sprites de personagem/inimigo em grade 40x48 por quadro, 4 linhas (esquerda/direita/cima/baixo)
- [ ] Confirmar contagem de quadros por animação antes de enviar
- [ ] Manter o tom sombrio/gótico e a mesma escala de pixel entre todas as artes
