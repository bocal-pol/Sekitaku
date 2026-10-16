=====================================================
PLAN DES BOITES
=====================================================

Idee cle  on choisit 3 valeurs de base arrondies
  100  proche de b c et a
  110  proche de o l t k et u
   10  c est exactement LF le retour a la ligne

  boite 3  =  100  =  2 fois 2 fois 5 fois 5  exact
  boite 6  =  110  =  2 fois 5 fois 11  exact
  boite 8  =   10  =  2 fois 5  exact

Pourquoi la boite 3 et pas la boite 0

  La boucle pour 100 est   2 fois 2 fois 5 fois 5   4 facteurs premiers
  Le dernier facteur 5 joue deux roles a la fois
    case compteur de la boucle la plus profonde
    valeur ajoutee a chaque tour de cette boucle
  Les 3 autres facteurs ont chacun besoin d une case compteur
  Cases compteurs en 0  1  2   puis le resultat en 3

  Regle generale
    N facteurs premiers dans la boucle imbriquee
    N moins 1 cases compteurs occupees avant le resultat
    resultat en case N moins 1

  Pour 100  4 facteurs   3 cases compteurs   resultat en case 3
  Pour 110  3 facteurs   2 cases compteurs   resultat en case 3 plus 2 = 6
  Pour  10  2 facteurs   1 case compteur     resultat en case 6 plus 1 = 7 (donc 8 car on part de 7)

Comment obtenir chaque lettre en ajustant depuis la boite la plus proche

  b   vaut  98   boite 3 puis on enleve 2          boite reste a  98
  o   vaut 111   boite 6 puis on ajoute 1           boite reste a 111
  c   vaut  99   boite 3 qui est a 98  on ajoute 1  boite reste a  99
  a   vaut  97   boite 3 qui est a 99  on enleve 2  boite reste a  97
  l   vaut 108   boite 6 qui est a 111 on enleve 3  boite reste a 108
  o   vaut 111   boite 6 qui est a 108 on ajoute 3  boite reste a 111
  t   vaut 116   boite 6 qui est a 111 on ajoute 5  boite reste a 116
  a   vaut  97   boite 3 qui est restee a 97 depuis la premiere fois
  k   vaut 107   boite 3 qui est a 97  on ajoute 10 boite reste a 107
  u   vaut 117   boite 6 qui est a 116 on ajoute 1  boite reste a 117
  LF  vaut  10   boite 8 sans ajustement

Le programme se deroule en 3 phases
  Phase 1  on remplit les 3 boites  sans rien afficher
  Phase 2  le doigt revient a la boite 3
  Phase 3  on affiche toutes les lettres en ajustant les boites

=====================================================
PHASE 1  CREATION DES 3 BOITES
=====================================================

100 = 2 fois 2 fois 5 fois 5  exact  resultat en boite 3
4 facteurs premiers donc 4 niveaux de boucle imbriquees
++[>++[>+++++[>+++++<-]<-]<-]

on avance de 4 cases pour commencer le bloc de la boite 6
110 = 2 fois 5 fois 11  exact  resultat en boite 6
>>>>++[>+++++[>+++++++++++<-]<-]

on avance de 3 cases pour commencer le bloc de la boite 8
10 = 2 fois 5  exact  resultat en boite 8
2 facteurs premiers donc 2 niveaux de boucle suffisent
>>>++[>+++++<-]

=====================================================
PHASE 2  LE DOIGT REVIENT A LA BOITE 3
=====================================================

toutes les boites compteurs sont videes a 0
on peut revenir sans perdre de valeur
4 cases vers la gauche  de la boite 7 vers la boite 3
<<<<

=====================================================
PHASE 3  ECRITURE EN AJUSTANT LES BOITES
=====================================================

les boites sont en 3  6  8
on suit la valeur courante de chaque boite
on ne la remet pas toujours a zero  cest voulu

b    on est en boite 3  valeur 100  on enleve 2  on obtient 98
--.

o    on avance de 3 cases de la boite 3 vers la boite 6
     la boite 6 vaut 110  on ajoute 1  on obtient 111  la boite reste a 111
>>>+.

c    on recule de 3 cases de la boite 6 vers la boite 3
     la boite 3 vaut 98  on ajoute 1  on obtient 99
<<<+.

a    on est toujours en boite 3  valeur 99  on enleve 2  on obtient 97
     la boite 3 reste a 97
--.

l    on avance de 3 cases de la boite 3 vers la boite 6
     la boite 6 vaut 111  on enleve 3  on obtient 108
>>>---.

o    on est toujours en boite 6  valeur 108  on ajoute 3  on obtient 111
+++.

t    on est toujours en boite 6  valeur 111  on ajoute 5  on obtient 116
     la boite 6 reste a 116
+++++.

a    on recule de 3 cases de la boite 6 vers la boite 3
     la boite 3 est restee a 97 depuis le premier a  sans ajustement
<<<.

k    on est toujours en boite 3  valeur 97  on ajoute 10 = 2 fois 5
     la case 2 est libre  compteur a 2  la boucle ajoute 5 a chaque tour
     2 tours de 5 = 10  la boite 3 passe a 107
<++[>+++++<-]>.

u    on avance de 3 cases de la boite 3 vers la boite 6
     la boite 6 vaut 116  on ajoute 1  on obtient 117
>>>+.

LF   on avance de 2 cases de la boite 6 vers la boite 8
     la boite 8 vaut 10  sans ajustement
>>.
