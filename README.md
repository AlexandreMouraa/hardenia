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
| Pausar / continuar | `Esc` |
| Voltar ao menu (na pausa) | `M` |
| Começar / voltar ao menu (na vitória) | `Enter` |
| Sair do jogo (no menu) | `Esc` |
| Tela cheia / janela | `Alt+Enter` |

## Como a run funciona

- Três arenas em sequência: **Ruínas** (esqueletos) → **Pátio** (ghouls) →
  **Cemitério** (wights). A câmera segue o jogador; o HUD mostra a tentativa,
  as cargas de dash, a fase e quantos inimigos faltam.
- O portão só abre quando a sala está limpa. O portão que leva adiante acende,
  e uma seta amarela na borda da tela aponta para ele quando está fora de vista.
- Um golpe mata. Ao morrer, a sala recomeça e o contador de **tentativas** sobe.
- Todo inimigo avisa antes de atacar: pisca, mostra `!` e desenha no chão a
  zona onde o golpe vai cair. Saia da zona ou atravesse com o dash.
- Limpar o Cemitério encerra a run com a tela de vitória e o total de tentativas.

## Teste automático (robô)

O jogo tem um robô que joga a run inteira sozinho — anda desviando das paredes,
foge das zonas de golpe, ataca e usa o dash — e registra tudo. Serve para
conferir, antes de subir uma mudança, que o jogo continua terminável do menu à
vitória e sem erro. No Windows, na pasta do repositório:

```
powershell -ExecutionPolicy Bypass -File tools\autotest.ps1
```

Ele compila com o GameMaker instalado (precisa ter feito login na IDE uma vez),
roda 3 runs em velocidade acelerada, sem som e em janela, e termina com `OK` ou
`PROBLEMAS ENCONTRADOS`. Log e prints ficam em `%LOCALAPPDATA%\Hardenia\autotest\`.

| Opção (`-Extra "..."`) | O que faz |
|---|---|
| `-morrer` | morre uma vez em cada sala na 1ª run (testa morte e reinício) |
| `-desatento 40` | ignora 40% dos avisos, como um jogador distraído |
| `-diag` | registra as decisões do robô a cada segundo |

Na primeira run o robô também confere o level design de cada sala: inimigo
nascendo dentro de parede, inimigo ou portão sem caminho até o jogador.

O robô só existe quando o jogo abre com `-autotest` (`obj_autotest`); jogando
normal, nada dele roda. Ele controla o jogador pelas mesmas variáveis que o
teclado preenche (`obj_player`, Step) e dispara os eventos reais de ataque e pausa.

## Como gerar a versão para entregar

**Windows (.zip):** no topo da IDE escolha a plataforma **Windows**, clique em
**Create Executable** (ícone de caixa) e escolha **Package as Zip**. Quem
recebe só descompacta e abre o `Hardenia.exe`.

**Navegador (link):** escolha a plataforma **GX.games** e use **Create
Executable** para publicar — gera um link que abre direto no navegador.
