package com.company;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        try {
            Scanner in = new Scanner(new File("D:\\SchoolOneDrive\\OneDrive - The University of Texas at Dallas\\Year2Semester1\\CS 3340\\GroupProjectCS3340\\Wordlists\\WordlistFormator\\out\\production\\WordlistFormator\\com\\company\\Wordlist1.txt"));
            WordListHandler wordListHandler = new WordListHandler(in);
            wordListHandler.loadToArraylist();
            wordListHandler.removeUnused(9, 4);
            wordListHandler.generateSignatures();
            wordListHandler.printArrayList();
            wordListHandler.generateWordlist(new File("D:\\SchoolOneDrive\\OneDrive - The University of Texas at Dallas\\Year2Semester1\\CS 3340\\GroupProjectCS3340\\Wordlists\\WordlistFormator\\out\\production\\WordlistFormator\\com\\company\\Wordlist1output.txt"));
        } catch (FileNotFoundException e){
            e.printStackTrace();
        }

    }
}
