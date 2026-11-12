// Regras reais de cura em um adaptador restrito. Playtest fica com o jogador.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import { bloco, funcao } from './gml-teste.mjs';

const fonte = readFileSync(new URL('../Hardenia/scripts/scr_cura/scr_cura.gml', import.meta.url), 'utf8');
const vivos = new Set(), sons = [], efeitos = [];
const ctx = vm.createContext({
  obj_enemy_curandeiro: 'curandeiro', obj_enemy: 'inimigo', obj_wall: 'parede', obj_autotest: 'robo',
  noone: null, inimigos: [], parede: false, min: Math.min, round: Math.round, string: String,
  instance_exists: e => vivos.has(e),
  point_distance: (x, y, px, py) => Math.hypot(px - x, py - y),
  collision_line: () => ctx.parede ? 'parede' : null,
  make_colour_rgb: (...a) => a.join(','),
  fx_faiscas: (...a) => efeitos.push(a), fx_onda: (...a) => efeitos.push(a), fx_numero: (...a) => efeitos.push(a),
  sfx: (...a) => sons.push(a), snd_confirm: 'confirmar',
});
for (const nome of ['cura_alvo_valido', 'cura_interromper', 'cura_concluir']) {
  vm.runInContext(funcao(fonte, nome), ctx);
}
let escolha = funcao(fonte, 'cura_escolher');
const ini = escolha.indexOf('with (obj_enemy)');
const iteracao = bloco(escolha, ini);
escolha = escolha.replace(iteracao, `for (const e of inimigos) { with(e) ${iteracao.slice(iteracao.indexOf('{'))} }`);
vm.runInContext(escolha, ctx);
const curador = { x: 0, y: 0, hp: 5, vida_maxima_cura: 5, object_index: 'curandeiro',
  cura_raio: 320, cura_quantidade: 2, cura_conjurando: true, cura_recarga_max: 240 };
const alvo = { x: 50, y: 0, hp: 4, vida_maxima_cura: 5, object_index: 'esqueleto', imovel: false, leve: false, bbox_top: -10 };
vivos.add(curador); vivos.add(alvo); alvo.id = alvo;
assert(ctx.cura_alvo_valido(curador, alvo));
assert(!ctx.cura_alvo_valido(curador, curador), 'Nao cura a si mesmo');
alvo.hp = 5; assert(!ctx.cura_alvo_valido(curador, alvo), 'Ignora vida cheia');
alvo.hp = 0; assert(!ctx.cura_alvo_valido(curador, alvo), 'Nao ressuscita');
alvo.hp = 2; alvo.x = 321; assert(!ctx.cura_alvo_valido(curador, alvo), 'Respeita alcance');
alvo.x = 50; ctx.parede = true; assert(!ctx.cura_alvo_valido(curador, alvo), 'Nao cura por paredes');
ctx.parede = false;
for (const campo of ['imovel', 'leve']) {
  alvo[campo] = true; assert(!ctx.cura_alvo_valido(curador, alvo)); alvo[campo] = false;
}
alvo.object_index = 'curandeiro'; assert(!ctx.cura_alvo_valido(curador, alvo), 'Curandeiros nao se sustentam mutuamente');
alvo.object_index = 'esqueleto';
const outro = { ...alvo, hp: 1 }; outro.id = outro; vivos.add(outro);
ctx.inimigos = [alvo, outro];
assert.equal(ctx.cura_escolher(curador), outro, 'Prioriza aliado mais ferido proporcionalmente');
curador.cura_alvo = alvo;
assert.equal(ctx.cura_concluir(curador), 2);
assert.equal(alvo.hp, 4);
assert.equal(curador.cura_recarga, 240);
assert.equal(curador.cura_conjurando, false);
curador.cura_conjurando = true; curador.cura_alvo = alvo;
assert.equal(ctx.cura_concluir(curador), 1, 'Limita ao maximo real');
assert.equal(alvo.hp, 5);
alvo.hp = 2; curador.cura_conjurando = true; curador.cura_alvo = alvo;
ctx.cura_interromper(curador);
assert.equal(alvo.hp, 2, 'Interromper nao cura');
assert.equal(curador.cura_alvo, null);
assert.equal(curador.cura_recarga, 120);
ctx.cura_interromper(curador); assert.equal(curador.cura_recarga, 120, 'Nao reinicia recarga fora da conjuracao');
curador.cura_conjurando = true; curador.cura_alvo = alvo; vivos.delete(alvo);
assert.equal(ctx.cura_concluir(curador), 0, 'Alvo morto cancela cura');
assert.equal(curador.cura_conjurando, false);
vivos.add(alvo); curador.cura_conjurando = true; curador.cura_alvo = alvo; ctx.parede = true;
assert.equal(ctx.cura_concluir(curador), 0, 'Revalida linha de visao no disparo');
assert.equal(alvo.hp, 2);
console.log('OK: alvo, prioridades, alcance, paredes, exclusoes, limite de vida, recarga e interrupcao da cura. Adaptador JS; playtest manual pendente.');
