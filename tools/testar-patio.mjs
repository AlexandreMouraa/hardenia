// Testa as regras reais do GML com funcoes de engine controladas. Runner ainda necessario.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import { funcao, bloco } from './gml-teste.mjs';

const fonte = readFileSync(new URL('../Hardenia/scripts/scr_patio/scr_patio.gml', import.meta.url), 'utf8');
const dano = [], sons = [], efeitos = [];
const jogador = { x: 0, y: 0, hp: 5, is_dead: false, venceu: false, is_dashing: false, invuln_timer: 0,
  levar_dano(n) { this.hp -= n; this.invuln_timer = 45; } };
const ctx = vm.createContext({
  global: { game_paused: false, hitstop: 0 },
  obj_player: jogador, obj_enemy: 'inimigos', obj_wall: 'parede', obj_perigo_patio: 'perigos',
  obj_mapa: 'mapa', obj_tecnicas: 'tecnicas', obj_arvore: 'arvore', obj_cena: 'cena',
  abertos: new Set(), inimigos: [], perigos: [], parede: false,
  instance_exists: obj => obj === jogador || ctx.inimigos.includes(obj) || ctx.abertos.has(obj),
  instance_find: () => jogador,
  point_direction: (x, y, px, py) => (Math.atan2(y - py, px - x) * 180 / Math.PI + 360) % 360,
  point_distance: Math.hypot ? (x, y, px, py) => Math.hypot(x - px, y - py) : undefined,
  angle_difference: (a, b) => ((a - b + 540) % 360) - 180,
  abs: Math.abs,
  sfx: (...a) => sons.push(a), snd_escudo: 'escudo', snd_arco_tensao: 'mecha',
  fx_faiscas: (...a) => efeitos.push(a), make_colour_rgb: (...a) => a.join(','),
  noone: null, collision_line: () => ctx.parede ? 'parede' : null,
  ds_list_create: () => [], ds_list_destroy: () => {},
  collision_circle_list: (x, y, r, obj, prec, self, lista) => {
    lista.push(...ctx.inimigos.filter(e => Math.hypot(e.x - x, e.y - y) <= r));
    return lista.length;
  },
  golpe_acertar: (...a) => dano.push(a),
  zona_acerta_jogador: z => !ctx.parede && Math.hypot(jogador.x - z.x, jogador.y - z.y) <= z.raio,
  patio_raio: () => {},
});
for (const nome of ['defensor_interceptar', 'patio_parado', 'patio_acender', 'patio_atingir']) {
  vm.runInContext(funcao(fonte, nome).replace(/\[\|\s*/g, '['), ctx);
}
const defensor = { x: 0, y: 0, defensor: true, state: 0, guarda_dir: 0, guarda_quebrada: 0 };
assert(ctx.defensor_interceptar(defensor, 50, 0, false), 'Frente bloqueia');
assert(!ctx.defensor_interceptar(defensor, -50, 0, false), 'Costas recebem golpe');
assert(!ctx.defensor_interceptar(defensor, 0, 50, false), 'Flanco recebe golpe');
defensor.state = 3;
assert(!ctx.defensor_interceptar(defensor, 50, 0, false), 'Recuperacao abre guarda');
defensor.state = 1;
assert(!ctx.defensor_interceptar(defensor, 50, 0, true), 'Golpe de quebra atravessa guarda');
assert.equal(defensor.guarda_quebrada, 60);
assert(!ctx.defensor_interceptar(defensor, 50, 0, false), 'Guarda quebrada permite golpe comum');
defensor.defensor = false; defensor.guarda_quebrada = 0;
assert(!ctx.defensor_interceptar(defensor, 50, 0, false), 'Outro inimigo nao recebe guarda');

const barril = { tipo: 'barril', estado: 0, aviso: 60 };
assert(ctx.patio_acender(barril));
assert.equal(barril.tempo, 60);
assert(!ctx.patio_acender(barril), 'Golpes seguintes nao reiniciam a mecha');
assert(!ctx.patio_acender({ tipo: 'armadilha', estado: 0 }));
assert(!ctx.patio_parado());
for (const modal of ['mapa', 'tecnicas', 'arvore', 'cena']) {
  ctx.abertos.add(modal); assert(ctx.patio_parado()); ctx.abertos.delete(modal);
}
for (const campo of ['game_paused', 'hitstop']) {
  ctx.global[campo] = 1; assert(ctx.patio_parado()); ctx.global[campo] = 0;
}
for (const campo of ['is_dead', 'venceu']) {
  jogador[campo] = true; assert(ctx.patio_parado()); jogador[campo] = false;
}
const perigo = { x: 0, y: 0, raio: 112, dano: 4, zona: { x: 0, y: 0, raio: 112 } };
ctx.inimigos = [{ x: 40, y: 0 }, { x: 200, y: 0 }];
ctx.patio_atingir(perigo);
assert.equal(dano.length, 1, 'Somente inimigo dentro do raio');
assert.equal(dano[0][7], true, 'Dano ambiental nao aplica tecnicas do jogador');
assert.equal(dano[0][1], 4);
assert.equal(jogador.hp, 4, 'Explosao tambem atinge jogador');
ctx.patio_atingir(perigo);
assert.equal(jogador.hp, 4, 'Invulnerabilidade impede dano repetido');
jogador.invuln_timer = 0; jogador.is_dashing = true;
ctx.patio_atingir(perigo); assert.equal(jogador.hp, 4, 'Dash protege');
jogador.is_dashing = false; ctx.parede = true; dano.length = 0;
ctx.patio_atingir(perigo);
assert.equal(dano.length, 0, 'Cobertura protege inimigo');
assert.equal(jogador.hp, 4, 'Cobertura protege jogador');

// Adapta somente a iteracao with do evento para exercitar a maquina de estados original.
let passo = readFileSync(new URL('../Hardenia/objects/obj_perigo_patio/Step_0.gml', import.meta.url), 'utf8');
const inicio = passo.indexOf('with (obj_enemy)');
const iteracao = bloco(passo, inicio);
passo = passo.replace(iteracao, `for (const inimigo of inimigos) { with ({...inimigo, other: globalThis}) ${iteracao.slice(iteracao.indexOf('{'))} }`);
passo = `(function() { ${passo.replace(/\bexit;/g, 'return;')} })()`;
Object.assign(ctx, {
  tipo: 'armadilha', estado: 0, tempo: 0, aviso: 60, raio: 38, x: 0, y: 0, id: 'perigo',
  inimigos: [], snd_inimigo_golpe: 'espinhos', snd_explosao: 'explosao',
  fx_onda: () => {}, fx_explosao: () => {}, impacto: () => {},
  patio_atingir: () => { ctx.disparos++; }, disparos: 0,
});
ctx.parede = false; jogador.x = 0; jogador.y = 0;
vm.runInContext(passo, ctx);
assert.equal(ctx.estado, 1);
assert.equal(ctx.disparos, 0);
ctx.global.game_paused = true;
const antes = ctx.tempo;
vm.runInContext(passo, ctx); assert.equal(ctx.tempo, antes, 'Pausa congela mecha');
ctx.global.game_paused = false;
for (let i = 0; i < 59; i++) vm.runInContext(passo, ctx);
assert.equal(ctx.disparos, 1, 'Dispara depois do aviso completo');
for (let i = 0; i < 18; i++) vm.runInContext(passo, ctx);
assert.equal(ctx.estado, 3);
assert.equal(ctx.disparos, 1, 'Um dano por disparo');
for (let i = 0; i < 180; i++) vm.runInContext(passo, ctx);
assert.equal(ctx.estado, 0, 'Armadilha rearma');
ctx.tipo = 'barril'; ctx.estado = 3; ctx.tempo = 0;
vm.runInContext(passo, ctx);
assert.equal(ctx.estado, 3, 'Barril permanece destruido');
console.log('OK: guarda frontal, flanco, recuperacao, quebra, dano neutro, cobertura, dash, pausa e ciclo dos perigos. Adaptador JS; Runner ainda necessario.');
