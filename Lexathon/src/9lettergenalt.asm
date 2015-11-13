#  -------------------------------------------------------------------------------------------------
#   FILE: 9lettergenalt.asm								  							  
#   AUTHOR: Jeffrey Neer							 							  
#   DESCRIPTION: Contains subroutine that generates nine letters based on prexisting 9 letter words						  
#  -------------------------------------------------------------------------------------------------

.data
Letters: .space 10 # Will store the nine generated letters(Plus one null terminator)
file_name: .asciiz "dictionary_9_letter_words.txt" #Name of the dictionary text file
nine_letter_words: .space 150000 #~150 KB

.text
#Main
main:
	#Load file
	la $a0, file_name
	la $a1, nine_letter_words
	jal loadFile
	move $a0, $v1
	jal genMain
	li $v0, 10
	syscall
# --------------------------------------------------------------------------------------------------------
# Prameters: a0: Address where letters will be saved
#
#
#stores all results to memory location labeled "Letters"
# --------------------------------------------------------------------------------------------------------
genMain:
# Save $s0, and #s1 by convention
addi $sp, $sp -12
sw $ra , 8($sp)
sw $s0, 4($sp)
sw $s1, 0($sp)

# Main Stuff
la $s0, Letters # Load Letters address into $s0
la $s1, nine_letter_words
li $a1, 11619 # Sets upper bound of random number generation as 11619
li $v0, 42 # Sets syscall to generate sudo-random number
syscall # Result stored in $a0
move $t0, $a0 #move random number to $t0
# These next lines are for the bitwise multiplication by 10
sll $t1, $t0, 4 #Multiply by 16 (16x)
sll $t2, $t0, 2 #Multiply by 4 (4x)
sll $t3, $t0, 1 #Multiply by 2 (2x)
sub $t0, $t1, $t2 #$t0=$t1(16x)-$t2(4x)
sub $t0, $t0, $t3 #$t0=$t0(12x)-$t3(2x)

add $s1, $s1, $t0 # $s1 + random offset by 10 bytes

#read the word
lb $t0, 0($s1)
sb $t0, 0($s0)
lb $t0, 1($s1)
sb $t0, 1($s0)
lb $t0, 2($s1)
sb $t0, 2($s0)
lb $t0, 3($s1)
sb $t0, 3($s0)
lb $t0, 4($s1)
sb $t0, 4($s0)
lb $t0, 5($s1)
sb $t0, 5($s0)
lb $t0, 6($s1)
sb $t0, 6($s0)
lb $t0, 7($s1)
sb $t0, 7($s0)
lb $t0, 8($s1)
sb $t0, 8($s0)
lb $t0, 9($s1)
sb $t0, 9($s0)

lw $ra , 8($sp)
lw $s0, 4($sp)
lw $s1, 0($sp)
addi $sp, $sp 12
jr $ra











# "loadFile" subroutine
# PARAMETERS:		$a0 = address of the name of the ".txt" file to open.
#				All words inside MUST be upper-case.
#			$a1 = address of the space to save data
# SAVED REGISTERS:	none
# DESCRIPTION:		Loads the file's contents into data labeled "dictionary".
#			**IMPORTANT**: file WILL NOT LOAD unless it is in the
#			SAME DIRECTORY as your MARS .jar!!!!!!!
# RETURNS:		$v0 = Number of bytes read from the file, or -1 if failed
#				to open the file.
#			$v1 = Address of the label "dictionary".
loadFile:
	#Load address of space
	move $t0, $a1
	#Open file
	move $a1, $zero
	li $v0, 13
	syscall
	#Read the entire file and store in dictionary
	move $a0, $v0
	move $a1, $t0
	li $a2, 116190
	li $v0, 14
	syscall
	#Move byte count
	move $t1, $v0
	#Close file
	li $v0, 16
	syscall
	#Return
	move $v0, $t1
	move $v1, $t0
	jr $ra


	