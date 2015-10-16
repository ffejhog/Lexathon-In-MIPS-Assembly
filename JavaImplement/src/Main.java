import java.io.File;
import java.io.IOException;
import java.util.*;

public class Main
{
	public static void main(String[] args)
	{
		letterGen gen = new letterGen();
        ArrayList<String> out = new ArrayList<String>();
		char[] letters = gen.generateChar();
        try {
            do {
                wordListSearch search = new wordListSearch(new File("D:\\ProgrammingProjects\\cs3340groupproject\\Wordlists\\Wordlist1.txt"));
                out = search.searchList(letters);
                //char[] test = {'B', 'R', 'W', 'O', 'N', 'S', 'A', 'L', 'R'};

            }while(out.size()<10);
        } catch (IOException e){
            e.printStackTrace();
        }
        for(int i = 0;i<letters.length; i++){
            System.out.println(letters[i]);
        }
        for(int i = 0;i<out.size(); i++){
            System.out.println(out.get(i));
        }
	}
	
}
