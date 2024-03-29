# -------------------------------------------------------------------------------------
# Programme de vérification de carré magique en MIPS
#
# But: Ce programme demande à l'utilisateur de saisir 16 valeurs comprises entre 1 et 16
#      dans un ordre quelconque. Ces valeurs sont stockées dans une matrice 4x4. Le programme
#      vérifie ensuite si cette matrice constitue un carré magique, c'est-à-dire si la somme
#      des nombres de chaque ligne, de chaque colonne, des deux diagonales principales, et
#      des quatre coins est égale. Ce programme a été codé dans le but d'un projet universitaire 
#      pour le cours IFT-1227, Architecture des ordinateurs I.
#      
# Date: 29 Mars 2024
#
# Auteurs: Tarik Hireche, Ilyesse Bouzommita, Erikha Kayembe Ngoma
# Adresses de courriel:
#   - tarik.hireche@umontreal.ca
#   - ilyesse.bouzommita@umontreal.ca
#   - erikha.kayembe.ngomba@umontreal.ca
#
# Matricules universitaires (codes permanents):
#   - Tarik Hireche: 20230189
#   - Ilyesse Bouzommita: 20276143
#   - Erikha Kayembe Ngoma: 202xxx (
# -------------------------------------------------------------------------------------


# Définition des segments de données pour les messages et le tableau
.data
msgEntree: .asciiz "Entrez une valeur de 1 à 16: "
msgNonValide: .asciiz "Le nombre entré n'est pas valide. Entrez une valeur de 1 à 16.\n"
msgDejaEntree: .asciiz "La donnée est déjà entrée! Entrez une autre valeur de 1 à 16.\n"
msgMatrice: .asciiz "Voici la matrice saisie:\n"
msgPasMagique: .asciiz "La matrice n'est pas un carré magique!\n"
msgMagique: .asciiz "Carré magique !!! La valeur magique est:"
tableauVerification: .space 64 # 16 entiers pour vérification des doublons 16 * 4 = 64 octets
matrice: .space 64 # 16 entiers pour la matrice, On résérve 64 octets d'espace mémoire.
espace: .asciiz " "
retourLigne: .asciiz "\n"

# Code
.text

# Fonction main
main:
    li $t0, 0x10040000 # Adresse de départ pour la matrice dans le heap
    li $t1, 4          # Taille de la matrice
    jal creerMat       # Créer la matrice avec les entrées utilisateur
    jal afficherMat    # Afficher la matrice
    jal estMagique     # Vérifier si la matrice est magique 

    # Terminer le programme
    li $v0, 10
    syscall

# Fonction creerMat
# Paramètres: aucun (utilise des valeurs globales et des saisies utilisateur)
# Retourne: rien
# Remplit la matrice avec des valeurs uniques saisies par l'utilisateur
creerMat:
    # Initialiser le compteur de valeurs saisies
    li $t2, 0
saisieBoucle:
    bge $t2, 16, finCreerMat # Sortir de la boucle si 16 valeurs ont été saisies

    # Afficher le message de saisie
    li $v0, 4
    la $a0, msgEntree
    syscall

    # Lire une valeur saisie par l'utilisateur
    li $v0, 5
    syscall
    move $t3, $v0 # Stocker la valeur saisie dans $t3

    # Vérifier la validité de la valeur
    blt $t3, 1, afficherNonValide # $t3 < 1
    bgt $t3, 16, afficherNonValide# $t3 > 16

    # Vérifier si la valeur a déjà été saisie
    la $t4, tableauVerification # On charge l'addresse du tableau de verification d'entrées
    add $t5, $t4, $t3            # Calcul de l'adresse dans le tableau de vérification
    sub $t5, $t5, 1              # Ajustement de l'index pour correspondre au tableau (1 à 16 vers 0 à 15) - On soustrait donc 1
    lb $t6, 0($t5)               # Charger la valeur actuelle à cet index
    bnez $t6, afficherDejaEntree # Vérifier si déjà saisie

    li $t6, 1                    # Préparer la valeur à stocker pour marquer comme saisie
    sb $t6, 0($t5)               # Marquer comme saisie


    # Stocker la valeur dans la matrice et le tableau de vérification
    sll $t7, $t2, 2         # Calculer l'offset pour la matrice - $t7 = $t2 * 4
    add $t8, $t0, $t7       # Adresse de destination dans la matrice - $t8 = offset + adresse de base
    sw $t3, 0($t8)           # Stocker la valeur dans la matrice matrice[index] = $t3

    # Incrémenter le compteur de valeurs saisies et continuer
    addi $t2, $t2, 1
    j saisieBoucle

# Section pour afficher un message lorsque la valeur saisie n'est pas valide
afficherNonValide:
    li $v0, 4               # $v0 = 4 : Préparer syscall pour afficher une chaîne de caractères
    la $a0, msgNonValide    # $a0 = adresse de msgNonValide : Charger l'adresse du message "non valide" dans $a0
    syscall                 # Exécuter syscall : Afficher le message "non valide"
    j saisieBoucle          # Sauter à saisieBoucle : Retourner à la boucle de saisie pour lire une nouvelle valeur

# Section pour afficher un message lorsque la valeur saisie a déjà été entrée
afficherDejaEntree:
    li $v0, 4               # $v0 = 4 : Préparer syscall pour afficher une chaîne de caractères
    la $a0, msgDejaEntree   # $a0 = adresse de msgDejaEntree : Charger l'adresse du message "déjà entrée" dans $a0
    syscall                 # Exécuter syscall : Afficher le message "déjà entrée"
    j saisieBoucle          # Sauter à saisieBoucle : Retourner à la boucle de saisie pour lire une nouvelle valeur

# Fin de la fonction creerMat et retour au point d'appel
finCreerMat:
    jr $ra                  # jr $ra : Sauter au retour d'adresse (retourner là où la fonction a été appelée)


# Fonction afficherMat - Affiche la matrice dans un format 4x4
# Paramètres: aucun (utilise des valeurs globales)
# Retourne: rien
afficherMat:
    li $t2, 0          # Compteur pour boucler sur les éléments de la matrice
    li $t0, 0x10040000 # Adresse de début de la matrice

    li $v0, 4
    la $a0, msgMatrice
    syscall

afficherBoucle:
    bge $t2, 16, finAfficherMat # Sortir de la boucle si tous les éléments sont affichés

    # Calculer l'adresse de l'élément à afficher
    sll $t3, $t2, 2     # Multiplier l'index par 4 pour obtenir l'offset de l'élément (car chaque entier est 4 octets)
    add $t4, $t0, $t3   # Ajouter l'offset à l'adresse de base pour obtenir l'adresse de l'élément
    lw $t5, ($t4)       # Charger la valeur de l'élément de la matrice

    # Afficher l'élément
    li $v0, 1
    move $a0, $t5
    syscall

    # Après avoir affiché chaque élément, afficher un espace
    li $v0, 4
    la $a0, espace
    syscall

    # Vérifier si nous avons affiché 4 éléments (fin de ligne)
    # Puisque les multiples de 4 en binaire se terminent toujours par 00 car 4 est 100 en binaire
    # nous pouvons utiliser un ET logique pour voir si nous avons fini d'afficher les 4 éléments sur une rangée.
    # Or, puisque notre index commence à 0, pour voir si notre nombre est un multiple de 4, on fait l'opération n % 4-1
    li $t6, 3	       # Préparer la valeur 3 pour le test
    and $t7, $t2, $t6  # Operation ET logique avec 3 pour voir si le compteur est un multiple de 4 - 1 (car index commence à 0)
    beq $t7, $t6, nouvelleLigne  # Si $t7 == 3, cela signifie que nous avons traité un multiple de 4 éléments; passer à une nouvelle ligne

continuerAffichage:
    addi $t2, $t2, 1   # Incrémenter le compteur et continuer
    j afficherBoucle

nouvelleLigne:
    # Après avoir affiché 4 éléments, passer à une nouvelle ligne
    li $v0, 4
    la $a0, retourLigne # On prépare l'affichage d'un retour à la ligne
    syscall
    addi $t2, $t2, 1   # Incrémenter le compteur après le saut de ligne
    j afficherBoucle   # Continuer avec le reste de la matrice

finAfficherMat:
    jr $ra

# Fonction estMagique - Vérifie si la matrice est un carré magique
# Entrée: utilise l'adresse de base de la matrice stockée dans $t0, ainsi que la taille de la matrice
# Sortie: $v0 contient -1 si la matrice n'est pas un carré magique, sinon la somme magique
estMagique:
    li $t1, 4                 # Taille de la matrice
    li $t2, 0                 # Initialiser le compteur de lignes/colonnes
    li $s0, 0                 # Somme pour vérification (somme de la première ligne comme référence)
    li $s1, 0                 # Somme temporaire pour les lignes
    li $s2, 0                 # Somme temporaire pour les colonnes
    li $s3, 0                 # Somme pour la diagonale principale
    li $s4, 0                 # Somme pour la diagonale secondaire

    # Calculer la somme de référence avec la première ligne
    li $t3, 0                 # Compteur pour éléments dans la ligne
calculSommeRef:
    bge $t3, $t1, continue    # Si on a fini avec la première ligne
    lw $t4, 0($t0)            # Charger l'élément de la matrice
    add $s0, $s0, $t4         # Ajouter à la somme de référence
    addi $t0, $t0, 4          # Passer à l'élément suivant
    addi $t3, $t3, 1          # Incrémenter le compteur d'éléments
    j calculSommeRef          # Boucler

continue:
    sub $t0, $t0, 16          # Revenir au début de la matrice

    # Vérification des lignes, colonnes et diagonales
verifLigneColonne:
    bge $t2, $t1, verifDiagonales # Passer aux diagonales si toutes les lignes/colonnes sont vérifiées
    li $t3, 0                 # Réinitialiser le compteur pour éléments de ligne/colonne
    li $s1, 0                 # Réinitialiser la somme de la ligne
    li $s2, 0                 # Réinitialiser la somme de la colonne

    # Boucle interne pour sommer les éléments de la ligne et de la colonne actuelle
    li $t5, 0                 # Compteur pour l'index dans la ligne/colonne
    sll $t6, $t2, 4           # Calculer le décalage pour la colonne (4 * $t2 * 4)
sommeLigneColonne:
    bge $t5, $t1, finSommeLigneColonne # Vérifier si la somme est complète
    lw $t7, 0($t0)            # Charger l'élément de la ligne
    add $s1, $s1, $t7         # Ajouter à la somme de la ligne
    lw $t8, 0($t0)            # Charger l'élément de la colonne
    add $s2, $s2, $t8         # Ajouter à la somme de la colonne
    addi $t0, $t0, 4          # Passer à l'élément suivant dans la ligne
    addi $t5, $t5, 1          # Incrémenter le compteur d'éléments
    j sommeLigneColonne       # Boucler sur les éléments de la ligne/colonne

finSommeLigneColonne:
    # Comparaison des sommes de ligne/colonne avec la somme de référence
    bne $s1, $s0, carreNonMagique # Si la somme de la ligne ne correspond pas
    bne $s2, $s0, carreNonMagique # Si la somme de la colonne ne correspond pas
    addi $t2, $t2, 1             # Passer à la ligne/colonne suivante
    j verifLigneColonne          # Continuer la vérification

verifDiagonales:
    li $t2, 0                     # Réinitialiser le compteur pour les diagonales 
    li $s3, 0                     # Réinitialiser la somme de la diagonale principale
    li $s4, 0                     # Réinitialiser la somme de la diagonale secondaire

calculDiagonales:
    li $t0, 0x10040000            # Assurer que $t0 pointe au début de la matrice (le premier élément)
    li $s3, 0                     # Réinitialiser la somme de la diagonale principale
    li $s4, 0                     # Réinitialiser la somme de la diagonale secondaire

    # Calculer la somme de la diagonale principale (11, 22, 33, 44)
    lw $t5, 0($t0)                # Charger 11
    add $s3, $s3, $t5
    lw $t5, 20($t0)               # Charger 22 (décalage de 5 mots = 20 octets)
    add $s3, $s3, $t5
    lw $t5, 40($t0)               # Charger 33 (décalage de 10 mots = 40 octets)
    add $s3, $s3, $t5
    lw $t5, 60($t0)               # Charger 44 (décalage de 15 mots = 60 octets)
    add $s3, $s3, $t5

    # Calculer la somme de la diagonale secondaire (14, 23, 32, 41)
    lw $t5, 12($t0)               # Charger 14 (décalage de 3 mots = 12 octets)
    add $s4, $s4, $t5
    lw $t5, 24($t0)               # Charger 23 (décalage de 6 mots = 24 octets)
    add $s4, $s4, $t5
    lw $t5, 36($t0)               # Charger 32 (décalage de 9 mots = 36 octets)
    add $s4, $s4, $t5
    lw $t5, 48($t0)               # Charger 41 (décalage de 12 mots = 48 octets)
    add $s4, $s4, $t5

    # Comparaison des sommes des diagonales avec la somme de référence ($s0)
    bne $s3, $s0, carreNonMagique # Si la somme de la diagonale principale ne correspond pas
    bne $s4, $s0, carreNonMagique # Si la somme de la diagonale secondaire ne correspond pas

    # Si tout est correct
    li $v0, 4                      # Préparer syscall pour afficher une chaîne
    la $a0, msgMagique             # Charger l'adresse du message de succès
    syscall
    li $v0, 1                      # Préparer syscall pour afficher un entier
    move $a0, $s0                  # Mettre la somme magique dans $a0
    syscall
    j finProgramme                 # Aller à la fin du programme

carreNonMagique:
    li $v0, 4                      # Préparer syscall pour afficher une chaîne
    la $a0, msgPasMagique          # Charger l'adresse du message d'échec
    syscall
    j finProgramme                 # Aller à la fin du programme

finProgramme:
    li $v0, 10                     # Terminer le programme
    syscall
