#  -------------------------------------------------------------------------------------------------
#   FILE: 9lettergenalt.asm								  							  
#   AUTHOR: Jeffrey Neer							 							  
#   DESCRIPTION: Contains subroutine that generates nine letters based on prexisting 9 letter words						  
#  -------------------------------------------------------------------------------------------------

.data
Letters: .space 10 # Will store the nine generated letters(Plus one null terminator)
file_name: .asciiz "wordlist.txt" #Name of the dictionary text file
nine_letter_words: .space 100000 #~100 KB

#Main
main:
	#Load file
	la $a0, file_name
	jal loadFile
	move $s0, $v0
	move $s1, $v1
