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
histogram_list: .word 0, 0, 0 #Three words used for each character list's histogram
				#IMPORTANT: Each word in "histogram_list" will only
				#contain AT MOST 30 bits of information. At least
				#the final two bits in each word are UNUSED. This
				#avoidd two words sharing bits for a particular
				#character count.
file_name: .asciiz "wordlist.txt" #Name of the dictionary text file
temp_chars:	.asciiz "HDULEFCAW" #test string, delete in final version plz
words: .space 1000 #max of 10 chars per word (9+null term), 100 words max
dictionary: .space 100000 #~100 KB

#Text Segment
.text

.global main
#Main
main:
	#Load file
	la $a0, file_name
	jal loadFile
	move $s0, $v0
	move $s1, $v1
	
	li $v0, 30
	syscall
	
	move $s7, $a0
	
	#Test search
	la $s2, temp_chars
	move $a0, $s1
	move $a1, $s2
	jal search
	la $s2, temp_chars
	move $a0, $s1
	move $a1, $s2
	jal search
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	li $v0, 30
	syscall
	
	sub $a0, $a0, $s7
	li $v0, 1
	syscall
	
	#Exit
	li $v0, 10
	syscall

# "loadFile" subroutine
# PARAMETERS:		$a0 = address of the name of the ".txt" file to open.
#				All words inside MUST be upper-case.
# SAVED REGISTERS:	none
# DESCRIPTION:		Loads the file's contents into data labeled "dictionary".
#			**IMPORTANT**: file WILL NOT LOAD unless it is in the
#			SAME DIRECTORY as your MARS .jar!!!!!!!
# RETURNS:		$v0 = Number of bytes read from the file, or -1 if failed
#				to open the file.
#			$v1 = Address of the label "dictionary".
loadFile:
	#Load address of space
	la $t0, dictionary
	#Open file
	move $a1, $zero
	li $v0, 13
	syscall
	#Read the entire file and store in dictionary
	move $a0, $v0
	move $a1, $t0
	li $a2, 100000
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

# "search" subroutine
# PARAMETERS: 		$a0 = address of the data labeled "dictionary"
#			$a1 = the memory address of the starting character
#				in the list of game characters. This
#				character should be the required character.
# SAVED REGISTERS:	$s0, $s1, $s2, $s3, $s4, $ra
# DESCRIPTION:		Populates data label "words" with list of at most
#			100 words containing some or all of the characters
#			that were most recently generated.
# RETURNS:		$v0 = Number of words found in the word list.
search:
	#Save registers
	addi $sp, $sp, -36
	sw $s0, 32($sp)
	sw $s1, 28($sp)
	sw $s2, 24($sp)
	sw $s3, 20($sp)
	sw $s4, 16($sp)
	sw $s5, 12($sp)
	sw $s6, 8($sp)
	sw $s7, 4($sp)
	sw $ra, ($sp)
	
	#Store arguements
	move $s0, $a0
	move $s1, $a1
	
	#Load in the word space
	la $s2, words
	#Clear our word space
	move $a0, $s2
	li $a1, 1000
	jal clearSpace
	
	#Create histogram and store its address
	move $a0, $s1
	jal histogram
	move $s4, $v0
	
	#These will be local copies of the histogram
	lw $s5, ($s4)
	lw $s6, 4($s4)
	lw $s7, 8($s4)

	#This is our word counter
	move $v0, $zero
	#End of search flag
	move $t8, $zero
	
	#Outer loop (word loop)
	searchLoop0:
		#Create temporary histogram registers
		move $t0, $s5
		move $t1, $s6
		move $t2, $s7
		
		#initialize word flag, req. char flag, req. char, and index
		li $t7, 1
		move $a0, $zero
		lb $a1, ($s1)
		move $t3, $s2
		#Inner loop (character loop)
		searchLoop1:
			#Load character
			lb $t4, ($s0)
			#Exit inner loops if we encounter line carriage or EOF
			beq $t4, 13, searchEndLoop1
			beq $t4, 0, searchEndLoop1F
			#Skip histogram stuff if the word is flagged bad
			beq $t7, $zero, searchLoop1Incr
			
			bne $a1, $t4, searchLoop0Comp
			li $a0, 1
			
			searchLoop0Comp:
			#Get Index
			subi $t5, $t4, 65
			#Branch to modify whichever word contains char $t2
			bgt $t5, 19, searchThirdWord
			bgt $t5, 9, searchSecondWord
			j searchFirstWord
			
			searchThirdWord:
			#Subtract 19 from our index [20, 26]
			subi $t5, $t5, 19
			#Multiply it by 3 by shifting once and adding itself
			move $t6, $t5
			sll $t5, $t5, 1
			add $t5, $t5, $t6
			#Subtract it from 32 to get shift amount
			li $t6, 32
			sub $t5, $t6, $t5
			#Get character count by masking
			li $t6, 7
			sllv $t6, $t6, $t5
			and $t6, $t2, $t6
			#If it's zero, the word won't work
			beq $t6, $zero, searchNoMatch 
			#If it's not zero, we need to decrement our temp histogram
			li $t6, 1
			sllv $t6, $t6, $t5
			sub $t2, $t2, $t6
			j searchLoop1Incr
			
			searchSecondWord:
			#Subtract 9 from our index [10, 19]
			subi $t5, $t5, 9
			#Multiply it by 3 by shifting once and adding itself
			move $t6, $t5
			sll $t5, $t5, 1
			add $t5, $t5, $t6
			#Subtract it from 32 to get shift amount
			li $t6, 32
			sub $t5, $t6, $t5
			#Get character count by masking
			li $t6, 7
			sllv $t6, $t6, $t5
			and $t6, $t1, $t6
			#If it's zero, the word won't work
			beq $t6, $zero, searchNoMatch 
			#If it's not zero, we need to decrement our temp histogram
			li $t6, 1
			sllv $t6, $t6, $t5
			sub $t1, $t1, $t6
			j searchLoop1Incr
			
			searchFirstWord:
			#Add 1 to our index
			addi $t5, $t5, 1
			#Multiply our index by 3 by shifting once and adding itself
			move $t6, $t5
			sll $t5, $t5, 1
			add $t5, $t5, $t6
			#Subtract it from 32 to get shift amount
			li $t6, 32
			sub $t5, $t6, $t5
			#Get character count by masking
			li $t6, 7
			sllv $t6, $t6, $t5
			and $t6, $t0, $t6
			#If it's zero, the word won't work
			beq $t6, $zero, searchNoMatch 
			#If it's not zero, we need to decrement our temp histogram
			li $t6, 1
			sllv $t6, $t6, $t5
			sub $t0, $t0, $t6
			j searchLoop1Incr
			
			#If the word contains letters not allowed by our histogram, set flag to false
			searchNoMatch:
			move $t7, $zero
			searchLoop1Incr:
			sb $t4, ($t3)
			addi $t3, $t3, 1
			addi $s0, $s0, 1
			j searchLoop1
			
		#We are done with dictionary
		searchEndLoop1F:
		li $t8, 1
		#We finished a word, pad it with zero
		searchEndLoop1:
		sb $zero, ($t3)
		
		#Make sure the word contains the required character
		and $t7, $a0, $t7
		#If the word doesn't fit our histogram, just cleanup and move on to next one
		beq $t7, $zero, searchLoop0Cleanup
		#Otherwise, override our current wordList index (meaning we don't want to
		#override the word we just processed)
		addi $t3, $t3, 1
		move $s2, $t3
		#Increment our word count
		addi $v0, $v0, 1
		
		#Cleanup data for next word
		searchLoop0Cleanup:
		#Reset our word flag
		li $t7, 1
		#Skip new-line character
		addi $s0, $s0, 2
		#We have reached end of dictiionary if $t8 = 1
		bne $t8, 1, searchLoop0
	
	#Reload registers and return
	lw $ra, ($sp)
	lw $s7, 4($sp)
	lw $s6, 8($sp)
	lw $s5, 12($sp)
	lw $s4, 16($sp)
	lw $s3, 20($sp)
	lw $s2, 24($sp)
	lw $s1, 28($sp)
	lw $s0, 32($sp)
	addi $sp, $sp, 36
	jr $ra

# "clearSpace" subroutine
# PARAMETERS:		$a0 = address of the head of the memory space
#			$a1 = size of the space to be cleared
# SAVED REGISTERS: 	none
# DESCRIPTION:		Sets the first {$a1} bytes of the space,
#			headed by address {$a0}, to 0.
# RETURNES:		void
clearSpace:
	#Create a temporary copy of $a0
	move $t0, $a0
	add $t1, $zero, $zero
	clearLoop0:
		#Exit loop when we hit length
		beq $t1, $a1, clearDone
		#Set byte and increment 
		sb $zero, ($t0)
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		j clearLoop0
	clearDone:
	jr $ra

# "histogram" subroutine
# PARAMETERS: 		$a0 = address of first character in the list
#			of characters to create a histogram with.
# SAVED REGISTERS: 	$s0, $s1, $ra
# DESCRIPTION:		Creates a histogram character count using three
#			bits per character. These counts will be stored
#			in the space allocated for the data label
#			"histogram_list".
# RETURNS:		$v0 = address of data label "histogram_list"
histogram:
	#Store registers
	addi $sp, $sp, -12
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $ra, ($sp)
	
	#Create temp copy of char list address
	move $s0, $a0
	#Load address of our histogram list
	la $s1, histogram_list
	#Clear histogram_list space
	move $a0, $s1
	li $a1, 12
	jal clearSpace
	#Loop through the 9 characters
	histLoop0:
		#Load character
		lb $t2, ($s0)
		#Break loop if character is null
		beq $t2, 0, histDone
		#Store alphabet index
		subi $t3, $t2, 65
		#Branch to modify whichever word contains char $t2
		bgt $t3, 19, histThirdWord
		bgt $t3, 9, histSecondWord
		j histFirstWord
		
		histThirdWord:
		#Load the third word
		lw $t4, 8($s1)
		#Subtract 19 from our index [20, 26]
		subi $t3, $t3, 19
		#Multiply it by 3 by shifting once and adding itself
		move $t5, $t3
		sll $t3, $t3, 1
		add $t3, $t3, $t5
		#Subtract it from 32 to get shift amount
		li $t5, 32
		sub $t3, $t5, $t3
		#Shift the number 1 to the left by shift amount
		li $t5, 1
		sllv $t3, $t5, $t3
		#Add the bits
		add $t4, $t4, $t3
		#store the word with new character count back
		sw $t4, 8($s1)
		j histLoop0BodyEnd
		
		histSecondWord:
		#Load the second word
		lw $t4, 4($s1)
		#Subtract 9 from our index [10, 19]
		subi $t3, $t3, 9
		#Multiply it by 3 by shifting once and adding itself
		move $t5, $t3
		sll $t3, $t3, 1
		add $t3, $t3, $t5
		#Subtract it from 32 to get shift amount
		li $t5, 32
		sub $t3, $t5, $t3
		#Shift the number 1 to the left by shift amount
		li $t5, 1
		sllv $t3, $t5, $t3
		#Add the bits
		add $t4, $t4, $t3
		#store the word with new character count back
		sw $t4, 4($s1)
		j histLoop0BodyEnd
		
		histFirstWord:
		
		#Load the first word
		lw $t4, ($s1)
		#Add 1 to our index
		addi $t3, $t3, 1
		#Multiply it by 3 by shifting once and adding itself
		move $t5, $t3
		sll $t3, $t3, 1
		add $t3, $t3, $t5
		#Subtract it from 32 to get shift amount
		li $t5, 32
		sub $t3, $t5, $t3
		#Shift the number 1 to the left 
		li $t5, 1
		sllv $t3, $t5, $t3
		#Add the bits
		add $t4, $t4, $t3
		#store the word with new character count back
		sw $t4, ($s1)
		
		histLoop0BodyEnd:
		#Increment to next character
		addi $s0, $s0, 1
		j histLoop0
	histDone:
	#Move label address to $v0 and return
	move $v0, $s1
	
	#Load saved registers
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $ra, ($sp)
	addi $sp, $sp, 12
	jr $ra
