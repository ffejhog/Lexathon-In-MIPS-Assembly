# FILE: letterGen.asm
# AUTHOR: Jeffrey Neer
# DESCRIPTION: Contains subroutine that generates nine letters based on 3 rules. 
# 	       1. FIrst letter is completely random, and is always required
#	       2. Second letter is always a vowel
#	       3. Third-Ninth letters are randomly generated

.data
Letters: .space 9 # Will store the nine generated letters

.text
letterGen:
# Program has no required parameters, and stores all results to memory location labeled "Letters"
# Program only uses temp registers, so it is the duty of the calling function to save any required data.

