# Game Design Document — Hardenia: O Último Guerreiro

## Pitch

Um souslike 2D hardcore sobre o guerreiro mais fraco de Hardenia, o último
enviado para derrotar quem destruiu o reino. Ele não tem poderes, armadura
lendária, armas mágicas nem habilidades especiais — só persistência. Cada
morte é uma tentativa a mais de aprender o padrão do inimigo. O jogo não
fortalece o personagem; fortalece o jogador.

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
- Kit de combate enxuto (ex: ataque básico, dash/esquiva, talvez um
  bloqueio/parry) — a limitação de ferramentas é proposital.

## Loop principal (rascunho)

1. Jogador entra em uma área/sala com inimigos.
2. Combate exige leitura de padrão e timing preciso.
3. Morte → volta a um ponto de checkpoint/hub, mantendo aprendizado (não
   necessariamente itens/status).
4. Repetição até dominar o encontro e avançar.

## Em aberto

- Estrutura de níveis: linear por fases vs. runs proceduralmente geradas
  (roguelike de verdade) vs. souslike com mundo fixo.
- O que persiste entre mortes (permadeath total? checkpoints? meta-progressão
  leve?).
- Boss final: quem é o "responsável pela destruição do reino"?
