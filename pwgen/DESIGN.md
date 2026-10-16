# DESIGN — pwgen.bf

Document technique du générateur de mot de passe Brainfuck.

## 1. Contexte et contraintes

Cible : mono-fichier Brainfuck exécuté par `bf.js` (interpréteur Node maison du dossier parent). Style pédagogique aligné avec `bocalotaku.bf` et `jeremy.bf` (commentaires français plain-text, structure phasée).

Contraintes du langage :

- 8 instructions, cellules 8 bits (`0-255`, wraparound).
- Pas de RNG natif, pas de division ni modulo natifs.
- Pas de comparaison directe, pas de table de lookup native.

Choix produit (validés par l'utilisateur) :

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Charset | ASCII 33-126 (94 chars) | `!` à `~` |
| Longueur | 16 fixe | Câblé en dur |
| Rejet | Actif | Élimine le biais 26.6 % |
| Source d'aléa | stdin, alimenté par wrapper PowerShell | 128 octets crypto |

## 2. Plan mémoire

Sept cellules utilisées, cases 0 à 6.

| Case | Rôle | Cycle de vie |
|------|------|--------------|
| 0 | Compteur principal N | Initialisé à 16, décrémenté chaque itération outer |
| 1 | Reject flag | 1 = relire, 0 = accepter. Reset à chaque itération inner |
| 2 | n du divmod (octet X lu) | Écrit par `,`, consommé par divmod |
| 3 | d du divmod (94, constante recréée) | Rempli avant chaque divmod, modifié par divmod |
| 4 | r du divmod (résultat X mod 94) | Sorti après acceptation |
| 5 | q du divmod (X div 94, quotient) | Testé pour le rejet, effacé après |
| 6 | Cellule tampon | Reste à zéro (divmod la traverse sans écrire) |

Aucun besoin de cellule au-delà de la 6.

## 3. Algorithme

### 3.1 Vue d'ensemble

```
initialiser case 0 = 16
répéter 16 fois :
    répéter jusqu'à acceptation :
        lire X sur stdin
        calculer q, r = divmod(X, 94)
        si q >= 2 : rejeter, relire
    afficher (33 + r)
afficher LF
```

### 3.2 Divmod utilisé

Pattern classique de la BF community :

```
[->-[>+>>]>[+[-<+>]>+>>]<<<<<]
```

- **Précondition** : pos 0 = n, pos 1 = d, pos 2 à 4 = 0, pointeur en pos 0
- **Postcondition** : pos 0 = 0, pos 1 = d - r, pos 2 = r, pos 3 = q, pos 4 = 0

Vérification (mesurée sur `bf.js`) :

| n | d | r attendu | q attendu | r reçu | q reçu |
|---|---|-----------|-----------|--------|--------|
| 3 | 5 | 3 | 0 | 3 | 0 |
| 5 | 3 | 2 | 1 | 2 | 1 |
| 47 | 94 | 47 | 0 | 47 | 0 |
| 93 | 94 | 93 | 0 | 93 | 0 |
| 94 | 94 | 0 | 1 | 0 | 1 |
| 95 | 94 | 1 | 1 | 1 | 1 |
| 187 | 94 | 93 | 1 | 93 | 1 |
| 188 | 94 | 0 | 2 | 0 | 2 |

Dans notre code, `n` est en case 2, `d` en case 3, donc le pattern écrit `r` en case 4 et `q` en case 5.

### 3.3 Test « q ≥ 2 » pour le rejet

Idiome BF sur trois niveaux d'imbrication :

```
[ - [ set_flag; clear_q ] ]
```

Trace :

- q = 0 : outer skip → flag = 0 (accept)
- q = 1 : outer entre, décrémente à 0, inner skip → flag = 0 (accept)
- q = 2 : outer entre, décrémente à 1, inner entre, set_flag, clear q → flag = 1 (reject)

Le seul cas où le flag est levé est `q = 2`, ce qui correspond à `X ∈ [188, 255]`. Exactement la fenêtre à rejeter.

### 3.4 Structure du code Brainfuck

Trois phases explicites :

**Phase 1** — Initialisation :
```
++++++++++++++++       # case 0 = 16
```

**Phase 2** — Boucle principale (16 itérations) :
```
[
  -                    # décrémente N
  >+                   # case 1 = 1 (entrer boucle interne)
  [                    # boucle interne (rejet)
    [-]                # reset reject_flag
    >[-]>[-]>[-]>[-]   # nettoie workspace cases 2-5
    <<< , >            # lit X en case 2, pointeur en case 3
    ++++...94...       # case 3 = 94
    <                  # pointeur en case 2 (n du divmod)
    [divmod]           # divmod (voir 3.2)
    >>>                # pointeur en case 5 (q)
    [test q>=2]        # met case 1 = 1 si rejet
    <<<<               # retour case 1 pour test loop
  ]
  >>>+++...33...       # case 4 += 33 (offset ASCII)
  .                    # affiche
  [-]                  # reset case 4
  <<<<                 # retour case 0
]
```

**Phase 3** — Saut de ligne :
```
++++++++++             # case 0 = 10 (LF)
.
```

### 3.5 Volumétrie du code source

- Total caractères BF : 251
- Setup : 16 `+`
- Constante 94 (rechargée à chaque itération) : 94 `+`
- Constante 33 (offset) : 33 `+`
- Constante 10 (LF) : 10 `+`

## 4. Lanceurs

Deux lanceurs équivalents : `run.js` (référence, Node) et `run.ps1` (PowerShell). Le poste cible applique `AllSigned` par GPO au niveau `MachinePolicy`, ce qui rend tout `.ps1` non signé inexécutable. `run.js` utilise `crypto.randomBytes(128)` et `spawnSync` avec l'option `input`, qui transmet les octets bruts à stdin sans BOM.

`run.ps1` fait trois choses :

1. Génère 128 octets crypto-sûrs via `RandomNumberGenerator.Create().GetBytes()` (l'API `Fill()` n'existe pas dans le .NET Framework livré avec ce Windows).
2. Écrit les octets dans un fichier temporaire.
3. Pipe le fichier vers `node bf.js pwgen.bf` via `cmd /c type ... | node ...`.

**Pourquoi cmd et pas StandardInput ?** Le `StreamWriter` que .NET expose sur `Process.StandardInput` insère un BOM UTF-8 (0xEF 0xBB 0xBF) lors de sa création. Ces trois octets se retrouvent en tête du flux et bf.js les lit comme les 3 premiers octets « aléatoires ». Passer par `cmd /c type` transmet le fichier binaire brut sans BOM.

**Pourquoi 128 octets ?** Probabilité d'accepter un octet = 188/256 ≈ 0.734. Moyenne pour 16 acceptations : 16 / 0.734 ≈ 21.8 octets. Écart-type ≈ 5.4. La probabilité d'épuisement du buffer sur 128 octets est astronomiquement faible (bien inférieure à 10⁻⁵⁰). Marge très confortable, coût nul.

## 5. Points d'extension

Le MVP livre le strict nécessaire. Extensions possibles listées par effort croissant :

### Facile — Longueur configurable

Remplacer `++++++++++++++++` (case 0 = 16) par une lecture du premier octet stdin, clampée entre 8 et 64. Modifier le wrapper pour prendre `-Length` en paramètre.

### Facile — Charsets alternatifs

Changer le seuil de rejet et l'offset. Exemples :

| Charset | Diviseur | Seuil rejet | Offset |
|---------|----------|-------------|--------|
| Alnum minuscules 0-9a-z | 36 | 252 (7×36) | Voir §5.1 |
| Alnum mixte 0-9a-zA-Z | 62 | 248 (4×62) | Voir §5.1 |
| Chiffres 0-9 | 10 | 250 (25×10) | 48 |

Les charsets non contigus (alnum) nécessitent un mapping conditionnel après divmod, plus complexe.

### Moyen — Sortie multi-mots-de-passe

Wrapper produit N mots de passe en un run en itérant.

### Difficile — PRNG en Brainfuck pur

Implémenter un LCG (`x_{n+1} = (a*x_n + c) mod 256`) alimenté par 1 seed stdin. Élimine la dépendance au buffer crypto initial, mais qualité d'aléa très inférieure. Pas recommandé pour un vrai mot de passe.

### Difficile — Charset avec espaces exclus

Actuellement `!` et `~` sont inclus. Pour exclure les caractères prêtant à confusion visuelle (`I`, `l`, `1`, `O`, `0`), il faut soit :

- Rejet-échantillonnage étendu (rejeter aussi les caractères à exclure)
- Table de lookup en mémoire BF (long à construire)

## 6. Décisions techniques

### Pourquoi divmod plutôt qu'une comparaison directe ?

Une comparaison « X < 188 » en Brainfuck pur nécessite un algorithme de décrément parallèle avec flag de kill, typiquement 30 à 50 caractères et sujet à erreurs subtiles. Le divmod fait le calcul du modulo ET fournit le test de rejet en un seul pattern (via `q ≥ 2`).

### Pourquoi la constante 94 est-elle rechargée à chaque itération ?

Le pattern divmod détruit son diviseur (le remplace par `d - r`). Le recharger avec 94 `+` est plus simple qu'une copie non-destructive depuis une case permanente.

### Pourquoi pas de cellule permanente pour l'offset 33 ?

Similaire : 33 `+` inline est plus lisible que le mécanisme de copie. Le coût CPU est négligeable (16 itérations × ~50 ops de trop = 800 ops sur des millions).

## 7. Vérifications effectuées

Tests manuels durant le développement :

- divmod isolé : 8 valeurs testées (3, 5, 47, 93, 94, 95, 187, 188) toutes correctes.
- Rejet actif : seed 0xBC (188) → 16 x `!` (attendu, EOF donne 0).
- Rejet borné : seed 0xBB (187) → 16 x `~` (attendu, r = 93).
- Déterminisme : même seed → même sortie 3 fois.
- Crypto : 3 exécutions avec RNG donnent 3 sorties distinctes.

Tests automatisés dans `test.ps1` (7 batteries, voir README).

## 8. Ce qui a failli être un piège

- **Commentaires avec opérateurs BF** — première version : commentaires contenant `+`, `-`, `<`, `>`, `[`, `]` étaient interprétés par bf.js. Solution : commentaires purement alphabétiques.
- **BOM UTF-8 sur stdin** — le `StreamWriter` .NET ajoutait `EF BB BF` en tête. Solution : passer par `cmd /c type`.
- **API RNG** — `RandomNumberGenerator.Fill()` n'existe pas dans le .NET Framework livré. Solution : `Create()` + `GetBytes()`.
- **Résidus dans le workspace** — sans nettoyage explicite avant divmod, les cases 4 et 5 pouvaient contenir des valeurs des itérations précédentes qui cassaient le pattern. Solution : `>[-]>[-]>[-]>[-]` au début de chaque itération interne.

## 9. Références

- Interpréteur : `..\bf.js`
- Style de code : `..\bocalotaku.bf`, `..\jeremy.bf`
- Recettes ASCII : `..\ascii_bf.md`
- Pattern divmod : Brainfuck algorithms wiki (esolangs.org)
