.globl Scoring

## Scoring Subroutine

## Creator: Daniel Lecheler

## Description:
## Recieves a length of a correct word and adds it to the current total score in $s0 (which should be zero when the game begins)
## and then returns the total score

# PARAMETERS: 		$a0 = length of the correct input
#			
# SAVED REGISTERS:	$s0 = the current total score
# RETURNS:		$v0 = the total score with the correct input accounted for



Scoring:

addi $sp, $sp, -8	# makes room on the stack
sw $s0, 4($sp)		# stores $s0 to the stack
sw $ra, 0($sp)		# stores $ra to the stack

add $s0, $a0, $s0	# adds the length of the correct word to the total score

move $v0, $s0		# assigns $v0 the total score

lw $ra, 0 ($sp)		# restores stack
lw $s0, 4($sp)
addi $sp, $sp, 8

jr $ra			# end of subroutine

