==================================================
EXERCICE 01   Afficher le chiffre 7
==================================================

Cible   7 vaut ASCII 55

Decomposition
==================================================

55 = 5 fois 11   reste nul   aucun ajustement residuel

Comparaison des factorisations
  5 fois 11   sept plus onze = dix huit symboles dans la boucle
  11 fois 5   onze plus cinq = idem   mais compteur plus long
  Retenu   5 fois 11   compteur le plus court

Table des boites
==================================================

  boite 0   compteur de boucle   5   detruit a 0
  boite 1   accumulateur   resultat de 5 fois 11 = 55 = 7

Code
==================================================

+++++              boite 0 = 5
[->+++++++++++<]   boucle 5 fois   boite 1 augmente de 11   total 55
>.                 aller en boite 1   afficher 7
