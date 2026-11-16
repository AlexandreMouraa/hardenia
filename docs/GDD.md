# Game Design Document — Hardenia: O Último Guerreiro

## Pitch

Um souslike 2D hardcore sobre o guerreiro mais fraco de Hardenia, o último
enviado para derrotar quem destruiu o reino. Ele não tem poderes, armadura
lendária, armas mágicas nem habilidades especiais — só persistência. Cada
morte é uma tentativa a mais de aprender o padrão do inimigo. Nada do personagem
passa de uma run para a outra; quem fica mais forte é o jogador.

## Pilares

- **Combate hardcore e justo**: inimigos difíceis, mas com padrões
  legíveis e previsíveis — toda morte precisa ensinar algo.
- **Progressão no jogador, não no personagem**: pouco ou nenhum grind de
  status; vencer depende de dominar timing, leitura de padrão e execução.
- **Morte como narrativa**: cada tentativa reforça o tema de persistência —
  considerar feedback de morte (ex: registro de tentativas, dicas sutis).

## Gênero e referências

Roguelike/souslike 2D. Referências de combat feel: Dark Souls (punição justa,
leitura de padrão), Hollow Knight (precisão de movimento 2D), Hades
(ritmo de combate rápido).

## Protagonista

- Sem poderes especiais, sem armadura lendária, sem armas mágicas.
- Técnicas dos Caídos: dentro de uma run ele aprende técnicas com os guerreiros que
  morreram antes. Valem até a próxima morte, sem nenhuma progressão permanente. O que
  fica de uma run para a outra continua sendo só o que o jogador aprendeu.
- Armas dos Caídos: o Caído vencido larga a arma que usava (o machado do Carrasco, as
  adagas do Batedor, a alabarda da Sentinela), e o guerreiro escolhe se troca a espada
  por ela. Não é arma mágica: é a arma de quem morreu antes, e se perde na morte, como
  as técnicas.
- Kit de combate enxuto (ex: ataque básico, dash/esquiva, talvez um
  bloqueio/parry) — a limitação de ferramentas é proposital.

## Loop principal (rascunho)

1. Jogador entra em uma área/sala com inimigos.
2. Combate exige leitura de padrão e timing preciso.
3. Morte → volta a um ponto de checkpoint/hub, mantendo aprendizado (não
   necessariamente itens/status).
4. Repetição até dominar o encontro e avançar.

## História (rascunho, para o grupo ajustar)

O texto na tela fica em `scripts/scr_historia` e em `scripts/scr_tecnicas`.

- **O Rei Morto** é o responsável: ele também veio ao trono um dia, para acabar com a
  guerra, e foi o último da sua vez. Era forte, mas não soube voltar.
- **Os Caídos** são os guerreiros mandados antes: o Carrasco, o Batedor, o Sapador e a
  Sentinela. O rei levanta cada um contra quem vem depois. Vencer um deles liberta o
  guerreiro, e ele deixa a técnica que sabia e a arma que usava. O Sapador não deixa
  arma: ele ensina as bombas.
- **O guerreiro** é o mais fraco de todos, e o único que não para de voltar. O final
  muda com o número de tentativas e fecha nessa ideia.

## Estrutura da run

- Cinco salas em sequência, com 3 arranjos de inimigos cada, sorteados por run. Um duelo
  em cada mapa antes do Trono, com os 4 Caídos em ordem sorteada (o das Ruínas é o mais
  fácil), e o Rei Morto, em 3 fases, no Trono.
- Morrer zera a run. No aparelho ficam só opções e recordes: o que passa de uma run
  para a outra continua sendo só o que o jogador aprendeu.
- Desafio do dia: a mesma run para todo mundo, com ranking próprio.

## Em aberto

- Confirmar com o grupo a história acima e os nomes da equipe (issue #13).
