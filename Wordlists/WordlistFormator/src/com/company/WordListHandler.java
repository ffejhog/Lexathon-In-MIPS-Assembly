package com.company;

import com.sun.deploy.util.ArrayUtil;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.Arrays;
/**
 * Created by Jeff on 9/18/2015.
 */
public class WordListHandler {
    Scanner in;
    ArrayList<String> data = new ArrayList<String>();
    ArrayList<String> signatureData = new ArrayList<String>();
    public WordListHandler(Scanner fileInput){
        in = fileInput;
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

    public void generateSignatures(){



    }

    private Character[] toCharacterArray( String s ) {

        if ( s == null ) {
            return null;
        }

        int len = s.length();
        Character[] array = new Character[len];
        for (int i = 0; i < len ; i++) {
            array[i] = new Character(s.charAt(i));
        }

        return array;
    }

    public void printArrayList(){
        for(int i = 0; i <data.size(); i++){
            System.out.println(data.get(i));
        }

    }
}
