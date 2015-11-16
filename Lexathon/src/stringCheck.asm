## String Check Subroutine

## Creator: Daniel Lecheler

## Description:
## Compares a string passed to it, with a list of possible strings and if the string is a match, place it in another list
## and then remove it from the first list, and finally returning a boolean value that represents a correct or incorrect response

# PARAMETERS: 		$a0 = addres of the input made by the user.
#			$a1 = the memory address of the list of correct words generated from
#				the letters provided.
#			$a2 = the memory address of a list of correct answers already entered by the user
# SAVED REGISTERS:	
# RETURNS:		$v0 = boolean representing if the input is in the list or not

StringCheck:

li $t2, 0	# zeros out $t2 to be prepared for their uses in the primary loop (StrChLoop0)

StrChLoop0:	# the primary loop; compares each individual letter of every word

lb $t0, 0($a1)	# loads the current letters of the strings to $t0 and $t1
lb $t1, 0($a0)	

bne $t0, $t1, StrChReset # compares the current letters, and branches if the letters are different 

beqz $t0, StrChLoop1	# exits the loop if the null terminator is reached in the current correct string

addi $a0, $a0, 1	# increments the current letter of each string, and the size of the string as well stored in $t2
addi $a1, $a1, 1	
addi $t2, $t2, 1

j StrChLoop0

StrChLoop1:

beqz $t1, StrMatch	# concludes the words are a match if $t1 is also null terminated

addi $a1, $a1, 1	# increments the current letter of the list of correct strings
lb $t0, 0($a1)		# loads the letter to $t0

beqz $t0, StrNoMatch	# ends search when double null terminator is reached, and concludes there is no match

subi $a0, $a0, $t2	# resets the user input
li $t2, 0		# zeroes out the letter counter
j StrChLoop0		# returns to the primary loop


StrChReset:

addi $a0, $a0, 1	# increments the letter in the list of correct strings
lb $t0, 0($a0)		# loads the letter to $t0
bnez $t0, StrChReset	# runs the loop until the null terminator is reached
subi $a0, $a0, $t2	# restes the user input
li $t2, 0		# zeroes out the counter
j StrChLoop0		# returns to the primary loop


StrMatch:

li $v0, 1	# returns 1 to be interpreted as a boolean true
jr $ra

StrNoMatch:
li $v0, 0	# returns 0 to be interpreted as a boolean false
jr $ra


