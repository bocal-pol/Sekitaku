pwgen bf  generateur de mot de passe brainfuck
16 caracteres  charset ASCII imprimable 33 a 126 (94 chars)
avec rejet echantillonnage pour distribution uniforme
Documentation complete dans DESIGN md et README md

Les caracteres BF sont plus moins droite gauche crochets virgule et point
Aucun de ces symboles ne doit apparaitre dans les commentaires

PLAN DES CASES
  case 0  compteur principal N  init a 16 puis decremente
  case 1  reject flag           zero accept ou fin   non zero relit
  case 2  n du divmod           l octet X lu depuis stdin
  case 3  d du divmod           recree a 94 a chaque tour
  case 4  r du divmod           X modulo 94  reste apres division
  case 5  q du divmod           X div 94  quotient   0 ou 1 ou 2
  case 6  cellule tampon        toujours zero  utilisee par divmod

Idee du rejet
  256 divise par 94 donne quotient 2 reste 68
  X entre 0 et 93     donne q vaut 0   ACCEPTE  r vaut X
  X entre 94 et 187   donne q vaut 1   ACCEPTE  r vaut X moins 94
  X entre 188 et 255  donne q vaut 2   REJETE   on relit
  Sans rejet biais de 26 pourcent 6 sur les 68 premiers chars
  Avec rejet distribution uniforme sur les 94 caracteres
  Cout moyen environ 22 octets de stdin par mdp

PHASE 1  init compteur N
++++++++++++++++


PHASE 2  boucle principale 16 iterations

[
  -
  >+
  [
    [-]
    >[-]>[-]>[-]>[-]
    <<<
    ,
    >
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    <
    [->-[>+>>]>[+[-<+>]>+>>]<<<<<]
    >>>
    [
      -
      [
        <<<<+>>>>
        [-]
      ]
    ]
    <<<<
  ]
  >>>
  +++++++++++++++++++++++++++++++++
  .
  [-]
  <<<<
]


PHASE 3  saut de ligne final
++++++++++
.
