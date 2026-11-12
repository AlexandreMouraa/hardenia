// Executa funcoes puras do GML em um adaptador JS restrito, sem dependencias.
// Nao substitui compilacao nem testes do Runner do GameMaker.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import { bloco, funcao } from './gml-teste.mjs';

const fonte = readFileSync(new URL('../Hardenia/scripts/scr_tecnicas/scr_tecnicas.gml', import.meta.url), 'utf8');
const interfaceFonte = readFileSync(new URL('../Hardenia/scripts/scr_interface_tecnicas/scr_interface_tecnicas.gml', import.meta.url), 'utf8');
const literalInicio = fonte.indexOf('[', fonte.indexOf('global.tecnicas_lista ='));
const literal = bloco(fonte, literalInicio, '[', ']');
const nomes = ['tem_tecnica', 'tecnica_def', 'combinacao_liberada', 'tecnica_dado', 'tecnicas_sortear'];
const uiNomes = ['tecnica_estado', 'tecnica_requisitos', 'tecnica_caminhos', 'tecnicas_ui', 'tecnica_ret', 'arvore_posicao'];
const contexto = vm.createContext({
  global: { tecnicas: [], caido_vencido: '' },
  array_contains: (a, b) => a.includes(b), array_length: a => a.length,
  array_push: (a, b) => a.push(b),
  variable_struct_exists: (o, k) => Object.hasOwn(o, k),
  variable_struct_set: (o, k, v) => { o[k] = v; },
  min: Math.min, obj_tecnicas: {}, instance_exists: () => false,
  tecnica_em_oferta: chave => contexto.ofertaAtual?.includes(chave) ?? false,
  display_get_gui_width: () => contexto.largura,
  display_get_gui_height: () => contexto.altura,
});
vm.runInContext(`global.tecnicas_lista = ${literal};\n${nomes.map(n => funcao(fonte, n)).join('\n')}\n${uiNomes.map(n => funcao(interfaceFonte, n)).join('\n')}`, contexto);
const lista = contexto.global.tecnicas_lista;
assert.equal(lista.length, 13);
assert.equal(new Set(lista.map(d => d.chave)).size, 13);
for (const d of lista) {
  for (const campo of ['nome', 'caido', 'ativacao', 'detalhe']) assert(d[campo]?.length, `${d.chave}: ${campo}`);
}
let cenarios = 0;
// Todas as 512 selecoes possiveis das nove tecnicas basicas.
for (let mascara = 0; mascara < 512; mascara++) {
  const adquiridas = lista.slice(0, 9).filter((_, i) => mascara & (1 << i)).map(d => d.chave);
  contexto.global.tecnicas = adquiridas;
  contexto.ofertaAtual = [];
  for (const d of lista.filter(d => d.requer)) {
    const esperada = d.requer.every(grupo => grupo.some(chave => adquiridas.includes(chave)));
    assert.equal(contexto.combinacao_liberada(d), esperada, `${mascara}: ${d.chave}`);
    assert.equal(contexto.tecnica_estado(d), esperada ? 'REQUISITOS CUMPRIDOS' : 'BLOQUEADA');
    assert.equal(contexto.tecnica_requisitos(d).includes('[FALTA]'), !esperada);
    assert(!contexto.global.tecnicas.includes(d.chave), 'Consulta nao concede combinacao');
  }
  for (const caido of ['', 'carrasco', 'batedor', 'sapador', 'sentinela']) {
    contexto.global.caido_vencido = caido;
    contexto.global.run_semente = 1097 + mascara * 97;
    contexto.global.ofertas_feitas = 0;
    const oferta = contexto.tecnicas_sortear();
    assert.equal(new Set(oferta.map(d => d.chave)).size, oferta.length);
    assert(oferta.length > 0 && oferta.length <= 3);
    for (const d of oferta) {
      assert(!adquiridas.includes(d.chave));
      if (d.requer) assert(d.requer.every(grupo => grupo.some(k => adquiridas.includes(k))));
    }
    const chaves = oferta.map(d => d.chave).join(',');
    contexto.global.ofertas_feitas = 0;
    assert.equal(contexto.tecnicas_sortear().map(d => d.chave).join(','), chaves, 'Sorteio determinista');
    cenarios++;
  }
}
contexto.global.tecnicas = [];
contexto.ofertaAtual = ['sangria'];
assert.equal(contexto.tecnica_estado(lista[0]), 'EM OFERTA');
assert.equal(contexto.tecnica_estado(lista[1]), 'NÃO ADQUIRIDA');
contexto.global.tecnicas = ['sangria'];
assert.equal(contexto.tecnica_estado(lista[0]), 'ADQUIRIDA');
contexto.global.tecnicas = lista.map(d => d.chave);
assert.equal(contexto.tecnicas_sortear().length, 0);
contexto.global.tecnicas = [];
assert.equal(contexto.tecnica_estado(lista[0]), 'EM OFERTA', 'Nova tentativa nao conserva aquisicao');
assert(contexto.tecnica_caminhos('sangria').includes('SANGUE E PÓLVORA'));
assert(contexto.tecnica_caminhos('sangria').includes('SENTENÇA'));
for (const [w, h] of [[640, 360], [960, 540], [1920, 1080], [1280, 1024]]) {
  contexto.largura = w; contexto.altura = h;
  const r = contexto.tecnica_ret(contexto.tecnicas_ui(), 32, 22, 896, 496);
  assert(r[0] >= 0 && r[1] >= 0 && r[2] <= w && r[3] <= h);
}
// Navegacao do evento real: todos os nos continuam alcancaveis pelas quatro direcoes.
const teclas = new Set();
Object.assign(contexto, {
  cursor: 0, tempo: 2, mouse_antes_x: 0, mouse_antes_y: 0,
  vk_escape: 'escape', vk_tab: 'tab', vk_right: 'right', vk_left: 'left', vk_up: 'up', vk_down: 'down',
  gp_face4: 'y', gp_start: 'start', ord: c => c,
  keyboard_check_pressed: k => teclas.has(k), pad_volta: () => false, pad_novo: () => false,
  tecnica_clicou: () => false, ponteiro_gui_x: () => 0, ponteiro_gui_y: () => 0,
  point_distance: (x, y, px, py) => Math.hypot(x - px, y - py), abs: Math.abs,
});
const evento = new vm.Script(`(function() { ${readFileSync(new URL('../Hardenia/objects/obj_arvore/Step_0.gml', import.meta.url), 'utf8').replace(/\bexit;/g, 'return;')} })()`);
const vistos = new Set([0]), fila = [0];
while (fila.length) {
  const inicio = fila.shift();
  for (const direcao of ['right', 'left', 'up', 'down']) {
    contexto.cursor = inicio; teclas.clear(); teclas.add(direcao);
    evento.runInContext(contexto);
    assert(contexto.cursor >= 0 && contexto.cursor < lista.length);
    if (!vistos.has(contexto.cursor)) { vistos.add(contexto.cursor); fila.push(contexto.cursor); }
  }
}
assert.equal(vistos.size, 13, 'Todos os nos alcancaveis sem mouse');
console.log(`OK: 512 construcoes, ${cenarios} ofertas, estados da arvore, navegacao dos 13 nos e quatro resolucoes. Adaptador JS; Runner ainda necessario.`);
