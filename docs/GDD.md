# Game Design Document — Hardenia: O Último Guerreiro

Este documento descreve o jogo como ele foi entregue, na **versão 1.0** (25/11/2026).
Os detalhes técnicos (onde fica cada coisa no código) estão no [README](../README.md).

## Pitch

Um roguelike de ação 2D, hardcore e justo, sobre o guerreiro mais fraco de Hardenia, o
último enviado para derrotar quem destruiu o reino. Ele não tem poderes, armadura
lendária, armas mágicas nem habilidades especiais: só persistência. Cada morte é uma
tentativa a mais de aprender o padrão do inimigo. Nada do personagem passa de uma run
para a outra; quem fica mais forte é o jogador.

## Pilares

- **Combate hardcore e justo:** todo inimigo avisa antes de atacar (pisca, mostra `!`
  e desenha no chão onde o golpe vai cair). Toda morte precisa ensinar algo.
- **Progressão no jogador, não no personagem:** dentro da run o guerreiro aprende
  técnicas e pode pegar armas, mas tudo se perde na morte. Não há progressão permanente.
- **Morte como narrativa:** o contador de tentativas, a caveira onde o guerreiro caiu,
  as frases a cada tantas mortes e o final que muda com o número de tentativas.

## Gênero e referências

Roguelike de ação 2D com visão de cima. Referências: Hades e Hades II (ritmo de combate,
escolha de recompensas entre salas, duelos), Vampire Survivors (ondas de inimigos),
Dark Souls (punição justa, leitura de padrão) e Hollow Knight (precisão de movimento).

## Plataformas e controles

- **Navegador** (o link do site, sem instalar) e **Windows** (zip baixado do site).
- **Teclado e mouse, controle de videogame e toque** (tablet e celular, com direcional
  e botões que aparecem no primeiro toque). A tabela completa está no README.
- O golpe vira sozinho para o inimigo mais perto: o cursor não mira. O jogo explica os
  controles antes da primeira partida.

## Protagonista

- Guerreiro de armadura escura, capa vermelha rasgada e espada longa, da mesma família
  visual dos inimigos.
- **Vida:** 5 golpes. A vida passa de uma sala para a outra. Volta 1 ao limpar uma fase
  pela primeira vez na run, ao vencer o Caído e ao limpar uma sala sem levar golpe.
- **Kit de combate:** combo de 3 golpes, golpe carregado, estocada (atacar durante o
  dash), giro especial com recarga, dash com 2 cargas e invencibilidade, e o golpe da
  Fúria, que enche ao lutar e é próprio de cada arma.

## Loop principal

1. Entrar numa sala; os inimigos chegam em ondas (2 nas Ruínas, 3 nas outras fases).
2. Ler os avisos, desviar, bater na hora em que o inimigo fica exposto.
3. Sala limpa: o último inimigo deixa um baú com **3 técnicas para escolher 1**.
4. Em cada mapa antes do Trono, um **duelo** com um dos Caídos, que deixa a arma dele.
5. O portão abre e o caminho entre as fases mostra onde o guerreiro está.
6. Morrer zera a run: volta às Ruínas, com vida cheia, e as tentativas sobem.
7. Vencer o Rei Morto encerra a run, com tentativas e tempo no ranking do site.

## Estrutura da run

| Fase | Inimigos | Duelo |
|---|---|---|
| Ruínas | esqueletos | Caído mais fácil |
| Catacumbas (túnel) | esqueletos, ghouls, wights, arqueiros e conjuradores | Caído |
| Pátio do Castelo | ghouls, arqueiros, defensores e curandeiros | Caído |
| Cemitério Gelado | wights | Caído |
| O Trono | o Rei Morto, em 3 fases | — |

- Cada sala tem 3 arranjos de inimigos, sorteados por run.
- Os 4 Caídos aparecem em ordem sorteada, sem repetir.
- **Desafio do dia:** a mesma run (arranjos, Caídos e cartas) para todo mundo, com
  ranking próprio.

## Inimigos

- **Esqueleto:** golpe curto; alterna dois golpes.
- **Ghoul:** rápido e frágil, dá um bote em linha e fica exposto no fim.
- **Wight:** lento e duro, varre um arco largo com aviso longo.
- **Arqueiro:** ataca de longe e mostra a linha da flecha antes do tiro.
- **Conjurador:** mantém distância e marca um círculo onde a bomba cai; pune quem fica parado.
- **Defensor:** escudo na frente. Golpe comum só passa pelo flanco, pelas costas ou logo
  depois do golpe dele; golpe forte, estocada e giro abrem a guarda.
- **Curandeiro:** cura os aliados com uma magia que pode ser interrompida.
- Os inimigos agem em grupo: perdem o jogador atrás da parede, chamam os vizinhos,
  cercam por lados diferentes e só 2 atacam ao mesmo tempo.

## Os Caídos: técnicas e armas

Os Caídos são os guerreiros mandados antes, que o rei levantou contra quem vem depois.
Vencer um deles o liberta, e ele deixa o que sabia.

| Caído | Técnicas | Arma (golpe forte e Fúria) |
|---|---|---|
| O Carrasco | Sangria, Execução | Machado: impacto no chão; Terremoto |
| O Batedor | Passo Cortante, Fôlego | Adagas: dois cortes com avanço; Tempestade |
| O Sapador | Bomba de Mão, Rastro de Pólvora | não deixa arma |
| A Sentinela | Último Instante, Retribuição, Hora Certa | Alabarda: estocada que atravessa a fila; Investida |

- A **espada** inicial tem a Fúria Giro Furioso.
- **Combinações** de dois Caídos: Sangue e Pólvora, Rastilho, Sentença e Contra-Passo.
  Aparecem quando o jogador já tem uma técnica de cada um.
- A árvore de técnicas (na pausa e na escolha) mostra o que foi aprendido e o que falta.
- Técnicas e arma valem até a próxima morte.

## História

O texto na tela fica em `scripts/scr_historia` e em `scripts/scr_tecnicas`. Falta a
aprovação do grupo (issue #100).

- **O Rei Morto** é o responsável: ele também veio ao trono um dia, para acabar com a
  guerra, e foi o último da sua vez. Era forte, mas não soube voltar.
- **Os Caídos** são o Carrasco, o Batedor, o Sapador e a Sentinela.
- **O guerreiro** é o mais fraco de todos, e o único que não para de voltar. O final
  muda com o número de tentativas e fecha nessa ideia.

## Arte, som e site

- Sprites 2D em pixel art (créditos em `docs/CREDITOS_ASSETS.md`), clima por fase
  (escuridão com luz, cinza, neve, fagulhas), cartas e árvore com brilho e animação.
- Música por fase, som de fundo e voz para cada tipo de inimigo (ao notar, antes do
  golpe e ao morrer).
- O site tem o jogo, o ranking ao vivo, o mapa de mortes, as novidades de cada versão
  e um formulário de opinião.

## Em aberto

- Nomes definitivos das fases e do chefe, e créditos da equipe (#13).
- Aprovação da história pelo grupo (#100).
- Ajuste de dificuldade com quem jogou (#98).
- Som próprio para eventos e técnicas (#97).
- Hordas e o limite de inimigos em tablet (#25).
- Origem das músicas antigas do menu e do jogo (#99).
