# Hardenia — O Último Guerreiro

Roguelike/souslike 2D hardcore feito no GameMaker, como atividade de faculdade.

## Premissa

Hardenia está em guerra há anos. Todos os guerreiros enviados para derrotar o
responsável pela destruição do reino morreram. O protagonista é o último —
considerado o mais fraco de todos. Sem poderes, sem armadura lendária, sem
armas mágicas, sem habilidades especiais. Só uma coisa: persistência.

Cada morte é uma tentativa de descobrir como vencer. A narrativa acompanha a
transformação de "o guerreiro mais fraco" para "o guerreiro que aprendeu" —
não é o personagem que fica mais forte, é o jogador.

Mais detalhes em [docs/GDD.md](docs/GDD.md).

## Engine

GameMaker (versão gratuita, uso não-comercial, export Windows).

O projeto foi salvo pela IDE **2026.0.0.16** — use essa versão ou mais nova.

## Como abrir o projeto

1. Instale o GameMaker: https://gamemaker.io/en/download
2. No GameMaker, **Open** → `Hardenia/Hardenia.yyp`.
3. Aperte **F5** para rodar.

## Controles

| Ação | Tecla |
|---|---|
| Mover | `WASD` ou setas |
| Atacar | `J` |
| Dash (2 cargas, invencível durante o impulso) | `Espaço` |
| Pausar | `Esc` |
| Começar / voltar ao menu | `Enter` |

## Como a run funciona

- Três arenas em sequência: **Ruínas** (esqueletos) → **Pátio** (ghouls) →
  **Cemitério** (wights).
- O portão só abre quando a sala está limpa. O portão que leva adiante brilha.
- Um golpe mata. Ao morrer, a sala recomeça e o contador de **tentativas** sobe.
- Todo inimigo avisa antes de atacar: pisca, mostra `!` e desenha no chão a
  zona onde o golpe vai cair. Saia da zona ou atravesse com o dash.
- Limpar o Cemitério encerra a run com a tela de vitória e o total de tentativas.

## Como gerar a versão para entregar

**Windows (.zip):** no topo da IDE escolha a plataforma **Windows**, clique em
**Create Executable** (ícone de caixa) e escolha **Package as Zip**. Quem
recebe só descompacta e abre o `.exe`.

**Navegador (link):** escolha a plataforma **GX.games** e use **Create
Executable** para publicar — gera um link que abre direto no navegador.
