// Adaptacao restrita para testes de funcoes; nao compila GML nem emula o Runner.
import assert from 'node:assert/strict';
export function bloco(texto, inicio, abertura = '{', fechamento = '}') {
  let nivel = 0, aspas = false, comentario = false;
  const primeiro = texto.indexOf(abertura, inicio);
  for (let i = primeiro; i < texto.length; i++) {
    const c = texto[i];
    if (comentario) { if (c === '\n') comentario = false; continue; }
    if (aspas) { if (c === '\\') i++; else if (c === '"') aspas = false; continue; }
    if (c === '"') { aspas = true; continue; }
    if (c === '/' && texto[i + 1] === '/') { comentario = true; i++; continue; }
    if (c === abertura) nivel++;
    if (c === fechamento) {
      nivel--;
      if (nivel === 0) return texto.slice(inicio, i + 1);
    }
  }
  throw new Error('Bloco GML incompleto');
}
export function funcao(texto, nome) {
  const inicio = texto.indexOf(`function ${nome}(`);
  assert(inicio >= 0, `Funcao ausente: ${nome}`);
  return bloco(texto, inicio).replace(/\bmod\b/g, '%');
}
