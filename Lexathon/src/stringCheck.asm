## String Check Subroutine

## Creator: Daniel Lecheler

## Description:
## Compares a string passed to it, with a list of possible strings and if the string is a match, place it in another list
## and then remove it from the first list, and finally returning a boolean value that represents a correct or incorrect response

# PARAMETERS: 		$a0 = addres of the input made by the user.
#			$a1 = the memory address of the list of correct words generated from
#				the letters provided.
# SAVED REGISTERS:	
# RETURNS:		$v0 = the length of the input if the input is correct, or -1 if the input is incorrect

StringCheck:

addi $sp, $sp, -4
sw $ra, 0($sp)

li $t2, 0	# zeros out $t2 to be prepared for their uses in the primary loop (StrChLoop0)

move $t3, $a0	# copies the address of the input to $t3

StrChLoop0:	# the primary loop; compares each individual letter of every word

lb $t0, 0($a0)	# loads the current letters of the strings to $t0 and $t1
lb $t1, 0($a1)	

bne $t0, $t1, StrChReset # compares the current letters, and branches if the letters are different 

beqz $t1, StrChLoop1	# exits the loop if the null terminator is reached in the current correct string

addi $a0, $a0, 1	# increments the current letter of each string, and the size of the string as well stored in $t2
addi $a1, $a1, 1	
addi $t2, $t2, 1

j StrChLoop0

StrChLoop1:

beqz $t0, StrMatch	# concludes the words are a match if $t0 is also null terminated

addi $a1, $a1, 1	# increments the current letter of the list of correct strings
lb $t1, 0($a1)		# loads the letter to $t0

beqz $t1, StrNoMatch	# ends search when double null terminator is reached, and concludes there is no match

sub $a0, $a0, $t2	# resets the user input
li $t2, 0		# zeroes out the letter counter
j StrChLoop0		# returns to the primary loop


StrChReset:

addi $a1, $a1, 1	# increments the letter in the list of correct strings
lb $t1, 0($a1)		# loads the letter to $t0
bnez $t1, StrChReset	# runs the loop until the null terminator is reached
move $a0, $t3		# restes the user input
li $t2, 0		# zeroes out the counter
j StrChLoop0		# returns to the primary loop


StrMatch:

move $v0, $t2	# returns the length of the input

move $a0, $t2	# prepares $a0 to be passed to Scoring subroutine
jal Scoring	

lw $ra, 0($sp)
addi $s0, $s0, 4

jr $ra

StrNoMatch:
li $v0, -1	# returns -1 if there is no match

lw $ra, 0($sp)
addi $s0, $s0, 4

jr $ra


