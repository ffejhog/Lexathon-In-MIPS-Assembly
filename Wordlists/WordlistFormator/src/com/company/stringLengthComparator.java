package com.company;

import java.util.Comparator;

/**
 * Created by Jeff on 9/23/2015.
 */
public class stringLengthComparator implements Comparator<String>{

    public int compare(String s1, String s2){

            if (s1.length()!=s2.length()) {
                return s1.length()-s2.length(); //overflow impossible since lengths are non-negative
            }

            return s1.compareTo(s2);

    }


}
