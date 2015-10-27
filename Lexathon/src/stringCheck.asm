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

li $t2, 0	# zeros out $t2 and $t4 to be prepared for their uses in the primary loop (StrChLoop0)
li $t4, 0

StrChLoop0:	# the primary loop; compares each individual letter of every word

lb $t0, 0($a1)	# loads the current letters of the strings to $t0 and $t1
lb $t1, 0($a0)	

seq $t3, $t0, $t1	# compares the current letters 

beqz $t0, StrChLoop1	# exits the loop if the null terminator is reached in either string
beqz $t1, StrChLoop1

add $t4, $t4, $t3	# $t4 keeps track of number of matches

addi $t0, $t0, 1	# increments the current letter of each string, and the size of the string as well stored in $t2
addi $t1, $t1, 1	
addi $t2, $t2, 1

j StrChLoop0

StrChLoop1:

seq $t3, $t3, 1		# uses $t3's value to determine if the strings are the same length (by null termination) 
seq $t4, $t4, $t2	# compares $t2 and $t4 to check if the length of the strings is equal to the number of char matches

add $t3, $t3, $t4	# adds the bools from the above checks and if they are both true (the value 2) then the strings are a match
beq $t3, 2, StrMatch	

li $t2, 0		# zeros out temporaries for reuse
li $t4, 0

addi $t0, $t0, 1	# increments the current letter of each string, and the size of the string as well stored in $t2
addi $t1, $t1, 1	
addi $t2, $t2, 1

beqz $t0, StrNoMatch	# ends search when double null terminator is reached

j StrChLoop0		# returns to primary loop

StrMatch:	# NEEDS TO BE COMPLETED BY MOVING CORRECT ANSWER FROM $a1 TO $a2



li $v0, 1	# returns 1 to be interpreted as a boolean true
jr $ra

StrNoMatch:
li $v0, 0	# returns 0 to be interpreted as a boolean false
jr $ra


