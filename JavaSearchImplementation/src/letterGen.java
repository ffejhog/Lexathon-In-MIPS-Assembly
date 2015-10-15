import java.util.*;

public class letterGen
{
	Random rand;
	public letterGen(){
	    rand = new Random();
		
	}
	public char[] generateChar(){
		char[] output = new char[9];
		for(int i = 0;i<8;i++){
		int randStore = rand.nextInt(25);
		randStore += 65;
		char letter = (char) randStore;
		output[i]=letter;
		}
		
		
		return output;
	}
}
