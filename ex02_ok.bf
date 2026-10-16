==================================================
EXERCICE 02   Afficher OK
==================================================

Cibles   O vaut ASCII 79   K vaut ASCII 75
Delta entre les deux lettres   79 vers 75   soit enlever 4

Decomposition de O = 79
==================================================

79 = 7 fois 11 plus 2

Comparaison des options
  7 fois 11 plus 2   sept plus onze plus deux = vingt symboles   retenu
  8 fois 9  plus 7   huit plus neuf plus sept  = vingt quatre     ecarte

Strategie boite unique   valeur courante tracee lettre par lettre
  apres la boucle   boite 1 vaut 7 fois 11 = 77
  on ajoute 2       boite 1 vaut 79   on affiche O
  on enleve 4       boite 1 vaut 75   on affiche K

Table des boites
==================================================

  boite 0   compteur de boucle   7   detruit a 0
  boite 1   accumulateur   valeur courante ci dessous

    init   7 fois 11 = 77
    plus 2             79   O
    moins 4            75   K

Code
==================================================

+++++++            boite 0 = 7
[->+++++++++++<]   boucle 7 fois   boite 1 augmente de 11   total 77
>++.               boite 1 = 79   O
----.              boite 1 = 75   K
