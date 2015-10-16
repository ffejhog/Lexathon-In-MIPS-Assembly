import java.io.File;
import java.io.IOException;
import java.util.*;

public class Main
{

	public static void main(String[] args)
	{
        ArrayList<String> out = new ArrayList<String>();
        char[] letters;

        do {

            letterGen gen = new letterGen();
		    letters = gen.generateChar();
            try {

                wordListSearch search = new wordListSearch(new File("D:\\ProgrammingProjects\\cs3340groupproject\\Wordlists\\WordList4.txt"));
                out = search.searchList(letters);
                //char[] test = {'B', 'R', 'W', 'O', 'N', 'S', 'A', 'L', 'R'};


            } catch (IOException e){
                e.printStackTrace();
            }
        }while(out.size()<100);
        for(int i = 0;i<letters.length; i++){
            System.out.println(letters[i]);
        }
        for(int i = 0;i<out.size(); i++){
            System.out.println(out.get(i));
        }
	}
	
}
