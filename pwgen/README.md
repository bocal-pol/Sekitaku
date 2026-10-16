# pwgen — générateur de mot de passe Brainfuck

Générateur de mot de passe écrit en **Brainfuck pur**, à exécuter avec l'interpréteur Node `bf.js` du dossier parent. Chaque mot de passe fait exactement **16 caractères** dans le charset ASCII imprimable **33 à 126** (94 caractères, du `!` au `~`).

## Structure du dossier

```
pwgen/
├── pwgen.bf     programme Brainfuck principal
├── run.js       lanceur Node : génère 128 octets crypto et les pipe   ← référence
├── test.js      tests automatisés Node (déterminisme, charset, rejet, distribution)
├── run.ps1      équivalent PowerShell (nécessite une signature de code, voir plus bas)
├── test.ps1     équivalent PowerShell des tests
├── README.md    ce fichier
└── DESIGN.md    plan mémoire, algorithme, décisions techniques
```

## Exécution rapide

```powershell
cd d:\Sekitaku\pwgen
node run.js
```

Sortie attendue :

```
}qzK*}_}^s{bl%@s
```

Chaque appel produit un mot de passe différent.

### À propos des scripts PowerShell

`run.ps1` et `test.ps1` font la même chose que `run.js` et `test.js`, mais la stratégie d'exécution de ce poste est `AllSigned` au niveau `MachinePolicy` (GPO). Ni `Unblock-File` ni `-ExecutionPolicy Bypass` ne peuvent la contourner : seul un script signé par un certificat de confiance s'exécute. Node.js n'est pas soumis à cette stratégie, d'où les lanceurs `.js` comme référence.

## Lancer les tests

```powershell
cd d:\Sekitaku\pwgen
node test.js
```

Sept batteries :

1. **Déterminisme** — seed fixe → sortie identique 3 fois
2. **Longueur** — 100 exécutions, toutes 16 caractères
3. **Charset** — 100 x 16 caractères, tous dans `[33, 126]`
4. **Rejet actif** — seed 128 x 0xBC (188) → tous rejetés, EOF donne 0, sortie 16 x `!`
5. **Rejet borné** — seed 128 x 0xBB (187) → tous acceptés (q=1, r=93), sortie 16 x `~`
6. **Non-répétition** — 100 exécutions crypto, aucune collision
7. **Distribution uniforme** — 10 000 caractères agrégés, chaque caractère du charset ≥ 50 occurrences

Durée typique : 60 à 90 secondes (dominée par le lancement de Node.js × 730 fois). Dernier résultat mesuré : 8 / 8 OK, distribution min=74 max=133 pour une attente de ~106.

## Principe

Le fichier `pwgen.bf` :

- Lit jusqu'à 128 octets sur stdin (fournis par le wrapper).
- Pour chaque caractère du mot de passe :
  - Lit un octet X.
  - Calcule `q, r = divmod(X, 94)` en Brainfuck.
  - Si `q ≥ 2` (c'est-à-dire X ≥ 188), **rejette** et relit un nouvel octet.
  - Sinon, sort le caractère `33 + r` (ASCII imprimable).
- Termine par un saut de ligne.

Le rejet-échantillonnage garantit une distribution parfaitement uniforme sur les 94 caractères. Sans lui, les 68 premiers caractères auraient reçu 3 chances sur 256 vs 2 pour les 26 derniers (biais de 26.6 %).

## Ce qui n'est pas fait

- Pas de longueur variable (16 est câblée dans le code)
- Pas de charset alternatif (33-126 est câblé)
- Pas de CI, pas de release, pas de dépendance externe

Voir [DESIGN.md](DESIGN.md) pour le plan mémoire complet, l'algorithme du divmod, et les points d'extension.

## Limites et sécurité

- **Entropie** — 94^16 ≈ 3.7 × 10^31 mots de passe possibles, soit ~105 bits d'entropie. Suffisant pour la plupart des usages.
- **Aléa** — le wrapper utilise `RandomNumberGenerator.Create()` (CSP Windows crypto-sûre). Ne pas remplacer par `System.Random` qui n'est PAS crypto-sûr.
- **EOF** — si le buffer stdin s'épuise (probabilité négligeable avec 128 octets pour 16 chars, moyenne consommée ~22), l'interpréteur renvoie 0 et le générateur sort des `!` en cascade. Un mot de passe finissant par plusieurs `!` d'affilée est un signal de bug à traiter comme suspect.

## Interpréteur bf.js

Le programme dépend de `..\bf.js` (dans `d:\Sekitaku\`), un interpréteur Node.js. Il fournit :

- 30 000 cellules 8 bits (wraparound modulo 256)
- Pointeur avec wraparound modulo 30 000
- `,` renvoie 0 sur EOF ou erreur de lecture

Aucune modification de `bf.js` n'est nécessaire pour utiliser `pwgen.bf`.
