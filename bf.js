// ============================================================
// bf.js — Interpréteur Brainfuck
// ============================================================
// Brainfuck est un langage de programmation minimaliste inventé
// en 1993. Il ne possède que 8 instructions, toutes représentées
// par un seul caractère. Tout le reste est ignoré (commentaires).
//
// Le modèle de mémoire est une longue bande de 30 000 cases,
// chacune contenant un nombre entre 0 et 255.
// Une "tête de lecture" se déplace sur cette bande et modifie
// les valeurs case par case.
//
// Utilisation : node bf.js mon_programme.bf
// ============================================================

const fs = require('fs');

// On récupère le nom du fichier passé en argument dans le terminal.
// Exemple : node bf.js hello.bf  →  file = "hello.bf"
const file = process.argv[2];
if (!file) {
  process.stderr.write('Usage: node bf.js <programme.bf>\n');
  process.exit(1);
}

// On lit tout le contenu du fichier .bf d'un coup.
const code = fs.readFileSync(file, 'utf8');

// --- La mémoire ---
// 30 000 cases, toutes initialisées à zéro.
// Chaque case peut contenir un entier de 0 à 255 (un octet).
const tape = new Uint8Array(30000);

// dp = "data pointer" : indice de la case actuellement pointée.
// Démarre à la case 0 (tout à gauche de la bande).
let dp = 0;

// ip = "instruction pointer" : position dans le code source.
// Démarre à la première instruction du fichier.
let ip = 0;

// --- Pré-calcul des sauts de boucle ---
// Les boucles en Brainfuck sont délimitées par [ et ].
// Pour éviter de chercher la parenthèse correspondante à chaque
// tour de boucle, on les associe une seule fois ici, avant
// d'exécuter le programme. C'est plus rapide.
//
// Exemple : si [ est à la position 8 et ] est à la position 45,
// on mémorise brackets[8]=45 et brackets[45]=8.
const brackets = {};
const stack = [];
for (let i = 0; i < code.length; i++) {
  if (code[i] === '[') {
    // On empile la position du [ ouvert, en attente de son ]
    stack.push(i);
  } else if (code[i] === ']') {
    // On dépile le dernier [ non fermé et on les associe mutuellement
    const open = stack.pop();
    if (open === undefined) {
      process.stderr.write(`Erreur : ] sans [ correspondant à la position ${i}\n`);
      process.exit(1);
    }
    brackets[open] = i;
    brackets[i] = open;
  }
}
// Si la pile n'est pas vide, il reste des [ non fermés
if (stack.length > 0) {
  process.stderr.write(`Erreur : [ sans ] correspondant à la position ${stack[0]}\n`);
  process.exit(1);
}

// --- Exécution du programme ---
// On collecte les caractères à afficher dans un tableau,
// puis on les écrit tous d'un coup à la fin (plus efficace).
const output = [];

while (ip < code.length) {
  switch (code[ip]) {

    // > Déplace la tête d'une case vers la droite.
    //   Le % 30000 fait "boucler" si on dépasse la fin de la bande.
    case '>': dp = (dp + 1) % 30000; break;

    // < Déplace la tête d'une case vers la gauche.
    //   Le + 29999 évite un résultat négatif en cas de boucle.
    case '<': dp = (dp + 29999) % 30000; break;

    // + Ajoute 1 à la case courante. Après 255, repart à 0.
    case '+': tape[dp] = (tape[dp] + 1) & 0xff; break;

    // - Retire 1 à la case courante. Avant 0, repart à 255.
    case '-': tape[dp] = (tape[dp] + 255) & 0xff; break;

    // . Affiche le caractère dont le code ASCII est dans la case.
    //   Exemple : si la case vaut 72, on affiche 'H'.
    case '.': output.push(tape[dp]); break;

    // , Lit un caractère au clavier et stocke son code dans la case.
    case ',': {
      const buf = Buffer.alloc(1);
      try { fs.readSync(0, buf, 0, 1, null); tape[dp] = buf[0]; }
      catch { tape[dp] = 0; }
      break;
    }

    // [ Si la case courante vaut 0, saute directement après le ]
    //   correspondant (on ne rentre pas dans la boucle).
    case '[': if (tape[dp] === 0) ip = brackets[ip]; break;

    // ] Si la case courante est non nulle, retourne au [ correspondant
    //   (on recommence la boucle). Si elle vaut 0, on sort de la boucle.
    case ']': if (tape[dp] !== 0) ip = brackets[ip]; break;

    // Tout autre caractère est silencieusement ignoré (c'est un commentaire).
  }

  // On passe à l'instruction suivante
  ip++;
}

// On écrit tous les caractères collectés vers le terminal d'un seul coup.
process.stdout.write(Buffer.from(output));
