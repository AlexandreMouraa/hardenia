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

GameMaker **LTS 2026** (versão gratuita, uso não-comercial, export Windows). O
projeto está salvo na IDE **2026.0.0.16**.

Use essa mesma versão em todos os computadores. Abrir o projeto num GameMaker
mais novo (a versão mensal, sem "LTS") converte os arquivos, e quem estiver na
LTS 2026 pode não conseguir mais abrir nem compilar.

## Como abrir o projeto

1. Instale o **GameMaker LTS 2026** (https://gamemaker.io/en/download), abra a
   IDE uma vez e faça login com sua conta.
2. Clone o repositório. Ele é privado, então entre no Git ou no GitHub Desktop
   com uma conta que tenha acesso:
   `git clone https://github.com/AlexandreMouraa/hardenia.git`
3. No GameMaker, **Open** → `Hardenia/Hardenia.yyp`.
4. Aperte **F5** para rodar.

## Trabalhando em equipe

O GitHub é a cópia oficial do projeto. O passo a passo de uma tarefa (branch,
robô, pull request), o que dá conflito no GameMaker e as regras do código
estão no [CONTRIBUTING.md](CONTRIBUTING.md).

- **Antes de mexer:** feche o projeto na IDE e só então faça `git pull`. Com o
  projeto aberto, a IDE pode salvar por cima do que chegou.
- **Ao terminar:** rode o robô (seção abaixo) e, se der `OK`, faça commit e
  `git push`. Não troque de computador deixando mudança sem subir.
- **Duas pessoas ao mesmo tempo:** combinem quem mexe em qual sala ou objeto.
  Criar ou apagar um recurso altera o `Hardenia.yyp`, e esse arquivo entra em
  conflito fácil.

## Controles

| Ação | Tecla |
|---|---|
| Mover | `WASD` ou setas |
| Atacar (3 seguidos: combo) | Clique esquerdo (mira no mouse) ou `J` (para onde anda) |
| Golpe carregado (anda devagar enquanto carrega) | Segurar o ataque e soltar quando o personagem piscar |
| Estocada (golpe mais comprido) | Atacar durante o dash ou logo no fim dele |
| Golpe especial (acerta todos em volta, recarga de 3 s) | Clique direito ou `K` |
| Dash (2 cargas, invencível durante o impulso) | `Espaço` |
| Pausar / continuar | `Esc` |
| Voltar ao menu (na pausa) | `M` |
| Começar (no menu) | `Enter` ou clique |
| Voltar ao menu (na vitória) | `Enter` |
| Sair do jogo (no menu) | `Esc` |
| Tela cheia / janela | `Alt+Enter` |

**Tablet e celular:** os controles aparecem no primeiro toque. O polegar na metade esquerda da tela vira o direcional, e os botões ficam à direita: atacar (segurar carrega), dash, giro e pausa. O golpe vira sozinho para o inimigo mais perto. Mexer o mouse ou usar o teclado esconde tudo de novo.

## Teste de horda

No menu, `H` ou um toque no texto do canto abre um protótipo fora da run: três
ondas de inimigos fracos chegando de fora da tela. Encostar machuca, sem aviso.
Ali, `L` ou um toque no botão de baixo mede quantos inimigos o aparelho aguenta a
60 fps e mostra o número na tela, sem precisar de teclado.

## Como a run funciona

- Cinco salas em sequência: **Ruínas** (esqueletos) → **Catacumbas** (túnel com os
  três tipos) → **Pátio** (ghouls) → **Cemitério** (wights) → **O Trono** (chefe). A câmera segue o jogador; o HUD mostra a tentativa,
  as cargas de dash, a fase e quantos inimigos faltam.
- O portão só abre quando a sala está limpa. O portão que leva adiante acende,
  e uma seta amarela na borda da tela aponta para ele quando está fora de vista.
- A barra mostra a **vida**: 5 golpes até morrer. Ela passa de uma sala para a
  outra, e limpar uma fase pela primeira vez na run devolve 1.
- Ao morrer, a run recomeça na primeira fase, com a vida cheia, e o contador de
  **tentativas** sobe.
- Todo inimigo avisa antes de atacar: pisca, mostra `!` e desenha no chão a
  zona onde o golpe vai cair. Saia da zona ou atravesse com o dash.
- Cada tipo age de um jeito. **Esqueleto:** golpe curto. **Ghoul:** rápido e
  frágil, dá um bote em linha e fica exposto no fim. **Wight:** lento e duro,
  varre um arco largo com aviso longo. Depois do golpe o inimigo fica apagado: é a
  hora de bater nele.
- Os inimigos agem em grupo: a parede bloqueia a visão, quem perde o jogador vai
  até o último lugar onde o viu, quem vê ou apanha chama os vizinhos, cada um
  chega por um lado e só 2 atacam ao mesmo tempo. Os outros rondam perto.
- Vencer o Trono encerra a run com a tela de vitória, o total de tentativas
  e o tempo. O jogo pede um nome e manda o resultado para o ranking do site.

## Ranking, mapa de mortes e efeitos

- **Rede** (`scripts/scr_rede`): o jogo avisa o site quando uma partida começa,
  quando o jogador morre (sala e posição) e quando uma sala é limpa. Na vitória
  envia nome, tentativas e tempo, e mostra a posição e o top 5. No navegador a
  API fica no mesmo site (`/api/...`); o build de Windows usa o endereço público.
  Sem internet o jogo funciona igual, só a tela de vitória avisa que não
  conectou. O único dado pessoal possível é o nome que o jogador escolhe
  digitar; o IP não é gravado.
- **Tempo da run:** contado em frames na velocidade do jogo (60), sem a pausa,
  então é o mesmo em PC rápido ou lento.
- **Game feel** (`scripts/scr_efeitos`, `obj_fx`): arco de corte no ataque,
  faíscas, micro-pausa de alguns frames e tremor de câmera ao acertar e ao
  morrer. A micro-pausa congela jogador, inimigos e golpes juntos, então não
  muda a justiça do combate.
- **Dash** (`obj_player`): arranca forte e freia suave (tabela `dash_perfil`,
  mesmos 78 px e 10 frames de invencibilidade de antes), direção travada,
  aperto guardado por 8 frames (vale apertar no fim do dash anterior ou na
  micro-pausa) e rastro brilhante, linhas de velocidade, poeira e anel na
  arrancada. O movimento encosta nas paredes e escorrega em quinas de até 6 px
  (`mover_eixo`).
- **Combo** (`obj_player`, `golpear`): três ataques seguidos. O 2º golpe varre
  ao contrário; o 3º é mais largo, vale 2, empurra o inimigo deslizando
  (`obj_enemy`, `empurrao_x/y`) e tem recarga maior (36 frames). Os dois
  primeiros mantêm a recarga do ataque antigo (20 frames), então um inimigo
  comum morre no mesmo tempo de antes. Apertar J na recarga fica guardado.
- **Mira no mouse** (`obj_player`, `golpear` e `mira_alvo`): atacando com o
  clique, o golpe vai para o mouse em qualquer ângulo, com o mesmo alcance do
  teclado; com `J`, para onde o jogador anda (vale o último usado,
  `global.mira_mouse`). O cursor do sistema some e o jogo desenha uma mira. No
  teclado a conta do golpe é a mesma de antes, bit a bit (ver o comentário em
  `golpear`). O robô tem `-mouse` para jogar mirando.
- **Mapa de progresso** (`scripts/scr_mapa`, `obj_mapa`): ao entrar numa fase
  nova, o guerreiro anda no mapa até ela (2,5 s, Enter ou clique pula); a pausa mostra
  onde você está. As fases ficam em `global.mapa_fases` (fase nova: acrescentar
  lá); o último ponto, o chefe final, aparece como "em breve".
- **Câmera:** agora em código (`obj_player`, End Step), centrada e presa nas
  bordas, seguindo com um leve atraso, mais o tremor.

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
| `-morrer` | morre uma vez em cada sala na 1ª run (testa morte, volta ao começo da run e a vida) |
| `-mouse` | ataca com o clique, mirando no inimigo (testa a mira no mouse) |
| `-carregar` | segura o ataque depois de cada golpe e solta com a carga cheia (testa o golpe carregado; soma `carregados=N` no resumo) |
| `-especial` | usa o golpe especial sempre que tem alvo perto e recarga pronta (soma `especiais=N` no resumo e registra os acertos de cada giro) |
| `-estocar` | com alvo perto e carga de dash, dá o dash e ataca logo depois (soma `estocadas=N` no resumo). Vida sempre cheia: testa o fluxo, não o balanceamento |
| `-formas` | confere a geometria das zonas de golpe e dá uma das 4 formas a cada inimigo, com mais vida (print de cada forma; `formas=8` no resumo quando todas apareceram). Vida sempre cheia, como no `-estocar` |
| `-grupo` | na primeira sala, fica parado e confere visão, memória, alerta dos vizinhos e cerco (print `cerco`; `grupo=1` no resumo) |
| `-horda` | joga as 3 ondas da sala de teste e depois mede o limite do aparelho a 60 fps (rodar com `-Runs 1`) |
| `-desatento 40` | ignora 40% dos avisos, como um jogador distraído |
| `-diag` | registra as decisões do robô a cada segundo |
| `-toque` | joga pelos controles de toque, com dedos de mentira, e reprova se o direcional não andar para onde o robô mandou (soma `toque=1` no resumo) |
| `-api URL` | liga a rede e manda os eventos para essa API (teste local; sem isso o robô não envia nada) |
| `-nome X` | com `-api`, digita X na vitória e envia ao ranking |

Na primeira run o robô também confere o level design de cada sala: inimigo
nascendo dentro de parede, inimigo ou portão sem caminho até o jogador.

O robô só existe quando o jogo abre com `-autotest` (`obj_autotest`); jogando
normal, nada dele roda. Ele controla o jogador pelas mesmas variáveis que o
teclado preenche (`obj_player`, Step) e dispara os eventos reais de ataque e pausa.

## Como gerar a versão para entregar

**Windows (.zip):** no topo da IDE escolha a plataforma **Windows**, clique em
**Create Executable** (ícone de caixa) e escolha **Package as Zip**. Quem
recebe só descompacta e abre o `Hardenia.exe`.

**Pela linha de comando** (sem abrir a IDE, precisa do login feito uma vez):

```
powershell -ExecutionPolicy Bypass -File tools\build-windows.ps1   # zip de Windows
powershell -ExecutionPolicy Bypass -File tools\build-web.ps1       # versão HTML5
```

**Navegador (link):** a versão HTML5 (`tools\build-web.ps1`, ou plataforma
**HTML5** na IDE) gera uma pasta estática que roda em qualquer servidor. É a
que está publicada no site do jogo. Na IDE, o módulo HTML5 é baixado pelo
Target Manager na primeira vez.

## Site e servidor

O site do jogo fica em `deploy/`: página inicial com ranking ao vivo, mapa de
mortes (`site/mapa/`), novidades de cada versão (`site/novidades/`) e a API que
guarda ranking, eventos e opiniões (`api/hardenia_api.py`, Python sem
dependências, banco SQLite). O `deploy/deploy.sh` monta o site com os builds e
publica no servidor; só roda com a chave de acesso, que fica com o Alexandre.
