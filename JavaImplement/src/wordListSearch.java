import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Scanner;

public class wordListSearch
{
    Scanner scanner;

    public wordListSearch(File input) throws FileNotFoundException {
        scanner = new Scanner(input);
    }
    public ArrayList<String> searchList(char[] input){
        ArrayList<String> outputList = new ArrayList<String>();
        while(scanner.hasNextLine()){
            String line = scanner.nextLine();
            int counter = 0;
            for(int i = 0; i < line.length(); i++){
                for(int j = 0; j<input.length;j++){
                    if(line.charAt(i) == input[j]){
                        counter++;
                        break;
                    }
                }

            }
            if(counter==line.length()){
                outputList.add(line);
            }
        }
        return  outputList;
    }



}