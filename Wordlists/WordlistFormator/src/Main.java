package com.company;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        try {
            Scanner in = new Scanner(new File("Wordlist1.txt"));
            WordListHandler wordListHandler = new WordListHandler(in, 9, 4, false); //(Scanner, Max Length, Min Length, Sort by length)
            wordListHandler.generateWordlist(new File("Wordlist1output.txt"));
        } catch (FileNotFoundException e){
            e.printStackTrace();
        }

    }
}
