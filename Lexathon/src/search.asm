#
# search.asm
# AUTHOR: Christian Leithner
# DESCRIPTION: Contains the "search" subroutine. This subroutine
# will search the specified dictionary for words that contains
# some or all of the characters in the provided string. This
# file is intented to be temporary, its contents should be
# merged with files containing other dictionary operations.
#

#Data Segment
.data

#Text Segment
.text

#Main
main:

# "search" subroutine
# PARAMETERS: 		$a0 = name of the ".txt" file to open
#			$a1 = the memory address of the starting character
#				in the list of required characters.
# SAVED REGISTERS:	$ra
search: