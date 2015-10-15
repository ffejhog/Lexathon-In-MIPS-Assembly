import java.util.*;

public class Main
{
	public static void main(String[] args)
	{
		letterGen gen = new letterGen();
		char[] letters = gen.generateChar();
        for(int i = 0;i<letters.length; i++){
            System.out.println(letters[i]);
        }
	}
	
}
