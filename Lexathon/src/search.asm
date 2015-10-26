#
# search.asm
# AUTHOR: Christian Leithner
# DESCRIPTION: Contains the "search" subroutine. This subroutine
# will search the specified dictionary for words that contains
# some or all of the characters in the provided string. This
# file is intented to be temporary, its contents should be
# merged with files containing other dictionary operations.
#

# TODO: test clearSpace and histogram subroutines. Then, fill our search.

#Data Segment
.data
words: .space 1000 #max of 10 chars per word (9+null term), 100 words max
line_buffer: .space 10 #buffer for each line of input
histogram_list: .word 0, 0, 0 #Three words used for each character list's histogram
				#IMPORTANT: Each word in "histogram_list" will only
				#contain AT MOST 30 bits of information. At least
				#the final two bits in each word are UNUSED. This
				#avoidd two words sharing bits for a particular
				#character count.

#Text Segment
.text

#Main
main:

# "search" subroutine
# PARAMETERS: 		$a0 = addres of the name of the ".txt" file to open.
#				All words inside MUST be upper case.
#			$a1 = the memory address of the starting character
#				in the list of required characters. This
#				character should be the required character.
# SAVED REGISTERS:	$s0, $s1, $s2, $s3, $ra
# DESCRIPTION:		Populates data label "words" with list of at most
#			100 words containing some or all of the characters
#			that were most recently generated.
# RETURNS:		$v0 = Number of words found in the word list.
search:
	#Save registers
	addi $sp, $sp, -24
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s2, 12($sp)
	sw $s3, 8($sp)
	sw $s4, 4($sp)
	sw $ra, ($sp)
	
	#Save arguements so we can syscall
	move $s0, $a0
	move $s1, $a1
	
	#Load word list and line buffer
	la $s2, words
	la $s3, line_buffer
	
	
	
	#Open text file
	li $v0, 13
	syscall
	#Store file descriptor
	move $s4, $v0
	
	
	
	#Close file
	li $v0, 16
	move $a0, $s4
	syscall
	
	#Reload registers and return
	lw $ra, ($sp)
	lw $s4, 4($sp)
	lw $s3, 8($sp)
	lw $s2, 12($sp)
	lw $s1, 16($sp)
	lw $s0, 20($sp)
	addi $sp, $sp, 24
	jr $ra

# "clearSpace" subroutine
# PARAMETERS:		$a0 = address of the head of the memory space
#			$a1 = size of the space to be cleared
# SAVED REGISTERS: none
# DESCRIPTION:		Sets the first {$a1} bytes of the space,
#			headed by address {$a0}, to 0.
# RETURNES:		void
clearSpace:
	#Create a temporary copy of $a0
	move $t0, $a0
	add $t1, $zero, $zero
	clearLoop0:
		#Exit loop when we hit length
		beq $t1, $a1
		#Set byte and increment 
		sb $zero, ($t0)
		addi $t0, $t0, 1
		addi $t1, $t1, 1
	clearDone:
	jr $ra

# "histogram" subroutine
# PARAMETERS: 		$a0 = address of first character in the list
#			of characters to create a histogram with.
# SAVED REGISTERS: 	none
# DESCRIPTION:		Creates a histogram character count using three
#			bits per character. These counts will be stored
#			in the space allocated for the data label
#			"histogram_list".
# RETURNS:		$v0 = address of data label "histogram_list"
histogram:
	#Create temp copy of char list address
	move $t0, $a0
	#Load address of our histogram list
	la $t1, histogram_list
	#Loop through the 9 characters
	histLoop0:
		#Load character
		lb $t2, ($t0)
		#Break loop if character is null
		beq $t2, 0, histDone
		#Store alphabet index
		subi $t3, $t2, 65
		#Branch to modify whichever word contains char $t2
		bgt $t3, 20, histThirdWord
		bgt $t3, 10, histSecondWord
		j histFirstWord
		
		histThirdWord:
		#Load the third word
		lw $t4, 2($t1)
		#Get shift ammount (32-($t3-20)-2)
		li $t5, 50
		sub $t3, $t5, $t3
		#Shift 1 to the left 
		li $t5 1
		sll $t3, $t5, $t3
		#Add the bits
		add $t4, $t4, $t3
		#store the word with new character count back
		sw $t4, 2($t1)
		j histLoop0BodyEnd
		
		histSecondWord:
		#Load the second word
		lw $t4, 1($t1)
		#Get shift ammount (32-($t3-10)-2)
		li $t5, 40
		sub $t3, $t5, $t3
		#Shift 1 to the left
		li $t5 1
		sll $t3, $t5, $t3
		#Add the bits
		add $t4, $t4, $t3
		#store the word with new character count back
		sw $t4, 1($t1)
		j histLoop0BodyEnd
		
		histFirstWord:
		
		#Load the first word
		lw $t4, ($t1)
		#Get shift ammount (32-($t3+0)-2)
		li $t5, 30
		sub $t3, $t5, $t3
		#Shift 1 to the left 
		li $t5 1
		sll $t3, $t5, $t3
		#Add the bits
		add $t4, $t4, $t3
		#store the word with new character count back
		sw $t4, ($t1)
		
		histLoop0BodyEnd:
		#Increment to next character
		addi $t0, $t0, 1
		j histLoop0:
	histDone:
	#Move label address to $v0 and return
	move $v0, $t1
	jr $ra