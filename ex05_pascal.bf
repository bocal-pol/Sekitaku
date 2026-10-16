==================================================
EXERCICE 05   Afficher Pascal
==================================================

Cibles   P=80   a=97   s=115   c=99   a=97   l=108

Observation cle
==================================================

Le a apparait deux fois   meme valeur 97   on le place dans une boite dediee
Le c vaut 99   soit le a plus 2   on repart de boite a   on ajoute 2
Apres le c on enleve 2 pour retrouver le a   puis on affiche le a a nouveau

On obtient ainsi 4 boites seulement   au lieu de 6

Decomposition avec compteur 10
==================================================

Un compteur unique de 10 iterations remplit les 4 boites en parallele
Les multiplicateurs sont choisis pour minimiser les ajustements residuels

  boite 1   10 fois  8 = 80    delta nul      P vaut 80
  boite 2   10 fois 10 = 100   delta moins 3   a vaut 97   reutilisee pour c et a
  boite 3   10 fois 12 = 120   delta moins 5   s vaut 115
  boite 4   10 fois 11 = 110   delta moins 2   l vaut 108

Justification du compteur 10
  Base 10   multiplicateurs entre 8 et 12   ajustements tous inferieurs a 6
  Base 9    certains multiplicateurs montent a 13   plus long a ecrire
  Base 11   genere des ajustements en positif la ou zero suffirait

Table des boites
==================================================

  boite 0   compteur de boucle   10   detruit a 0
  boite 1   P   80 exact   aucun ajustement
  boite 2   a   100 puis 97   reutilisee pour c = 99 et second a = 97
  boite 3   s   120 puis 115
  boite 4   l   110 puis 108

Suivi de boite 2 lettre par lettre
  100 au depart
  moins 3     97   afficher a
  plus  2     99   afficher c
  moins 2     97   afficher a   second passage   boite restauree
  inchangee   97   afficher a   (affichage direct sans navigation)

Code
==================================================

PHASE 1   remplissage des 4 boites en une seule boucle

++++++++++   boite 0 = 10
[            repeter 10 fois
>++++++++      boite 1 augmente de 8
>++++++++++    boite 2 augmente de 10
>++++++++++++  boite 3 augmente de 12
>+++++++++++   boite 4 augmente de 11
<<<<-          retour boite 0   decrementer
]            fin boucle   boite 0 = 0

PHASE 2   emission lettre par lettre   suivi de la valeur courante

>.           boite 1 = 80                    P
>---.        boite 2 = 100 vers 97           a
>-----.      boite 3 = 120 vers 115          s
<++.         boite 2 = 97 vers 99            c
--.          boite 2 = 99 vers 97            a   boite restauree
>>--.        boite 4 = 110 vers 108          l
