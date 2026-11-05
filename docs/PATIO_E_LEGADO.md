# Pátio tático e Legado dos Caídos

Implementação local na branch `rodrigo/implementacao`, baseada na versão 0.9.
Não foi publicada nem teve a versão de distribuição alterada.

## O que muda

| Antes | Agora | Objetivo de design |
|---|---|---|
| Cenário sem ferramentas de combate | Quatro barris e duas armadilhas no mapa original | Atrair inimigos e criar oportunidades de dano ambiental |
| Arranjos centrados em ghouls | Arqueiros, ghouls, defensor e curandeiro | Criar prioridades de combate e suporte entre inimigos |
| Cartas com descrição curta | Ícone, efeito detalhado, ativação e caminhos de combinação | Entender a consequência de cada escolha |
| Técnicas representadas por quadrados no HUD | Ícones compartilhados e nome da última técnica ativada | Reconhecer a construção e perceber seus efeitos |
| Lista de nomes na pausa | Árvore consultável na pausa e na escolha | Planejar combinações e identificar pré-requisitos |

## Mapa original preservado

Por solicitação do Rodrigo, o redesenho do mapa foi retirado. A terceira fase
continua sendo o Pátio (`Room2`), com **fundo, paredes, iluminação, entradas,
dimensões e configurações originais**. O cenário procedural e seu cache de surface
foram removidos. A restauração foi comparada com a base original do trabalho;
as diferenças da sala ficam nos novos inimigos.

`obj_patio` agora cria somente os perigos interativos e mostra as dicas.
Os barris e armadilhas permanecem em posições acessíveis dentro da geometria original.
Os ícones, cartas, árvore, defensor, curandeiro e créditos de Rodrigo Geraldino
continuam presentes.

## Regras de combate no Pátio

- **Barril:** golpe, flecha ou explosão acende a mecha. Aviso de 60 frames,
  raio de 112 px, 4 de dano em inimigos e 1 no jogador. Explode uma vez e deixa restos.
- **Armadilha:** aproximação de jogador ou inimigo inicia aviso de 60 frames.
  Raio de 38 px, 2 de dano em inimigos e 1 no jogador; animação de 18 frames
  e recarga de 180 frames. Perigos não adicionam obstáculos sólidos ao mapa.
- **Paredes:** bloqueiam visão, flechas e dano ambiental. O dash mantém a
  invulnerabilidade e a proteção contra dano repetido segue o combate existente.
- **Defensor:** 5 de vida base, movimento de 1,05 px/frame, guarda frontal de
  65 graus para cada lado e giro limitado a 2 graus/frame. Aviso de 72 frames e
  recuperação de 90, antes dos multiplicadores de dificuldade da fase.
- **Contra o defensor:** flanco, costas e recuperação permitem golpes comuns.
  Carregado, estocada, giro e cenário abrem a guarda por 60 frames. Bloqueio
  tem som metálico, faíscas e reação do escudo; recuperação ganha um losango.
- **Curandeiro:** regras e validação em [CURANDEIRO.md](CURANDEIRO.md).

Dano ambiental não aplica técnicas do jogador ao golpe. Um inimigo já sangrando
continua podendo disparar sua combinação de morte. Reações em cadeia acendem
outra mecha, sem explosão recursiva no mesmo frame. Pausa, cartas, árvore,
transição, cenas, morte e vitória interrompem os perigos.

## Técnicas e árvore

As 13 técnicas existentes continuam com os mesmos pré-requisitos e sorteio.
Os campos `ativacao` e `detalhe`, em `scr_tecnicas`, alimentam cartas e painel da árvore.
Os ícones são vetoriais, sem arquivos externos, e aparecem também no HUD.

A árvore organiza técnicas básicas nas quatro linhagens; combinações ficam na
última linha. As ligações são calculadas de `requer`, a mesma informação que o
sorteio usa. O painel escreve **OU** entre alternativas e **E** entre grupos,
indicando `[OK]` ou `[FALTA]` em cada grupo.

Estados:

- **Adquirida:** técnica ativa nesta tentativa.
- **Em oferta:** pode ser escolhida na tela atual.
- **Não adquirida:** técnica básica ainda não escolhida.
- **Requisitos cumpridos:** combinação elegível para uma oferta futura.
- **Bloqueada:** combinação com pelo menos um grupo de requisitos faltando.

Cumprir requisitos não concede a técnica nem garante uma oferta específica.
A árvore é uma consulta. Aquisição continua acontecendo exclusivamente pela
escolha de uma carta; morrer limpa as técnicas como antes.

Entrada:

- Na seleção: botão **Árvore de técnicas**, `Tab` ou `Y` no controle.
- Na pausa: botão **Árvore de técnicas**, `Tab` ou `X` no controle.
- Na árvore: setas, WASD ou alavanca; mouse/toque seleciona um nó.
- Para voltar: botão **Voltar**, `Esc`, `Tab`, `B`, `Y` ou `Start`.
- Fechar a árvore retorna à pausa ou às cartas, sem confirmar escolha nem
  retomar o combate. Há proteção curta contra reaproveitar o mesmo aperto.

Cartas e árvore usam uma área lógica de 960×540, centralizada e escalada para a GUI.

## Verificação realizada neste ambiente

```bash
python3 tools/validar-projeto.py
node tools/testar-tecnicas.mjs
node tools/testar-patio.mjs
git diff --check
```

- Recursos e eventos registrados, referências e delimitadores GML verificados.
- Grade conservadora: 23 destinos do Pátio acessíveis, incluindo nascimentos dos
  três arranjos, portões e perigos; inflação de 8 px laterais e 14 px verticais.
- 512 seleções das nove técnicas básicas e 2.560 ofertas verificadas, incluindo
  determinismo, ausência de duplicatas e pré-requisitos das combinações.
- Estados da árvore, caminhos de combinação, quatro resoluções e acesso por
  teclado aos 13 nós verificados.
- Guarda frontal, flanco, recuperação, quebra, dano neutro, cobertura,
  invulnerabilidade, pausa, aviso, disparo único e rearmamento verificados.
- Prévia das cartas e da árvore desenhada em Canvas a partir dos eventos GML
  adaptados e das fontes do projeto; inspeção visual sem cortes nos exemplos conferidos.

Os testes Node executam um subconjunto das funções reais com adaptação restrita
para JavaScript e funções de engine controladas. O verificador Python não é um
compilador. A prévia não é uma execução do jogo. Nenhum desses substitui o Runner.

Antes da instalacao e autenticacao do GameMaker, as tentativas de
`tools/build-web.ps1` e `tools/autotest.ps1 -Runs 1` pararam com:

> GameMaker nao encontrado, ou sem login: abra a IDE e entre com a conta uma vez.

Após instalar e autenticar o GameMaker LTS 2026 (runtime 2026.0.0.23),
`tools/build-windows.ps1` compilou e gerou o ZIP de Windows com sucesso.
A build foi extraída em `C:\Users\feito\Games\Hardenia-dev` e iniciada normalmente.
As capturas do Runner confirmaram as novas cartas e o defensor no Pátio.
Os resultados abaixo foram obtidos antes da inclusão do curandeiro; o teste
dessa nova inclusão está descrito em `CURANDEIRO.md`.
O robô padrão terminou três runs com sucesso, sem mortes ou alertas:

```text
runs=3 vitorias=3 mortes=0 golpes_inimigos=196 danos=1 avisos_max=2 combos=98 elites=3 tecnicas=8 furia=22 duelos=6
```

Logs e capturas dessa execução foram preservados em `tmp/verificacao-windows/base/`.
O teste adicional com `-Runs 1 -Speed 480 -Extra "-mouse -morrer -grupo"`
também terminou com `OK`, exercitando ataque por clique, morte em cada fase,
reinício da run, cura e comportamento de grupo:

```text
runs=1 vitorias=1 mortes=5 golpes_inimigos=293 danos=27 avisos_max=2 combos=102 elites=3 grupo=1 tecnicas=10 furia=18 duelos=6
```

Logs e capturas adicionais: `tmp/verificacao-windows/mouse-morte-grupo/`.



**Pendente:** testes de HTML5, medição de desempenho e playtest humano do balanceamento.
O módulo HTML5 ainda não está instalado neste runtime.

## Roteiro para validar na engine

Abra `Hardenia/Hardenia.yyp` no GameMaker LTS 2026, IDE 2026.0.0.16, com login.
Rode os comandos abaixo na raiz do repositório, em Windows:

```powershell
powershell -ExecutionPolicy Bypass -File tools\autotest.ps1
powershell -ExecutionPolicy Bypass -File tools\autotest.ps1 -Extra "-mouse"
powershell -ExecutionPolicy Bypass -File tools\autotest.ps1 -Extra "-morrer"
powershell -ExecutionPolicy Bypass -File tools\autotest.ps1 -Extra "-grupo"
powershell -ExecutionPolicy Bypass -File tools\autotest.ps1 -Extra "-tecnicas"
powershell -ExecutionPolicy Bypass -File tools\autotest.ps1 -Extra "-toque"
powershell -ExecutionPolicy Bypass -File tools\build-web.ps1
```

Playtest manual:

1. Abrir árvore na primeira escolha, explorar as quatro linhagens e voltar.
   Confirmar que não ganhou uma técnica só por consultar.
2. Escolher técnicas que habilitam uma combinação. Conferir os grupos E/OU,
   a indicação de requisitos cumpridos e a aquisição posterior por uma oferta.
3. Abrir árvore pela pausa; fechar com teclado, controle e toque. Confirmar que
   o mundo permanece pausado e o próximo comando não vira ataque acidental.
4. No Pátio, provocar disparo de arqueiro contra uma parede e contra um barril.
   Ativar um barril perto de um inimigo, sair do raio e testar proteção da cobertura.
5. Atrair inimigo para uma armadilha. Pausar durante o aviso e confirmar que
   o temporizador não avança; testar o rearmamento e o dash sobre o disparo.
6. Contra o defensor, comparar golpe frontal, flanco, recuperação e carregado.
   Conferir se a zona de ataque continua clara por cima do cenário e dos efeitos.
7. Limpar os três arranjos do Pátio em runs diferentes. Abrir o baú e alcançar
   o Cemitério; morrer e confirmar o reinício sem técnicas ou perigos antigos.
8. Repetir cartas, árvore e interações em HTML5, incluindo toque e redimensionamento.

Para apresentar o trabalho, comparar os encontros no mesmo mapa e observar
se colegas usam as paredes, provocam dano ambiental e explicam um caminho de combinação.
