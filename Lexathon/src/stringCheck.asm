.globl StringCheck

.text

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
# RETURNS:		$v0 = the length of the input if the input is correct, or -1 if the input is incorrect

StringCheck:

li $t2, 0	# zeros out $t2 to be prepared for their uses in the primary loop (StrChLoop0)
li $t3, 0	# the duplicate sentinal used to determine if a correct word is entered twice

StrChLoop0:	# the primary loop; compares each individual letter of every word

lb $t0, 0($a0)	# loads the current letters of the strings to $t0 and $t1
lb $t1, 0($a1)	

beqz $t1, StrChLoop1	# exits the loop if the null terminator is reached in the current correct string

bne $t0, $t1, StrChReset0 # compares the current letters, and branches if the letters are different

addi $a0, $a0, 1	# increments the current letter of each string, and the size of the string as well stored in $t2
addi $a1, $a1, 1	
addi $t2, $t2, 1

j StrChLoop0

StrChLoop1:

beqz $t0, StrDuplicateCheck	# concludes the words are a match if $t0 is also null terminated

addi $a1, $a1, 1	# increments the current letter of the list of correct strings
lb $t1, 0($a1)		# loads the letter to $t0

beqz $t1, StrNoMatch	# ends search when double null terminator is reached, and concludes there is no match

addi $a1, $a1, -1
lb $t1, 0($a1)

StrChReset0:		# if StrChLoop1 finds neither a match or a double null terminator, then StrChReset0 is used automatically

beqz $t1, StrChReset1
addi $a1, $a1, 1	# increments the letter in the list of correct strings
lb $t1, 0($a1)		# loads the letter to $t0
bnez $t1, StrChReset0	# runs the loop until the null terminator is reached

StrChReset1:

addi $a1, $a1, 1	# increments the letter in the list of correct strings from the null to the start of the next word
addi $t3, $t3, 1	# increments the current number of the word in the word list
sub $a0, $a0, $t2	# restes the user input
li $t2, 0		# zeroes out the counter
j StrChLoop0		# returns to the primary loop


StrMatch:

move $v0, $t2	# returns the length of the input

add $s3, $s3, $t2	# adds the length of the correct word to the total score

jr $ra

StrNoMatch:

li $v0, -1	# returns -1 if there is no match

jr $ra

StrDuplicateCheck:

la $t4, DuplicateList
add $t4, $t4, $t3
lb $t5, 0($t4)
bnez $t5, StrNoMatch
li $t5, 1
sb $t5 0($t4)
j StrMatch
