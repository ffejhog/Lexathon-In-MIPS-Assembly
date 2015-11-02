#  --------------------------------------------------------------------------------
# | FILE: UserInput.asm								  |
# | AUTHOR: Julian McNichols							  |
# | DESCRIPTION: The basic shell for the game, provides a user interface for the  |
# |	       		player to interact with. Shows a grid of letters for use  |
# |			by entering number keys on the keypad. 			  |
# |			1) Enter desired grid letter with NumPad		  |
# |			2) Enter zero for an "Enter Command" Currently only resets|
# |										  |
# |			Setup: 	Open Tools<Keyboard and Display MMIO Simulator    |
# |				Click "Connect to MIPS" button			  |
# |				Input numbers into the bottom field		  |
# |				Non-number inputs ignored			  |
#  --------------------------------------------------------------------------------

#WARNING: COMMENT-LESS NIGHTMARE AHEAD, OPTIMIZATION IN PROCESS

.data

Hud1:		.byte						 '-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','0','0','0','0','0','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-',0
Hud2:		.asciiz						 "#									#"
Hud3:		.asciiz						 "#			 _______ _______ _______			#"
Hud4:		.byte						 '#','	','	','	','|',' ',' ',' ','G',' ',' ',' ','|',' ',' ',' ','H',' ',' ',' ','|',' ',' ',' ','I',' ',' ',' ','|','	','	','	','#',0
Hud5:		.byte						 '#','	','	','	','|',' ',' ',' ','D',' ',' ',' ','|',' ',' ',' ','E',' ',' ',' ','|',' ',' ',' ','F',' ',' ',' ','|','	','	','	','#',0
Hud6:		.byte						 '#','	','	','	','|',' ',' ',' ','A',' ',' ',' ','|',' ',' ',' ','B',' ',' ',' ','|',' ',' ',' ','C',' ',' ',' ','|','	','	','	','#',0
Hud7:		.asciiz						 "#			|_______|_______|_______|			#"
Hud8: 		.asciiz						 "-------------------------------------------------------------------------"

NewLine:		.asciiz		"\n"

Input:			.byte		0:10
LettersUse:		.word		0			#Bits 0 to 8 are true if letter is in use

Letters:		.byte		'A','B','C','D','E','F','G','H','I'				

#REGISTER USE:
# $s0 - Timer
# $s1 - Input

.text

	li $t0,0xffff0000		#Keyboard and Display MMIO Receiver RControl Register
	li $s0,0x00000000		#First 9 bits used for key use.
	li $s1,0x00000000		#Used for timer value (in seconds)

	lw $t1,0($t0)
	ori $t1,$t1,0x00000002		#Check Bit Position 1 (Interrupt-Enable Bit) true
	sw $t1,0($t0)
	
	Redraw:
	jal DrawScreen

	MainLoop:
	
	j MainLoop


DrawScreen:
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Hud1
	syscall
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Hud2
	syscall
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Hud3
	syscall	
			
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Hud4
	syscall			
					
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Hud7
	syscall
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Hud5
	syscall					
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Hud7
	syscall
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Hud6
	syscall
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Hud7
	syscall
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Hud8
	syscall
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	li $v0,4
	la $a0,Input
	syscall
	
	jr $ra
	
	


Exit:


.ktext 0x80000180

	mfc0 $k0,$13			#Retrieve Cause
	andi $k0,$k0,0x0000017C		#Transfer 1s on bits 2-6 and 8
	li $k1,0x00000100		#Check for 1 at bit 8 and zeroes in bits 2-6
	bne $k0,$k1,NotKeyboard
	li $k1,0xffff0004		#Address of Receiver Data
	lb $a0,0($k1)
	
	
	slti $k0,$a0,58
	beq $k0,$zero,UnusedKey
	li $k0,47
	slt $k0,$k0,$a0
	beq $k0,$zero,UnusedKey
	
	subi $a0,$a0,49			#Now we have reduced it to iterate across the loaded letters, and we have -1 if the entry was 0
	slt $k1,$a0,$zero
	bne $k1,$zero,EnterEvent
	
	li $k1,1
	sllv $k1,$k1,$a0
	la $k0,LettersUse
	lw $k0,0($k0)
	and $k1,$k1,$k0
	
	bne $k1,$zero,LetterInUse
	
	li $k1,1
	sllv $k1,$k1,$a0
	
	or $k1,$k1,$k0
	la $k0,LettersUse
	sw $k1,0($k0)
	
	la $k0, Letters
	add $k0,$k0,$a0
	lb $a0,0($k0)
	
	la $k0,Input
	FindInput:
	lb $k1,0($k0)
	addi $k0,$k0,1
	bne $k1,$zero,FindInput
	sb $zero,0($k0)
	addi $k0,$k0,-1
	
	sb $a0,0($k0)
	
	la $k0,Redraw
	mtc0 $k0,$14
	
	eret
	
LetterInUse:
	eret
	
EnterEvent:
	
	la $k0,LettersUse
	sw $zero,0($k0)
	
	la $k0,Input
	sb $zero,0($k0)
	
	la $k0,Redraw
	mtc0 $k0,$14

UnusedKey:
	eret

NotKeyboard:


li $v0,4
la $a0,Output1
syscall

la $k0,Exit
mtc0 $k0,$14

eret





.kdata

Output1:		.asciiz		"Time Out!"
