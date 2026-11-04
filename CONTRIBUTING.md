# Como trabalhar no Hardenia em equipe

A `main` é sempre jogável: tudo o que entra nela passou pelo robô. Ninguém sobe
direto na `main`; toda mudança entra por pull request (PR).

Como abrir o projeto e rodar o robô está no [README](README.md).

## Passo a passo de uma tarefa

1. **Pegue uma tarefa** nas issues do GitHub e avise no grupo que ela é sua.
   Uma tarefa, um branch, um PR.
2. **Atualize** com o projeto fechado na IDE:
   ```
   git checkout main
   git pull
   ```
3. **Crie um branch** com seu nome e a tarefa:
   ```
   git checkout -b cris/golpe-carregado
   ```
4. **Faça a mudança.** Commits pequenos, com a mensagem dizendo o que mudou.
5. **Rode o robô** e só siga se der `OK`:
   ```
   powershell -ExecutionPolicy Bypass -File tools\autotest.ps1
   ```
   Mexeu em combate ou mira: rode também com `-Extra "-mouse"`. Mexeu em morte
   ou vida: com `-Extra "-morrer"`. Mexeu em inimigo: com `-Extra "-grupo"`.
6. **Suba e abra o PR:**
   ```
   git push -u origin cris/golpe-carregado
   ```
   No GitHub aparece o botão para abrir o PR. Preencha o modelo: o que muda,
   a linha `resumo` do robô e um print.
7. **Revisão:** outra pessoa da equipe olha, o Alexandre aprova e faz o merge.
8. **Publicação:** só o Alexandre publica no site, porque o acesso ao servidor
   fica com ele. Ver [Versões](#versões).

## O robô é a régua

A linha `resumo` do robô (`runs=3 vitorias=3 mortes=... golpes_inimigos=...
combos=...`) é a mesma toda vez que o jogo é o mesmo: o jogo é determinístico.
Por isso:

- **Mudança só visual** (efeito, HUD, som) **não pode mudar o resumo.** Se
  mudou, tem algo errado. Na v0.5 um resto de arredondamento na 16ª casa
  decimal mudou a run no teclado, e foi o robô que mostrou.
- **Mudança de gameplay muda o resumo**, e tudo bem. Cole no PR o antes e o
  depois e explique a diferença (ex.: "inimigo mais duro: golpes_inimigos
  10 → 14").
- **Não use `random`, `irandom` nem `choose` em efeito visual ou som.** O robô
  usa a sequência aleatória do jogo, então um sorteio a mais muda a run inteira.
  Para variar efeito, use um contador (ver `dash_contador` no `obj_player`).
  Sorteio no gameplay pode, mas combine antes.

## O que dá conflito no GameMaker

- **`Hardenia/Hardenia.yyp`** muda sempre que alguém cria, apaga ou renomeia um
  recurso (objeto, sprite, som, sala, script). Avise no grupo antes de criar
  recurso. Se der conflito, ele é uma lista: mantenha as linhas dos dois lados.
- **Salas (`Hardenia/rooms/`)**: o conflito é difícil de resolver na mão. Uma
  pessoa por sala de cada vez.
- **`.yy` de objeto** muda quando cria ou apaga um evento. Dois PRs criando
  evento no mesmo objeto (ex.: `obj_player`) dão conflito pequeno: mantenha os
  dois eventos.
- **Sempre** feche o projeto na IDE antes de `git pull`, `git checkout` ou
  `git merge`. Com ele aberto, a IDE salva por cima do que chegou.

## Jeito do código

- Comentários em português, sem acento, explicando o porquê (como no resto do
  código). Nomes novos em português.
- Som: `sfx()` no lugar de `audio_play_sound()`, e `musica()` para música, por causa
  do volume das opções (`scr_som`).
- Texto na tela: com acento, pelas funções `texto()` e `titulo()` de `scr_fonte`.
  A fonte só tem os acentos do português: caractere novo pede a folha nova
  (`tools/gerar_fontes.py`).
- Número de balanceamento com comentário dizendo de onde veio (ex.: "mesma
  recarga do ataque antigo (20 frames)").
- Mexeu em tela, mouse ou teclado: teste também no navegador
  (`tools\build-web.ps1`), que se comporta diferente do Windows em fonte, tela
  cheia e mouse.

## Versões

- A versão fica em dois lugares, sempre iguais: `VERSAO_JOGO` em
  `Hardenia/scripts/scr_rede` (aparece no menu) e `deploy/VERSAO` (aparece no
  site).
- Cada versão publicada ganha um bloco em `deploy/site/novidades/index.html`,
  com "antes → agora" e o que pode dar errado.

## Onde fica cada coisa

| Pasta | O quê |
|---|---|
| `Hardenia/` | O jogo (projeto do GameMaker) |
| `docs/GDD.md` | Documento de design: pitch, pilares, protagonista, loop |
| `docs/ESPECIFICACAO_ARTE.md` | Tamanhos e formato de sprites e salas, para a arte |
| `tools/` | Robô (`autotest.ps1`) e builds de HTML5 e Windows |
| `deploy/site/` | Site: página inicial, mapa de mortes, novidades |
| `deploy/api/` | API do ranking, mapa de mortes e opiniões (Python, sem dependências) |
| `deploy/deploy.sh` | Publica no servidor (só quem tem a chave) |
