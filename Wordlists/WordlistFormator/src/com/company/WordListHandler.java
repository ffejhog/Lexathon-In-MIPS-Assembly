package com.company;

import com.sun.deploy.util.ArrayUtil;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.Arrays;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

/**
 * Created by Jeff on 9/18/2015.
 */
public class WordListHandler {
    Scanner in;
    ArrayList<String> data = new ArrayList<String>();
    ArrayList<String> signatureData = new ArrayList<String>();

    public WordListHandler(Scanner fileInput, int max, int min, boolean sortLength){
        in = fileInput;
        loadToArraylist();
        removeUnused(max, min);
        if(sortLength) {
            sortByLength();
        }

    }

    public void loadToArraylist(){
        while (in.hasNextLine()) {
            data.add(in.nextLine());
        }
    }

    public void removeUnused(int upperLimit, int lowerLimit){
        for(int i = 0; i <data.size(); i++){
            if(data.get(i).contains("'") || data.get(i).length()>upperLimit || data.get(i).length()<lowerLimit){
                data.remove(i);
                i--;
            }

        }
    }


    public void sortByLength(){
        data.sort(new stringLengthComparator());
    }



    public void generateWordlist(File file){
        try{
            if(!file.exists()) {
                file.createNewFile();
            }
            FileWriter fw = new FileWriter(file.getAbsoluteFile());
            BufferedWriter bw = new BufferedWriter((fw));
            for(int i = 0; i<data.size();i++){
                bw.write(data.get(i).toUpperCase() + "\n");
            }
            bw.close();
            System.out.print("File Generated");

        } catch (IOException e){
            System.out.print("File failed to generate");
            e.printStackTrace();
        }
    }
}
