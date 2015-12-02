-------------------------------------------------------------------------------------------------
|					Lexathon In Mips					|
|												|
|	Programmers: 	Daniel Lecheler								|
|			Christian Leithner							|
|			Julian McNichols							|
|			Jeffrey Neer								|
|												|
|	Files:		Lexathon/Backend.asm							|
|			Lexathon/Scoring.asm							|
|			Lexathon/StringCheck.asm						|
|			Lexathon/UserInput.asm							|
|			Wordlists/Wordlist.txt							|
|			Wordlists/dictionary_9_letter_words.txt					|
-------------------------------------------------------------------------------------------------

FEATURES:
	This MIPS Assembly immplementation of Lexathon possesses all of the following features:
		50000+ total possible words 
		A grid based input that uses the numberpad for input
		A fulling working timer that updates every second on the main game space
		A scoring system that assigns a score based on the length of the word that is correctly guessed
		A MIDI based sound system that outputs a tone for each correct or incorrect word guess
		A main loop that allows to game to be replayed without the need for its re-assembly


KNOWN ISSUES:
		-	The MARS simulator has a tendancy to slow down program execution time dramatiacally after a program has been assembled a few times.
			If the game is taking a long time to load, close MARS fully and reopen the program, this should correct the issue.
		-	On rare occassions there may be words which are immpossible to get with the letters provided that show up in the list of all possible
			words after a round is complete

INSTRUCTIONS:
		1) Copy the files Wordlist.txt and dictionary_9_letter_words.txt to the same directory that your MARS.jar file is located(Program will not work otherwise)
		2) In MARS, open the file titled UserInput.asm
		3) In the menu bar tab labeled, "Settings" be sure to check, "Assemble all files in directory" and, "Initilize Program Counter to Global Main (if defined)"
		4) In the menu bar tab labeled, "Tools" open the "Keyboard and Display MMIO Simulator"
		5) In the open simulator, click "Connect to MIPS" in the lower left corner"
		6) Assemble and run the program
		7) To input your letter choices, select the bottom textbox in the "Keyboard and Display MMIO Simulator" then press the number on your numpad that coresponds
		   to the box on the displayed grid containing the letter you wish to input next(For more information see the section titled MMIO Simulator below)
		8) To submit your word(After you have inputed each letter) enter the number 0.

		
MMIO SIMULATOR:
		By inputing a specific number into the bottom textbox of the MMIO Simulator, you add the numbers corresponding letter to your current word. 
		The diagram for which numbers correspond to each box on the grid is shown below(This will correspond to your keyboards numberpad, but if you do not have
		a numberpad, you can use this guide below to see which numbers to input)
		
		 _______ _______ _______
		|	|	|	|
		|   7   |   8   |   9   |
		|_______|_______|_______|
		|	|	|	|
		|   4   |   5   |   6   |
		|_______|_______|_______|
		|	|	|	|
		|   1   |   2   |   3   |
		|_______|_______|_______|
