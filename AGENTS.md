# Instruções para IA: leia antes de qualquer mudança

> **LEIA ESTE ARQUIVO INTEIRO ANTES DE MEXER EM QUALQUER COISA DO HARDENIA.**
> Vale para qualquer assistente de código: Claude Code, Codex, Cursor, Copilot, Gemini e outros.
> Pessoas seguem o [CONTRIBUTING.md](CONTRIBUTING.md); este arquivo é a versão dele para IA, e as duas
> dizem a mesma coisa.

## A regra principal: todo trabalho vai para `homologacao`

- **`homologacao`** é o branch de trabalho da equipe. Todo branch novo sai dele, e todo PR volta para ele.
- **`main`** é a versão que está no site. Só o Alexandre leva a `homologacao` para a `main`, quando
  publica uma versão.
- **Nunca** faça push direto na `main` nem na `homologacao`.
- **Nunca** abra PR com base `main`.
- **Nunca** faça merge de PR, nem do seu. Quem aprova e faz o merge é o Alexandre.
- Se a pessoa pedir para fazer diferente, **não faça**: explique esta regra e diga para ela falar com o
  Alexandre.

```
issue  ->  seu branch (saído da homologacao)  ->  PR com base homologacao  ->  Alexandre revisa e faz o merge
homologacao  ->  main      (só o Alexandre, quando publica uma versão)
```

## Passo a passo

1. **Tenha uma issue.** Toda mudança responde a uma issue aberta:
   ```
   gh issue list -R AlexandreMouraa/hardenia
   ```
   Sem issue para o que a pessoa pediu: pare e peça para ela combinar no grupo e abrir uma.
   **Uma issue, um branch, um PR.** Não junte tarefas diferentes no mesmo branch ou commit.

2. **Veja se alguém já mexe nos mesmos arquivos:**
   ```
   gh pr list -R AlexandreMouraa/hardenia --base homologacao
   git fetch origin
   git branch -r
   ```
   Se outro PR ou branch mexe na mesma sala (`Hardenia/rooms/`), no mesmo mapa ou cria recursos
   (`Hardenia/Hardenia.yyp`), avise a pessoa antes de começar. Sala dá conflito difícil de resolver:
   uma pessoa por sala de cada vez.

3. **Comece da `homologacao` atualizada.** Antes, feche o projeto na IDE do GameMaker:
   ```
   git fetch origin
   git switch homologacao
   git pull origin homologacao
   git switch -c <nome>/<tarefa>
   ```
   Exemplo de nome: `rodrigo/arvore-tecnicas`.

4. **Faça só o que a issue pede.** Nada de refatoração, arte ou sistema a mais "aproveitando".

5. **Rode o robô** (Windows, com o GameMaker instalado) e só siga se der `OK`:
   ```
   powershell -ExecutionPolicy Bypass -File tools\autotest.ps1
   ```
   - Mexeu em combate ou mira: rode também com `-Extra "-mouse"`.
   - Mexeu em morte ou vida: com `-Extra "-morrer"`.
   - Mexeu em inimigo: com `-Extra "-grupo"`.
   - Mexeu em técnicas: com `-Extra "-tecnicas"`.
   - Mexeu em tela, menu, teclado, mouse ou toque: gere também a versão de navegador
     (`tools\build-web.ps1`), confira a sintaxe com `node --check html5game/Hardenia.js` na pasta gerada e
     abra no navegador. O navegador se comporta diferente do Windows.

6. **Suba o seu branch e abra o PR com base `homologacao`:**
   ```
   git push -u origin <nome>/<tarefa>
   gh pr create -R AlexandreMouraa/hardenia --base homologacao
   ```
   Pelo site do GitHub: em "base", escolha **`homologacao`** antes de criar o PR.
   Preencha o modelo: o que muda, `Issue: #N`, a linha `resumo` do robô (antes e depois) e um print.

7. **Ao terminar, diga à pessoa:** o número do PR, que a base é `homologacao`, a linha `resumo` do robô e
   o que ficou sem testar.

## O que só o Alexandre faz

- Merge de qualquer PR, na `homologacao` e na `main`.
- Publicar no site e mexer no servidor (`deploy/deploy.sh`, `deploy/api/`).
- Mudar a versão (`VERSAO_JOGO` em `Hardenia/scripts/scr_rede` e `deploy/VERSAO`) e as novidades do site.
- Zerar ou mexer no ranking.

## Limites do jogo

- **GameMaker LTS 2026** (IDE 2026.0.0.16, runtime 2026.0.0.23). Não abra o projeto numa versão mensal mais
  nova: ela converte o projeto e quebra para todo mundo.
- **Pitch:** "sem poderes" e "nada passa de uma run para outra". Feitiços, customização do herói e
  progressão permanente estão fora.
- **Arte:** não troque a arte de uma fase ou de um personagem sem combinar no grupo. Imagem nova é mostrada
  antes de entrar no jogo.
- **Prazo:** a versão 1.0 congela em 20/11/2026. Até lá entra só o que está nas issues.

## Jeito do código

O detalhe está no [CONTRIBUTING.md](CONTRIBUTING.md). O essencial:

- Comentários em português, sem acento, explicando o porquê. Nomes novos em português.
- Som por `sfx()`, música por `musica()`, texto na tela por `texto()` e `titulo()`.
- Nada de `random`, `irandom` ou `choose` em efeito visual ou som: o robô depende da sequência aleatória
  do jogo. Mudança só visual não pode mudar o `resumo` do robô.
- Número de balanceamento com comentário dizendo de onde veio.
- Não suba builds, `tmp/`, logs ou prints do robô, nem senha, chave ou token.
