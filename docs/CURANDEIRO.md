# Curandeiro do Pátio

Inimigo de suporte presente nos três arranjos da terceira fase (`Room2`).
Seu papel é mudar a prioridade dos alvos: proteger-se do defensor e das flechas
enquanto decide se interrompe a cura ou finaliza o aliado ferido.

## Regras

- Uma conjuração recupera até **2 pontos de vida de um aliado**, sem ultrapassar
  a vida que ele tinha depois dos ajustes de dificuldade e elite da sala.
- Escolhe o aliado mais ferido proporcionalmente, até **320 px**, com linha de visão.
- Tem **72 frames de aviso** (1,2 s), parado, com ligação verde ao alvo,
  círculo e barra de conjuração. A cura é aplicada somente ao terminar o aviso.
- Um golpe que realmente causa dano ao curandeiro interrompe a conjuração e
  impõe **120 frames** antes de tentar novamente. Sangramento sozinho não interrompe.
- Após uma cura, espera **240 frames** antes da próxima conjuração.
- Alvo morto, fora do alcance, com vida cheia ou atrás de uma parede cancela a cura.
- Não cura a si mesmo, outros curandeiros, chefes/Caídos ou inimigos de horda.
  Não ressuscita e não aumenta permanentemente a vida máxima.
- Tem 3 de vida base, **5 no Pátio**, e não causa dano direto. Quando fica sozinho,
  aproxima-se do jogador para evitar uma perseguição sem fim.
- Pausas, cartas, árvore, cenas e transições respeitam as mesmas travas do combate.

A silhueta usa o conjurador existente, com tom verde e uma cruz acima da cabeça.
Durante a cura ele usa a animação de conjuração; interromper risca a cruz e desfaz
a ligação. O alvo recebe um pulso verde e o número da vida recuperada, na mesma
escala visual dos números de dano do jogo.

## Implementação

- `obj_enemy_curandeiro`: parâmetros, visual e configuração do suporte.
- `scr_cura`: seleção, validação, conjuração, efeito e interrupção.
- `obj_enemy`, Step: preserva sangramento, empurrão e pausa antes do comportamento de suporte.
- `golpe_acertar`: avisa o suporte apenas depois de dano efetivo.
- `dificuldade_aplicar`: registra o limite de vida após os ajustes de dificuldade/elite.
- `Room2` e `scr_variacao`: um curandeiro por arranjo, perto de aliados e sem nascer em paredes.

A cura não usa os estados de ataque 1/2 do pai: ela não ocupa uma das duas vagas
de ataque do grupo nem cria uma zona de dano falsa para o robô.

## Validação desta mudança

```bash
python3 tools/validar-projeto.py
node tools/testar-cura.mjs
```

O teste de lógica verifica seleção, prioridades, alcance, paredes, exclusões,
limite de vida, recarga e interrupção, usando as funções reais em um adaptador
JavaScript restrito. Não substitui execução na engine.

A build Windows foi compilada para teste manual. Por solicitação do Rodrigo,
o playtest do curandeiro fica com ele; não foi executada uma nova run automática
de gameplay desta alteração. Os resultados do robô registrados em
`PATIO_E_LEGADO.md` pertencem à versão anterior à inclusão do curandeiro.

Para experimentar: entrar na terceira fase, ferir um aliado próximo do curandeiro,
observar a ligação verde e comparar deixar a conjuração terminar com interrompê-la.
Conferir também que a cura não atravessa uma parede do mapa original.
