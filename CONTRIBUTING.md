# Como trabalhar neste repositório

Escrito assumindo que você **nunca usou git a sério**. Não pule etapas e nada
vai dar errado.

## Uma vez só, na primeira vez

```bash
git clone <url-do-repo>
cd Hardenia
git config user.name "Seu Nome"
git config user.email "seu@email.com"
```

Depois abra o `project.godot` no Godot 4.7.2.

## Toda vez que for mexer em algo

```bash
git checkout main
git pull                              # pega o que os outros fizeram
git checkout -b feat/nome-da-tarefa   # sua branch
```

Nomes de branch: `feat/inimigo-arqueiro`, `feat/sala-03`, `fix/pulo-travando`.

## Quando terminar

```bash
godot --headless --path . res://tools/smoke_test.tscn   # tem que dar TUDO OK
git add .
git commit -m "adiciona inimigo arqueiro"
git push -u origin feat/nome-da-tarefa
```

Depois abra um **Pull Request** no GitHub e chame alguém para olhar.

## As três regras

**1. Nunca commite direto na `main`.** Sempre branch + PR. A `main` tem que
estar sempre jogável — é dela que sai a build da apresentação.

**2. Nunca dê `git push --force`.** Se algo travou, pergunte no grupo. Force
push é a única forma real de alguém perder trabalho aqui.

**3. Uma tarefa, uma branch, um PR.** Não junte "arrumei o pulo" com
"fiz 3 salas" no mesmo commit. Se der problema, ninguém consegue desfazer só
metade.

## Quem mexe em quê

Para dois não editarem o mesmo arquivo ao mesmo tempo:

| Área | Arquivos | Responsável |
|---|---|---|
| Sistemas do jogador | `scripts/jogador.gd`, `scenes/jogador/` | |
| Inimigos e boss | `scripts/inimigos/`, `scenes/inimigos/` | |
| Level design | `scenes/salas/` | |
| Arte, UI e áudio | `assets/`, `scenes/ui/`, `scripts/ui/` | |

Preencham a coluna da direita na primeira reunião.

## Se der conflito

Cena do Godot (`.tscn`) é arquivo de texto, então dá para resolver na mão —
mas é chato. **Prevenir é melhor:** avise no grupo antes de mexer numa cena
que não é da sua área.

Se travar mesmo assim: **não delete nada**, tire print e mande no grupo.

## Antes de commitar arte ou áudio

Adicione a linha correspondente no [CREDITS.md](CREDITS.md) **no mesmo commit**.
Asset sem licença registrada não entra. O direito autoral do jogo é nosso e é
isso que sustenta essa afirmação.
