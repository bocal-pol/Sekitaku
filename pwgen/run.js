// =====================================================
// run.js - Lanceur du generateur de mot de passe Brainfuck
// =====================================================
// Genere 128 octets cryptographiquement surs, les envoie
// sur stdin de  node bf.js pwgen.bf  et affiche le resultat.
//
// Usage :  node run.js
//
// Pourquoi un lanceur Node et pas run.ps1 ?
//   La strategie PowerShell AllSigned (GPO) refuse tout
//   script .ps1 non signe. Node n'est pas concerne.
// =====================================================

const { spawnSync } = require('child_process');
const { randomBytes } = require('crypto');
const path = require('path');
const fs = require('fs');

const here = __dirname;
const bfjs = path.join(here, '..', 'bf.js');
const prog = path.join(here, 'pwgen.bf');

for (const f of [bfjs, prog]) {
  if (!fs.existsSync(f)) {
    process.stderr.write(`Fichier introuvable : ${f}\n`);
    process.exit(1);
  }
}

// 128 octets crypto : marge tres large pour le rejet-echantillonnage
// (moyenne consommee ~22 octets pour 16 caracteres).
const seed = randomBytes(128);

const res = spawnSync(process.execPath, [bfjs, prog], {
  input: seed,
  encoding: 'buffer',
});

if (res.error) {
  process.stderr.write(`Impossible de lancer bf.js : ${res.error.message}\n`);
  process.exit(1);
}
if (res.stderr && res.stderr.length) {
  process.stderr.write(res.stderr);
}
process.stdout.write(res.stdout);
process.exit(res.status === null ? 1 : res.status);
