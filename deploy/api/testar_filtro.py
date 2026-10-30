#!/usr/bin/env python3
"""Confere o filtro de nomes do ranking. Rode depois de mexer nas listas:

  python deploy/api/testar_filtro.py

Sai com codigo 0 se os nomes ruins foram barrados e os comuns passaram. Nao
abre banco nem rede.
"""
import itertools
import sys

from hardenia_api import nome_proibido

RUINS = [
    "p3n1s", "penis", "pau pequeno", "paupequeno", "pau-pequeno", "PAU", "p a u", "pau123",
    "paaau", "caralho", "c4r4lh0", "car alho", "c.a.r.a.l.h.o", "KARALHO", "merda",
    "m3rd4", "mer da", "merrrda", "puta", "p_u_t_a", "pu ta", "puuuta", "PuTa", "filho da puta",
    "fdp", "F.D.P", "porra", "p0rr4", "cu", "c u", "cuzao", "cuzão", "buceta", "bu_ceta",
    "b0c3t4", "foda-se", "fodase", "foda", "vai se foder", "vsf", "viado", "meu pau",
    "meu pinto", "anal", "a n a l", "hitler", "H1TL3R", "fuck", "bosta",
]

COMUNS = [
    "Paulo", "Paula", "Paulinho", "Pinto", "Joao Pinto", "Ana L", "Ana L.", "Ana Lima",
    "Ana Luiza", "Analu", "Marcus", "Lucas", "Cunha", "Hercules", "Computador", "Deputado",
    "Disputa", "Enviado", "Aviador", "Desviado", "Carolina", "Rolando", "Carola", "Picasso",
    "Tropical", "Nazira", "Nazare", "Yoshito", "Yoshitaka", "Hancock", "Peacock", "Passos",
    "Assis", "Cassio", "Rafael", "Meu Paulo", "Seu Paulo", "Romeu Pinto", "Eliseu Pinto",
    "Nicolau", "Filipe Rocha", "Felipe", "Cristielly", "William", "Alexandre", "Roger",
    "Isabela", "Ze", "Bia", "TESTE", "Jogador 1", "Guerreiro", "Ultimo Guerreiro", "xX_Rei_Xx",
]

PRIMEIROS = """Joao Pedro Lucas Mateus Gabriel Rafael Guilherme Gustavo Felipe Filipe Bruno
Thiago Tiago Vitor Daniel Marcos Marcus Paulo Andre Carlos Eduardo Henrique Leonardo Rodrigo
Diego Caio Igor Davi Nicolas Samuel Heitor Antonio Francisco Jose Luis Luiz Maria Ana Julia
Juliana Mariana Camila Fernanda Amanda Beatriz Larissa Leticia Gabriela Rafaela Isabela Sofia
Laura Luana Carolina Bruna Vitoria Natalia Aline Patricia Vanessa Cristina Paula Lara Alice
Homero Abel Noe Cosme Damiao""".split()

SOBRENOMES = """Silva Santos Oliveira Souza Lima Pereira Ferreira Costa Rodrigues Almeida
Nascimento Alves Carvalho Araujo Ribeiro Gomes Martins Rocha Barbosa Melo Cardoso Dias Moura
Teixeira Moreira Mendes Nunes Vieira Correia Campos Freitas Pinto Lopes Machado Castro Andrade
Cavalcante Borges Monteiro Medeiros Fonseca Ramos Reis Bezerra Duarte Assis Cunha Paes Peixoto
Rocha Sales Pacheco Pires Lacerda Damasceno Queiroz Tavares Nogueira""".split()


def main():
    erros = [f"passou: {n}" for n in RUINS if not nome_proibido(n)]
    erros += [f"barrado: {n}" for n in COMUNS if nome_proibido(n)]
    # nome e sobrenome juntos criam encontros que uma lista curta nao mostra
    combinados = [f"{a} {b}" for a, b in itertools.product(PRIMEIROS, SOBRENOMES)]
    erros += [f"barrado: {n}" for n in combinados if nome_proibido(n)]
    for erro in erros:
        print(erro)
    print(f"{len(RUINS)} ruins, {len(COMUNS) + len(combinados)} comuns, {len(erros)} erro(s)")
    return 1 if erros else 0


if __name__ == "__main__":
    sys.exit(main())
