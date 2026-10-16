=====================================================
PLAN DES BOITES
=====================================================

On choisit 4 valeurs de base par facteurs premiers

  72   H en plein dans la zone basse des lettres
  100  cible principale pour la zone haute
   32  espace et point d exclamation
   10  retour a la ligne

  boite 4  =   72  =  2 fois 2 fois 2 fois 3 fois 3  exact
  boite 8  =  100  =  2 fois 2 fois 5 fois 5  exact
  boite 13 =   32  =  2 fois 2 fois 2 fois 2 fois 2  exact
  boite 15 =   10  =  2 fois 5  exact

Pourquoi la boite 4 et pas la boite 0

  La boucle pour 72 est   2 fois 2 fois 2 fois 3 fois 3   5 facteurs premiers
  Le dernier facteur 3 joue deux roles a la fois
    case compteur de la boucle la plus profonde
    valeur ajoutee a chaque tour de cette boucle
  Les 4 autres facteurs ont chacun besoin d une case compteur
  Cases compteurs en 0  1  2  3   puis le resultat en 4

  Regle generale
    N facteurs premiers dans la boucle imbriquee
    N moins 1 cases compteurs occupees avant le resultat
    resultat en case N moins 1

  Pour  72  5 facteurs   4 cases compteurs 0 1 2 3    resultat en 0 plus 4 = case 4
  Pour 100  4 facteurs   3 cases compteurs 5 6 7      resultat en 5 plus 3 = case 8
  Pour  32  5 facteurs   4 cases compteurs 9 10 11 12 resultat en 9 plus 4 = case 13
  Pour  10  2 facteurs   1 case compteur 14            resultat en 14 plus 1 = case 15

Comment obtenir chaque lettre en ajustant depuis la boite la plus proche
Tout ajustement superieur a 1 est exprime en facteurs premiers avec une boucle

  H   vaut  72   boite 4  sans ajustement
  e   vaut 101   boite 8  on ajoute 1                      boite reste a 101
  l   vaut 108   boite 8  qui est a 101  on ajoute 7        boite reste a 108
  l   vaut 108   boite 8  sans ajustement
  o   vaut 111   boite 8  qui est a 108  on ajoute 3        boite reste a 111
  sp  vaut  32   boite 13 sans ajustement
  W   vaut  87   boite 4  qui est a 72   on ajoute 15 = 3 fois 5  boite reste a 87
  o   vaut 111   boite 8  sans ajustement     boite est restee a 111
  r   vaut 114   boite 8  qui est a 111  on ajoute 3        boite reste a 114
  l   vaut 108   boite 8  qui est a 114  on enleve 6 = 2 fois 3   boite reste a 108
  d   vaut 100   boite 8  qui est a 108  on enleve 8 = 2x2x2      boite reste a 100
  ex  vaut  33   boite 13 qui est a 32   on ajoute 1        boite reste a 33
  LF  vaut  10   boite 15 sans ajustement

Le programme se deroule en 3 phases
  Phase 1  on remplit les 4 boites  sans rien afficher
  Phase 2  le doigt revient a la boite 4
  Phase 3  on affiche toutes les lettres en ajustant les boites

=====================================================
PHASE 1  CREATION DES 4 BOITES
=====================================================

72 = 2 fois 2 fois 2 fois 3 fois 3  exact  resultat en boite 4
5 facteurs premiers donc 4 niveaux de boucle imbriquees
Pointeur part de case 0
++[>++[>++[>+++[>+++<-]<-]<-]<-]

Pointeur est revenu en case 0 apres la boucle
On avance de 5 cases pour aller en case 5 qui commence le bloc de la boite 8
100 = 2 fois 2 fois 5 fois 5  exact  resultat en boite 8
>>>>>++[>++[>+++++[>+++++<-]<-]<-]

Pointeur est revenu en case 5 apres la boucle
On avance de 4 cases pour aller en case 9 qui commence le bloc de la boite 13
32 = 2 fois 2 fois 2 fois 2 fois 2  exact  resultat en boite 13
>>>>++[>++[>++[>++[>++<-]<-]<-]<-]

Pointeur est revenu en case 9 apres la boucle
On avance de 5 cases pour aller en case 14 qui commence le bloc de la boite 15
10 = 2 fois 5  exact  resultat en boite 15
>>>>>++[>+++++<-]

=====================================================
PHASE 2  LE DOIGT REVIENT A LA BOITE 4
=====================================================

toutes les boites compteurs sont videes a 0
on peut revenir sans perdre de valeur
Pointeur est en case 14 apres la derniere boucle
10 cases vers la gauche  de la case 14 vers la boite 4 en case 4
<<<<<<<<<<

=====================================================
PHASE 3  ECRITURE EN AJUSTANT LES BOITES
=====================================================

les boites sont en 4  8  13  15
on suit la valeur courante de chaque boite
les ajustements superieurs a 1 utilisent des boucles a facteurs premiers

H    on est en boite 4  valeur 72  sans ajustement
.

e    on avance de 4 cases de la boite 4 vers la boite 8
     la boite 8 vaut 100  on ajoute 1  on obtient 101
>>>>+.

l    on est toujours en boite 8  valeur 101  on ajoute 7  on obtient 108
     7 est un nombre premier  on l ajoute directement
+++++++.

l    on est toujours en boite 8  valeur 108  sans ajustement
.

o    on est toujours en boite 8  valeur 108  on ajoute 3  on obtient 111
     3 est un nombre premier  on l ajoute directement
+++.

sp   on avance de 5 cases de la boite 8 vers la boite 13
     la boite 13 vaut 32  sans ajustement
>>>>>.

W    on recule de 9 cases de la boite 13 vers la boite 4
     la boite 4 est restee a 72
     on ajoute 15 = 3 fois 5
     la case 3 est libre  on la met a 3  boucle ajoute 5 a la boite 4  3 fois
<<<<<<<<<
<+++[>+++++<-]>.

o    on avance de 4 cases de la boite 4 vers la boite 8
     la boite 8 est restee a 111  sans ajustement
>>>>.

r    on est toujours en boite 8  valeur 111  on ajoute 3  on obtient 114
     3 est un nombre premier  on l ajoute directement
+++.

l    on est toujours en boite 8  valeur 114  on enleve 6 = 2 fois 3
     la case 7 est libre  on la met a 2  boucle enleve 3 a la boite 8  2 fois
<++[>---<-]>.

d    on est toujours en boite 8  valeur 108  on enleve 8 = 2 fois 2 fois 2
     la case 6 est libre  compteur exterieur 2
     la case 7 est libre  compteur interieur 2
     boucle en 2 niveaux  le niveau interieur enleve 2 deux fois = 4 par tour
     2 tours exterieurs = 8 enleves au total  la boite 8 passe a 100
<<++[>++[>--<-]<-]>>.

ex   on avance de 5 cases de la boite 8 vers la boite 13
     la boite 13 est restee a 32  on ajoute 1  on obtient 33
>>>>>+.

LF   on avance de 2 cases de la boite 13 vers la boite 15
     la boite 15 vaut 10  sans ajustement
>>.
