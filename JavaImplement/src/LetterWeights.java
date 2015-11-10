import java.util.Scanner;
import java.io.*;

class LetterWeights
{
	public static void main(String[] args) throws FileNotFoundException
	{
		Scanner s = new Scanner(new File("wordlist.txt"));
		int[] counter = new int[26];
		while(s.hasNext())
		{
			char[] s2 = s.next().toCharArray();
			for(char c : s2)
				counter[((int) c)-65]++;
		}
		
		for(int i = 0; i<26; i++)
			System.out.println((char)(i+65) + " " + counter[i]);
		s.close();
	}
}