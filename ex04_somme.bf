==================================================
EXERCICE 04   Lire deux chiffres et afficher leur somme
==================================================

Entree   deux caracteres chiffres consecutifs   ex 34
Sortie   le chiffre somme   ex 7

Mathematique
==================================================

  c1 = valeur ASCII du premier chiffre   ex   3 vaut 51
  c2 = valeur ASCII du second chiffre    ex   4 vaut 52

  On veut afficher le chiffre c1 moins 48 plus c2 moins 48
  Ce qui vaut   c1 plus c2 moins 48

  Astuce   additionner c1 et c2 en une seule boite
  puis retrancher 48 une seule fois

Decomposition de 48
==================================================

  48 = 6 fois 8
  6 boucles de 8 soustractions   aucune longue chaine de tirets

Table des boites
==================================================

  boite 0   accumulateur   c1 puis c1 plus c2 puis resultat ASCII
  boite 1   lecture de c2   puis compteur pour retrancher 48

Phase 1   lecture
  boite 0 = c1   premier chiffre ASCII
  boite 1 = c2   second  chiffre ASCII

Phase 2   addition
  transferer boite 1 dans boite 0   boite 0 = c1 plus c2

Phase 3   correction ASCII   retrancher 48 = 6 fois 8
  boite 1 sert de compteur 6   la boucle enleve 8 a boite 0 six fois
  boite 0 = c1 plus c2 moins 48 = ASCII du chiffre somme

Code
==================================================

,>,             lire c1 en boite 0   c2 en boite 1
[<+>-]          fusionner   boite 0 = c1 plus c2   boite 1 devient 0
<               retour en boite 0
>++++++         boite 1 = 6   compteur de soustraction
[<-------->-]   boucle 6 fois   boite 0 enleve 8   total retrancher 48
<.              afficher boite 0 = chiffre somme
