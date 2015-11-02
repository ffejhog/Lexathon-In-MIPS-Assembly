#  --------------------------------------------------------------------------------
# | FILE: UserInput.asm								  |
# | AUTHOR: Julian McNichols							  |
# | DESCRIPTION: 	Simple timer. Seems to be most effective from my research.| 
# | 			Many ways to improve. Must find way to display in seconds |
# |			efficiently.						  |
#  --------------------------------------------------------------------------------

#WARNING: COMMENT-LESS NIGHTMARE AHEAD, OPTIMIZATION IN PROCESS

.data

Output2:		.asciiz		"Game Over!"
NewLine:		.asciiz		"\n"

.text

li $t0,6000		#Timer Var

li $v0, 30
syscall

move $s0,$a0

Timer:

li $t5,450
WasteTime:
addi $t5,$t5,-1
bne $t5,$zero,WasteTime

li $v0, 30
syscall
sub $t1,$a0,$s0
sub $t2,$t0,$t1 

tlti $t2,1
j Timer

Done:

li $v0,4
la $a0,Output2
syscall

.ktext 0x80000180

li $t2,2

li $v0,4
la $a0,Output1
syscall

la $k0,Done
mtc0 $k0,$14

eret

.kdata

Output1:		.asciiz		"Time Out!"
