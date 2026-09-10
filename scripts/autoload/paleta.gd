extends Node
## Paleta oficial de Hardenia, tirada da biblia visual da equipe.
##
## REGRA DO PROJETO: nenhuma cor solta no jogo. Toda cor sai daqui.
## E o que faz a arte de 4 pessoas diferentes parecer o mesmo jogo.
##
## Uso:  modulate = Paleta.SANGUE

const VAZIO   := Color("0a0b0d")  ## fundo, contorno, o breu
const ARDOSIA := Color("1b2027")  ## pedra escura, sombra
const AZUL    := Color("323c49")  ## pedra clara, cenario
const CINZA   := Color("626269")  ## metal, elementos neutros
const OSSO    := Color("a9988e")  ## pele, madeira, detalhe quente
const SANGUE  := Color("901b1d")  ## ACENTO. perigo, vida, capa. use pouco.
const BRANCO  := Color("e8ded9")  ## texto e destaque

## Ordem oficial, util para gerar UI ou depuracao.
const TODAS: Array[Color] = [VAZIO, ARDOSIA, AZUL, CINZA, OSSO, SANGUE, BRANCO]
