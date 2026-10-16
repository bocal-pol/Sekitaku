// =====================================================
// test.js - Tests automatises de pwgen.bf (version Node)
// =====================================================
// Equivalent de test.ps1, utilisable malgre la strategie
// PowerShell AllSigned.
//
// Usage :  node test.js
//
// Batteries :
//   1. Determinisme          seed fixe --> sortie identique
//   2. Longueur              100 runs --> tous 16 chars
//   3. Charset               100 runs x 16 --> tous dans [33,126]
//   4. Rejet actif           128 x 0xBC (188) --> 16 x '!'
//   5. Rejet borne           128 x 0xBB (187) --> 16 x '~'
//   6. Non repetition        100 runs crypto --> aucune collision
//   7. Distribution          10000 chars --> chaque char >= 50 fois
// =====================================================

const { spawnSync } = require('child_process');
const { randomBytes } = require('crypto');
const path = require('path');

const bfjs = path.join(__dirname, '..', 'bf.js');
const prog = path.join(__dirname, 'pwgen.bf');

let run = 0, ok = 0, fail = 0;

function pwgen(seed) {
  const res = spawnSync(process.execPath, [bfjs, prog], { input: seed, encoding: 'buffer' });
  if (res.status !== 0) throw new Error(`bf.js a echoue : ${res.stderr}`);
  // Retire le LF final, garde le mot de passe brut.
  return res.stdout.toString('latin1').replace(/\n$/, '');
}

function assert(name, cond, detail) {
  run++;
  if (cond) { ok++; console.log(`  [OK]   ${name}`); }
  else { fail++; console.log(`  [FAIL] ${name}`); if (detail) console.log(`         ${detail}`); }
}

function filled(v) { return Buffer.alloc(128, v); }

console.log('\n======================================================');
console.log('  Tests pwgen.bf');
console.log('======================================================');

// TEST 1
console.log('\nTEST 1 - Determinisme');
const det = Buffer.from(Array.from({ length: 128 }, (_, i) => (i * 17) & 0xff));
const r1 = pwgen(det), r2 = pwgen(det), r3 = pwgen(det);
assert('Run 1 = Run 2', r1 === r2, `'${r1}' vs '${r2}'`);
assert('Run 2 = Run 3', r2 === r3, `'${r2}' vs '${r3}'`);
console.log(`         sortie deterministe = '${r1}'`);

// TEST 2 + 3 + 6  (memes 100 runs)
console.log('\nTEST 2 - Longueur 16 (100 runs)');
console.log('TEST 3 - Charset [33,126] (100 runs)');
console.log('TEST 6 - Non repetition (100 runs)');
let lenBad = null, charBad = null, dup = null;
const seen = new Map();
for (let i = 0; i < 100; i++) {
  const out = pwgen(randomBytes(128));
  if (out.length !== 16 && !lenBad) lenBad = `run ${i} : ${out.length} chars ('${out}')`;
  for (const ch of out) {
    const c = ch.charCodeAt(0);
    if ((c < 33 || c > 126) && !charBad) charBad = `code ${c} dans '${out}' (run ${i})`;
  }
  if (seen.has(out) && !dup) dup = `collision '${out}' runs ${seen.get(out)} et ${i}`;
  seen.set(out, i);
}
assert('100 runs tous a 16 chars', !lenBad, lenBad);
assert('Tous les chars dans [33, 126]', !charBad, charBad);
assert('Aucune paire identique', !dup, dup);

// TEST 4
console.log('\nTEST 4 - Rejet actif (128 x 0xBC = 188)');
const rej = pwgen(filled(0xbc));
assert("Sortie 16 x '!' (EOF -> 0 accepte)", rej === '!'.repeat(16), `recu '${rej}'`);

// TEST 5
console.log('\nTEST 5 - Rejet borne (128 x 0xBB = 187)');
const bor = pwgen(filled(0xbb));
assert("Sortie 16 x '~' (r=93+33)", bor === '~'.repeat(16), `recu '${bor}'`);

// TEST 7
console.log('\nTEST 7 - Distribution uniforme (10000 chars)');
const counts = new Array(127).fill(0);
for (let i = 0; i < 625; i++) {
  for (const ch of pwgen(randomBytes(128))) counts[ch.charCodeAt(0)]++;
}
const slice = counts.slice(33, 127);
const min = Math.min(...slice), max = Math.max(...slice);
console.log(`         min=${min} max=${max} attendu ~${(10000 / 94).toFixed(1)}`);
assert('Chaque char apparu au moins 50 fois', min >= 50, `min=${min}`);

console.log('\n======================================================');
console.log(`  Resume : ${ok} / ${run} tests OK`);
console.log(fail === 0 ? '  Tous les tests passent.' : `  ${fail} test(s) en echec.`);
process.exit(fail === 0 ? 0 : 1);
