# Hardenia — O Último Guerreiro

Roguelike de ação 2D lateral. Projeto da disciplina de Jogos Digitais — UFG.

> "Não é o personagem que fica mais forte. É o jogador."

## O princípio que não se negocia

Hardenia **não tem progressão permanente**. Nada que o jogador ganha numa run
sobrevive à morte. O que melhora entre uma tentativa e outra é a habilidade de
quem está no teclado — não um número no personagem.

Toda decisão de design passa por essa pergunta: *isso faz o jogador melhorar,
ou faz o personagem melhorar?* Se for a segunda, está fora.

## Como rodar

1. Baixe o **Godot 4.7.2** (versão padrão, **não** a .NET/Mono) em
   <https://godotengine.org/download>. É um `.exe` de ~120 MB, não instala nada.
2. Abra o Godot, clique em **Import**, escolha o `project.godot` desta pasta.
3. Aperte **F5**.

Todo mundo na equipe usa a **mesma versão** do Godot. Versão diferente gera
diff em arquivo que ninguém tocou.

## Controles

| Ação | Tecla |
|---|---|
| Mover | `A` / `D` ou setas |
| Pular | `Espaço` ou `W` |
| Atacar | `J` ou botão esquerdo do mouse |
| Dash | `K` ou `Shift` |
| Reiniciar | `R` |

O dash tem **invencibilidade** durante o impulso — é ferramenta de defesa, não
só de mobilidade. É a mecânica central de "aprender o padrão".

## Estrutura

```
assets/          sprites, áudio e fontes
scenes/
  jogador/       o personagem
  inimigos/      um arquivo por tipo de inimigo
  salas/         AQUI mora o level design
  ui/            HUD e telas
scripts/
  autoload/      Paleta (cores) e Jogo (estado da run)
  inimigos/      InimigoBase e derivados
tools/           gerador de placeholder e smoke test
docs/            atas e decisões da equipe
```

## Paleta

Fechada em 7 cores. **Nenhuma cor solta no projeto** — tudo sai de
`scripts/autoload/paleta.gd`. É o que faz a arte de 4 pessoas diferentes
parecer o mesmo jogo.

| | hex | uso |
|---|---|---|
| vazio | `#0a0b0d` | fundo, contorno |
| ardósia | `#1b2027` | pedra escura, sombra |
| azul | `#323c49` | cenário |
| cinza | `#626269` | metal, neutro |
| osso | `#a9988e` | pele, madeira |
| sangue | `#901b1d` | **acento** — perigo, vida, capa |
| branco | `#e8ded9` | texto |

## Testes

```bash
godot --headless --path . res://tools/smoke_test.tscn
```

Sai com código 0 se passou. Roda sozinho a cada push (`.github/workflows`).
Rode antes de abrir um Pull Request.

## Estado atual

- [x] Movimento lateral, pulo com coyote time e buffer
- [x] Dash com i-frames
- [x] Ataque corpo a corpo com janela de dano
- [x] Vida, dano, empurrão e morte
- [x] Inimigo de patrulha que não cai da plataforma
- [x] Câmera travada nos limites da sala
- [x] HUD e tela de morte
- [ ] Arte definitiva (hoje são placeholders gerados por código)
- [ ] Mais 2 tipos de inimigo + boss
- [ ] Salas de verdade e sorteio da run
- [ ] Áudio
- [ ] Export web + deploy

## Como contribuir

Leia o [CONTRIBUTING.md](CONTRIBUTING.md). Se você nunca usou git, ele foi
escrito pensando exatamente em você.
