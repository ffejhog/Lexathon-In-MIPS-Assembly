import java.io.File;
import java.io.IOError;
import java.io.IOException;
import java.util.*;

public class Main
{
	public static void main(String[] args)
	{
		letterGen gen = new letterGen();
		char[] letters = gen.generateChar();
        try {
            wordListSearch search = new wordListSearch(new File("somelocation.txt"));
        } catch (IOException e){
            e.printStackTrace();
        }
        for(int i = 0;i<letters.length; i++){
            System.out.println(letters[i]);
        }
	}
	
}
