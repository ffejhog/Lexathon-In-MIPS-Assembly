#  --------------------------------------------------------------------------------
# | FILE: letterGen.asm								  |
# | AUTHOR: Jeffrey Neer							  |
# | DESCRIPTION: Contains subroutine that generates nine letters based on 3 rules.|
# |	       1. FIrst letter is completely random, and is always required	  |
# |	       2. Second letter is always a vowel				  |
# |	       3. Third-Ninth letters are randomly generated			  | 
#  --------------------------------------------------------------------------------
.data
Letters: .space 9 # Will store the nine generated letters

.text
# --------------------------------------------------------------------------------------------------------
# Program has no required parameters, and stores all results to memory location labeled "Letters"
# Program only uses temp registers, so it is the duty of the calling function to save any required data.
# --------------------------------------------------------------------------------------------------------
Main:
la $s0, Letters # Load Letters address into $s0
jal genLetter # Generate one random letter into $s1
sb $s1, 0($s0) # Save first required letter into Letters first byte
jal genVowel
sb $s1, 1($s0) # Save second letter into Letters second byte (This letter is a vowel)

# ----------------------------------------------
# This loop Generates the last 7 random letters
# ----------------------------------------------

addi $t0, $s0, 2 # store Address of Letters into $t0(factoring the first two bytes have to letters already in them)
li $t1, 7 # i=7
letterGenLoop:
beq $t1, 0, End # if i==0 goto End ********** THIS IS THE EXIT FOR THE LOOP **********
subi $t1, $t1, 1 # i--
jal genLetter # Generate one random letter into $s1
sb $s1, 0($t0) # Store into the 3-9th memory location
addi $t0, $t0, 1 #Incement the address so the next character is stored in the right place
j letterGenLoop # Loop again




# ----------------------------------------
# This method generates one random letter
# Returns random letter in $s1
# ----------------------------------------
genLetter:
li $a1, 26 # Sets upper bound of random number generation as 26
li $v0, 42 # Sets syscall to generate sudo-random number
syscall # Result stored in $a0
addi $s1, $a0, 65 # puts random number(Plus the offset to account for ascii) into #s1
jr $ra # Return to calling function

# ----------------------------------------
# This method generates one vowel letter
# Returns vowel letter in $s1
# ----------------------------------------
genVowel:
li $a1, 4 # Sets upper bound of random number generation as 4
li $v0, 42 # Sets syscall to generate sudo-random number
syscall # Result stored in $a0
beq $a0, 0, vowela #Checks if $a0 == 0
beq $a0, 1, vowele #Checks if $a0 == 1
beq $a0, 2, voweli #Checks if $a0 == 2
beq $a0, 3, vowelo #Checks if $a0 == 3
beq $a0, 4, vowelu #Checks if $a0 == 4
vowela: #Sets $s1 to 'a' and returns
li $s1, 65
jr $ra
vowele:#Sets $s1 to 'e' and returns
li $s1, 69
jr $ra
voweli:#Sets $s1 to 'i' and returns
li $s1, 73
jr $ra
vowelo:#Sets $s1 to 'o' and returns
li $s1, 79
jr $ra
vowelu:#Sets $s1 to 'u' and returns
li $s1, 85
jr $ra




End: