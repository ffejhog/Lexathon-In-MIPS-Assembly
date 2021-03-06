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

.data

Hud1:			.byte						 '-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-',0
Hud2:			.asciiz						 "#									#\n"
Hud3:			.asciiz						 "#			 _______ _______ _______			#\n"
Hud4:			.byte						 '#','	','	','	','|',' ',' ',' ','G',' ',' ',' ','|',' ',' ',' ','H',' ',' ',' ','|',' ',' ',' ','I',' ',' ',' ','|','	','	','	','#','\n',0
Hud5:			.byte						 '#','	','	','	','|',' ',' ',' ','D',' ',' ',' ','|',' ',' ',' ','E',' ',' ',' ','|',' ',' ',' ','F',' ',' ',' ','|','	','	','	','#','\n',0
Hud6:			.byte						 '#','	','	','	','|',' ',' ',' ','A',' ',' ',' ','|',' ',' ',' ','B',' ',' ',' ','|',' ',' ',' ','C',' ',' ',' ','|','	','	','	','#','\n',0
Hud7:			.asciiz						 "#			|_______|_______|_______|			#\n"
Hud8: 			.asciiz						 "Tries:"
Hud9:			.asciiz						 "-------------------------------------------------------Score:"

LoadingPrompt:		.asciiz		"Loading...\n"

NewLine:		.asciiz		"\n"

Input:			.byte		0:10

Letters:		.byte		0:10
words:			.byte		0:2001		#100 10-Letter Slots. End of list is double-terminated
WordsUsed:		.byte		0:100		
DuplicateList:		.byte		0:100

.globl		main,Letters,words,DuplicateList		

#REGISTER USE:
# $s0 - Timer (in seconds)
# $s1 - Logic Bits (0-8: Input Bits, 9: Timer On, 10: Waiting For Reset, 11-31 UNUSED)
# $s2 - Start Frame (when timer was last checked)
# $s3 - User Score
# $s4 - Total Possible Words
# $s5 - Number of tries left
# $s6 - Number of cycles to allow wasted time between clock checks

.text

main:
	jal backendInit
	li $s5,450			#Initialize cycle skips
	
#-------------------------------------------------------------------------------------------------------#
#					Initialization							#				
#	This section initializes all the required elemetns for a new game.				#				
#-------------------------------------------------------------------------------------------------------#
	
	NewGame:
	
	#Let the user know the game is loading
	la $a0, LoadingPrompt
	li $v0, 4
	syscall
	
	jal backendSearch		#Fetches a new list of letters and words
	move $s4,$v0			#Save the number of words found
	jal WriteHUD
	
	li $s0,60			#Initialize Timer
	li $s1,0			#Initialize Logic bits
	li $s2,0			#Initialize Start Frame
	li $s3,0			#Initialize Score
	li $s5,3			#Initialize number of tries
	#s6 is initialized above so it only sets once

	la $k0,Input			#Initialize Input Buffer
	sb $zero,0($k0)

	#Initialization COMPLETE: Proceed to start timer and enter main execution loop
	
	li $t0,0xffff0000		#Keyboard and Display MMIO Receiver RControl Register
	lw $t1,0($t0)
	ori $t1,$t1,0x00000002		#Check Bit Position 1 (Interrupt-Enable Bit) true
	sw $t1,0($t0)
	
	ori $s1,$s1,0x00000200		#Checks true that the timer is active
	
#-------------------------------------------------------------------------------------------------------#
#					Main Program Execution						#				
#	Setup should be completed before this point. Once the interruptable bit is saved, the		#
#	program will start executing interrupts.							#				
#-------------------------------------------------------------------------------------------------------#
	
	li $v0, 30			#Fetches system time, miliseconds since Jan 1 1970
	syscall
	add $s2,$zero,$a0		#Move current system time to start time
	
	Redraw:				#Return here whenever you need to redraw screen
	jal DrawScreen

	MainLoop:			#Standard waiting and time checking while player isn't providing input
	andi $t0,$s1,0x00000200		#Transfers the timer active bit
	beq $t0,$zero,TimerOff		#Leave the timer alone if the timer is off, do not process time
	jal CheckTime
	
	TimerOff:
	
#-------------------------------------------------------------------------------------------------------#
#					Time Wasting Loop						#				#
#	Wastes a certain number of cycles on addition executions. These are desireable for their	#
#	consistent execution time.									#
#-------------------------------------------------------------------------------------------------------#
	
	move $t5,$s6
	WasteTime:
	addi $t5,$t5,-1
	bne $t5,$zero,WasteTime
	
	j MainLoop
	
#-------------------------------------------------------------------------------------------------------#
#					Scoring Logic							#			
#	The program jumps to this portion of the code in order to properly score input when entered.	#
#													#
#	NOTE: Time MUST be stopped to avoid interruption!						#	
#-------------------------------------------------------------------------------------------------------#
	
	ScoreEntry:
	
	andi $k0,$s1,0x00000010		#Transfer 5th (the required input) use bit
	beq $k0,$zero,NoMatch
	
	la $a0,Input
	la $a1,words
	jal StringCheck 		#Jumps to String Check subroutine by Daniel in "stringCheck.asm"
					# v0 is now EITHER -1 if there was no match OR equal to the 			
													
	slt $v0,$v0,$zero
	bne $v0,$zero,NoMatch
	
	li $a0,100			#Tone pitch
	
	addi $s0,$s0,4
	
	beq $s3,$s4,EndGame		#Game ends if all words are found
	
	j EndScore
	
	NoMatch:
	
	li $a0,27			#Tone pitch
	
	addi $s5,$s5,-1			#Takes a strike and checks if the game needs to end.
	
	beq $s5,$zero,EndGame
	
	EndScore:
	
	li $v0,31			#Play Midi tone function
	li $a1,500			#Milisecond Length
	li $a2,0			#Tone type
	li $a3,60			#Tone volume
	syscall
	
	andi $s1,$s1,0xFFFFFE00		#Turns off first 9 bits (ie the input bits)
	
	la $k0,Input
	sb $zero,0($k0)
	
	li $t0,0xffff0000		#Keyboard and Display MMIO Receiver RControl Register
	lw $t1,0($t0)
	ori $t1,$t1,0x00000002		#Check Bit Position 1 (Interrupt-Enable Bit) true
	sw $t1,0($t0)
	
	ori $s1,$s1,0x00000200		#Checks true that the timer is active
	
	j Redraw
	
	EndGame:
	li $s0,1			#Force the clock to timeout on next check
	li $s2,0
	j EndScore

#---------------------------------------------------------------------------------------------------------------#
#	Subroutine: CheckTime											#
#		Use: 		Checks the number of miliseconds that have passed since the program started 	#
#				and generates a trap if the timer has run out.					#
#														#
#		Inputs:		NONE										#
#		Ouptuts: 	NONE										#
#														#
#		Notes: 		Debug this to make sure the user can't prevent check by holding num key, etc.	#
#				Time can be added or taken away by changing max timer in $s0			#
#---------------------------------------------------------------------------------------------------------------#

CheckTime:
	li $v0, 30			#Fetches system time, miliseconds since Jan 1 1970
	syscall
	sub $t0,$a0,$s2
	
	slti $t1,$t0,1000
	bne $t1,$zero,NoFullSecond
	subi $s0,$s0,1
	
	subi $t0,$t0,1000		#Make sure any few miliseconds over a second are retained on point of comparison
	sub $s2,$a0,$t0
	
	addi $sp,$sp,-4			#Draw the appropriate timer
	sw $ra,0($sp)
	jal DrawScreen
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	tlti $s0,1			#Generate a trap if the timer has run out
	
	addi $s6,$s6,-10		#Wait for 10 fewer cycles next time, this ensures that the computer will find steady
					#	execution equilibrium.
	
	jr $ra				#Return to program after incrementing time
	
	NoFullSecond:
	
	addi $s6,$s6,10			#Wait for 10 more cycles next time
	jr $ra
	
#---------------------------------------------------------------------------------------------------------------#
#	Subroutine: DrawMeter											#
#		Use: 		Draws a five digit meter with leading zeroes. Used for both time and score.	#
#														#
#		Inputs:		$a0 : the number to draw, $a1 : number of drawn digits (max 5)			#
#		Ouptuts: 	NONE										#
#														#
#		NOTE: This could be fused with DrawTimer to make a more generic subroutine.			#
#---------------------------------------------------------------------------------------------------------------#

DrawMeter:
	move $t0,$a0
	li $v0,11
	li $a0,48		#Character '0'
	
	beq $a1,4,FormatFourDigit
	beq $a1,3,FormatThreeDigit
	beq $a1,2,FormatTwoDigit
	beq $a1,1,FormatOneDigit

	slti $t1,$t0,10000
	bne $t1,$zero,MeterNotFiveDigit
	li $v0,1
	move $a0,$t0
	syscall
	j MeterPrintDone
	
	MeterNotFiveDigit:
	syscall
	
	FormatFourDigit:
	
	slti $t1,$t0,1000
	bne $t1,$zero,MeterNotFourDigit
	li $v0,1
	move $a0,$t0
	syscall
	j MeterPrintDone
	
	MeterNotFourDigit:
	syscall
	
	FormatThreeDigit:
	
	slti $t1,$t0,100
	bne $t1,$zero,MeterNotThreeDigit
	li $v0,1
	move $a0,$t0
	syscall
	j MeterPrintDone
	
	MeterNotThreeDigit:
	syscall
	
	FormatTwoDigit:
	
	slti $t1,$t0,10
	bne $t1,$zero,MeterNotTwoDigit
	li $v0,1
	move $a0,$t0
	syscall
	j MeterPrintDone
	
	MeterNotTwoDigit:
	syscall
	
	FormatOneDigit:
	li $v0,1
	move $a0,$t0
	syscall
	
	MeterPrintDone:
	
	jr $ra


#---------------------------------------------------------------------------------------------------------------#
#	Subroutine: DrawScreen											#
#		Use: 		Redraws screen with stored string values in data section.			#
#														#
#		Inputs:		NONE										#
#		Ouptuts: 	NONE										#
#														#
#---------------------------------------------------------------------------------------------------------------#

DrawScreen:
	addi $sp,$sp,-4			#Draw the appropriate timer
	sw $ra,0($sp)
	
	li $v0,4
	la $a0,NewLine
	syscall
	syscall
	
	la $a0,Hud1
	syscall
	
	move $a0,$s0
	li $a1,5
	jal DrawMeter
	
	li $v0,4
	la $a0,Hud1
	syscall
	
	la $a0,NewLine
	syscall
	
	la $a0,Hud2
	syscall

	la $a0,Hud3
	syscall	
			
	la $a0,Hud4
	syscall			

	la $a0,Hud7
	syscall
	
	la $a0,Hud5
	syscall					

	la $a0,Hud7
	syscall

	la $a0,Hud6
	syscall

	la $a0,Hud7
	syscall

	la $a0,Hud8
	syscall
	
	move $a0,$s5
	li $a1,1
	jal DrawMeter
	
	li $v0,4
	la $a0,Hud9
	syscall
	
	move $a0,$s3
	li $a1,2
	jal DrawMeter
	
	li $v0,11
	li $a0,47
	syscall
	
	move $a0,$s4
	li $a1,2
	jal DrawMeter
	
	li $v0,4
	la $a0,NewLine
	syscall
	
	la $a0,Input
	syscall
	
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	
#---------------------------------------------------------------------------------------------------------------#
#	Subroutine: WriteHUD											#
#		Use: 		Populates the hud elements with the letters in use.				#
#														#
#		Inputs:		NONE										#
#		Ouptuts: 	NONE										#
#														#
#---------------------------------------------------------------------------------------------------------------#

WriteHUD:

	la $t0,Letters			#Write Letters to display HUD elements
	la $t1,Hud6
	lb $t2,0($t0)
	sb $t2,8($t1)
	lb $t2,1($t0)
	sb $t2,16($t1)
	lb $t2,2($t0)
	sb $t2,24($t1)
	lb $t2,3($t0)
	la $t1,Hud5
	sb $t2,8($t1)
	lb $t2,4($t0)
	sb $t2,16($t1)
	lb $t2,5($t0)
	sb $t2,24($t1)
	lb $t2,6($t0)
	la $t1,Hud4
	sb $t2,8($t1)
	lb $t2,7($t0)
	sb $t2,16($t1)
	lb $t2,8($t0)
	sb $t2,24($t1)
	
	jr $ra


Exit:


#-------------------------------------------------------------------------------------------------------#
#					Exception Section						#				
#													#
#		Program jumps to these instructions upon interruption or trap				#
#													#				
#-------------------------------------------------------------------------------------------------------#

.kdata

Output1:		.asciiz		"				GAME OVER\n"
Output2:		.asciiz		"			Hit the zero key to play again!\n"

.ktext 0x80000180

	#---------------------------------------#
	#	Keyboard Input Handler		#
	#---------------------------------------#

	mfc0 $k0,$13			#Retrieve Cause
	andi $k0,$k0,0x0000017C		#Transfer 1s on bits 2-6 and 8
	li $k1,0x00000100		#Check for 1 at bit 8 and zeroes in bits 2-6
	bne $k0,$k1,NotKeyboard
	
	li $k1,0xffff0004		#Address of Receiver Data
	lb $a0,0($k1)
	
	slti $k0,$a0,58			# Check that input is in range of numbers 0 to 9
	beq $k0,$zero,UnusedKey
	li $k0,47
	slt $k0,$k0,$a0
	beq $k0,$zero,UnusedKey
	
	subi $a0,$a0,49			#Now we have reduced it to iterate across the loaded letters, and we have -1 if the entry was 0
	slt $k1,$a0,$zero
	bne $k1,$zero,EnterEvent
	
	andi $k0,$s1,0x00000200		#Transfers the timer active bit
	beq $k0,$zero,UnusedKey		#Don't care about non-enter input if timer is off
	
	li $k1,1			#Check that the input key is not in use
	sllv $k1,$k1,$a0
	and $k1,$k1,$s1
	
	bne $k1,$zero,LetterInUse
	
	li $k1,1			#Now flag that digit as being in use
	sllv $k1,$k1,$a0
	or $s1,$k1,$s1
	
	la $k0, Letters			#Add the indicated letter to the input string
	add $k0,$k0,$a0
	lb $a0,0($k0)
	
	la $k0,Input			#Finds the end of the string. 
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
	
	#-----------------------------------------------#
	#	Input Letter Already Being Used		#
	#-----------------------------------------------#
LetterInUse:
	eret
	
	#-------------------------------#
	#	User Hit Enter Key	#
	#-------------------------------#
EnterEvent:
	andi $s1,$s1,0xFFFFFDFF		#Switch timer bit off, stopping the timer
	
	li $k0,0xFFFF0000		#Keyboard and Display MMIO Receiver RControl Register
	lw $k1,0($k0)
	andi $k1,$k1,0xFFFFFFFD		#Check Bit Position 1 (Interrupt-Enable Bit) FALSE (Disables interrupts)
	sw $k1,0($k0)
	
	andi $k0,$s1,0x00000400		#Transfers the waiting for reset bit
	bne $k0,$zero,RestartGame	#An enter while waiting for restart starts a new game
	
	la $k0,ScoreEntry		#Jump to section of the code that handles checking the string and input
	mtc0 $k0,$14
	eret
	
	RestartGame:
	li $k0,0xFFFF0000		#Keyboard and Display MMIO Receiver RControl Register
	lw $k1,0($k0)
	andi $k1,$k1,0xFFFFFFFD		#Check Bit Position 1 (Interrupt-Enable Bit) FALSE (Disables interrupts)
	sw $k1,0($k0)
	
	li $v0,31			#Play Midi tone function
	li $a0,85			#Tone pitch
	li $a1,500			#Milisecond Length
	li $a2,0			#Tone type
	li $a3,60			#Tone volume
	syscall
	
	la $k0,NewGame		#Jump to section of the code that handles checking the string and input
	mtc0 $k0,$14
	eret
	
	#-------------------------------#
	#	Non-Implemented Key	#
	#-------------------------------#
UnusedKey:
	eret


NotKeyboard:	#Continue To Other Handlers

	#-------------------------------#
	#	Timer End Detected	#
	#-------------------------------#
	li $k1,0x00000034		#This is the bit pattern for the timer trap
	bne $k0,$k1,NotTimer
	
	li $v0,4			#Printing timeout announcement.
	la $a0,NewLine
	syscall
	
	la $a0,Output1			#Timeout text and instructions
	syscall
	
		#---------------------------------------#
		#	Print Word List on Timeout	#
		#---------------------------------------#
	
		la $k0,words
		addi $k1,$k0,70
		li $v0,11
	
		WordLoop1:			#Basic chech pulls character byte and prints it unless it is null
		lb $a0,0($k0)
		beq $a0,$zero,WordLoopNull
		syscall
		addi $k0,$k0,1
		j WordLoop1
	
		WordLoopNull:			#Jump here upon detecting the first null character
		lb $a0,1($k0)
		beq $a0,$zero,EndWordLoop	#A second null terminator means the list is done
		slt $a0,$k0,$k1
		beq $a0,$zero,WordLoopEndline	#If the line is full, then we need to return, but otherwise begin a new word
		addi $k0,$k0,1
		li $a0,44
		syscall
		j WordLoop1
	
		WordLoopEndline:		#Adds a newline to the list and increments k1 and k0
		li $a0,44
		syscall
		lb $a0,NewLine
		syscall
		addi $k1,$k1,70
		addi $k0,$k0,1
		j WordLoop1
	
		EndWordLoop:
	
	li $v0,4
	la $a0,NewLine
	syscall
	syscall
	la $a0,Output2
	syscall
	
	andi $s1,$s1,0xFFFFFDFF		#Switch timer bit off, stopping the timer
	ori $s1,$s1,0x00000400		#11th bit Indicates that we are waiting for reset
	
	la $k0,MainLoop			#Program will not process time or update screen till a new game is started
	mtc0 $k0,$14
	
	eret

		
	
NotTimer:

	la $k0,Exit
	mtc0 $k0,$14

	eret
