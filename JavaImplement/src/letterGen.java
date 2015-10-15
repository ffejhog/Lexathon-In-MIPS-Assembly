import java.util.*;

public class letterGen
{
	Random rand;
	int randStore;
	char letter;
	public letterGen(){
	    rand = new Random();

	}
	public char[] generateChar(){
		char[] output = new char[9];
		randStore = rand.nextInt(25) + 65;
		letter = (char) randStore;
		output[0] = letter;
		randStore = rand.nextInt(5);
		switch(randStore){
			case 0: output[1]='A';break;
			case 1: output[1]='E';break;
			case 2: output[1]='I';break;
			case 3: output[1]='O';break;
			case 4: output[1]='U';break;
		}
		for(int i = 2;i<9;i++){
		randStore = rand.nextInt(25) + 65;
		letter = (char) randStore;
		output[i]=letter;
		}
		
		
		return output;
	}
}
