// Executa os eventos simples de entrada com dublês; nao substitui o Runner.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

function executar(evento, estado, robo) {
  const fonte = readFileSync(new URL(`../Hardenia/objects/${evento}.gml`, import.meta.url), 'utf8');
  const contexto = {
    obj_autotest: 'robo', obj_mapa: 'mapa', obj_abertura: 'abertura', obj_opcoes: 'opcoes',
    instance_exists: objeto => objeto === 'robo' && robo,
    ...estado,
  };
  // Estes eventos nao usam exit dentro de funcoes aninhadas.
  vm.runInNewContext(`(function() { ${fonte.replace(/\bexit\s*;/g, 'return;').replace(/\bmod\b/g, '%')} })()`, contexto);
  return contexto;
}

const entradaProibida = () => assert.fail('O robo deixou a tela consultar entrada real');
const entradas = {
  toque_detectar: entradaProibida, keyboard_check_pressed: entradaProibida,
  aperto_de_passar: entradaProibida, mouse_check_button_pressed: entradaProibida,
  pad_volta: entradaProibida, pad_confirma: entradaProibida,
  ponteiro_gui_x: entradaProibida, ponteiro_gui_y: entradaProibida,
  toque_tap_em: entradaProibida, comecar: entradaProibida,
};
executar('obj_menu/Step_0', entradas, true);
executar('obj_menu/KeyPress_13', entradas, true);
for (const modo of ['como_jogar', 'creditos', 'opcoes', 'controles_iniciais']) {
  const tela = executar('obj_opcoes/Step_0', { ...entradas, tempo: 24, modo, fechar: entradaProibida }, true);
  assert.equal(tela.tempo, 25);
}
// Mesmo apos o prazo para pular, o mapa espera a duracao; depois avanca sozinho.
let transicoes = 0;
const mapa = { ...entradas, tempo: 90, pode_pular: 30, duracao: 150,
  saindo: false, destino: 'fase', room_goto: sala => { assert.equal(sala, 'fase'); transicoes++; } };
assert.equal(executar('obj_mapa/Step_0', mapa, true).saindo, false);
assert.equal(transicoes, 0);
assert.equal(executar('obj_mapa/Step_0', { ...mapa, tempo: 149 }, true).saindo, true);
assert.equal(transicoes, 1);
executar('obj_mapa/Step_0', { ...mapa, tempo: 150, saindo: true }, true);
assert.equal(transicoes, 1);
// Fora do robo, o jogador ainda pula o mapa e fecha Como jogar.
executar('obj_mapa/Step_0', { ...mapa, aperto_de_passar: () => true }, false);
assert.equal(transicoes, 2);
let fechou = false;
executar('obj_opcoes/Step_0', { tempo: 24, modo: 'como_jogar', vk_escape: 27,
  keyboard_check_pressed: () => false, pad_volta: () => false,
  aperto_de_passar: () => true, fechar: () => { fechou = true; } }, false);
assert.equal(fechou, true);
// Enter continua iniciando o jogo ou acionando o item selecionado.
let comecou = 0, acao;
const menu = { cursor: 0, comecar: () => comecou++, acionar: valor => { acao = valor; },
  itens: [{ acao: 'jogar' }, { acao: 'opcoes' }] };
executar('obj_menu/KeyPress_13', menu, false);
assert.equal(comecou, 1);
executar('obj_menu/KeyPress_13', { ...menu, cursor: 1 }, false);
assert.equal(acao, 'opcoes');
assert.equal(comecou, 1);
console.log('OK: entrada real isolada no robo; menu, opcoes e mapa preservados para o jogador');
