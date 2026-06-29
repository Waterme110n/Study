package com.example.lab2;

import android.content.Context;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class spinners {
    public static void initializeDay(Context context, Spinner spinner) {
        List<Integer> numbersList = new ArrayList<>();
        for (int i = 1; i <= 31; i++) {
            numbersList.add(i);
        }

        ArrayAdapter<Integer> adapter = new ArrayAdapter<>(context, android.R.layout.simple_spinner_item, numbersList);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
    }
    public static void initializeMonth(Context context, Spinner spinner) {
        List<Integer> numbersList = new ArrayList<>();
        for (int i = 1; i <= 12; i++) {
            numbersList.add(i);
        }

        ArrayAdapter<Integer> adapter = new ArrayAdapter<>(context, android.R.layout.simple_spinner_item, numbersList);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
    }
    public static void initializeYear(Context context, Spinner spinner) {
        List<String> numbersList = new ArrayList<>();
        for (int i = 1980; i <= 2024; i++) {
            numbersList.add(String.valueOf(i));
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(context, android.R.layout.simple_spinner_item, numbersList);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
    }
    public static void initializeMinutes(Context context, Spinner spinner) {
        List<String> numbersList = new ArrayList<>();
        for (int i = 0; i <= 59; i++) {
            numbersList.add(String.valueOf(i));
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(context, android.R.layout.simple_spinner_item, numbersList);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
    }
    public static void initializeHours(Context context, Spinner spinner) {
        List<String> numbersList = new ArrayList<>();
        for (int i = 0; i <= 23; i++) {
            numbersList.add(String.valueOf(i));
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(context, android.R.layout.simple_spinner_item, numbersList);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
    }
    public static String getZodiacSign(int day, int month) {
        String zodiacSign = "";

        if ((month == 1 && day >= 21) || (month == 2 && day <= 16)) {
            zodiacSign = "Козерог";
        } else if ((month == 2 && day >= 17) || (month == 3 && day <= 11)) {
            zodiacSign = "Водолей";
        } else if ((month == 3 && day >= 12) || (month == 4 && day <= 18)) {
            zodiacSign = "Рыбы";
        } else if ((month == 4 && day >= 19) || (month == 5 && day <= 13)) {
            zodiacSign = "Овен";
        } else if ((month == 5 && day >= 14) || (month == 6 && day <= 21)) {
            zodiacSign = "Телец";
        } else if ((month == 6 && day >= 22) || (month == 7 && day <= 20)) {
            zodiacSign = "Близнецы";
        } else if ((month == 7 && day >= 21) || (month == 8 && day <= 10)) {
            zodiacSign = "Рак";
        } else if ((month == 8 && day >= 11) || (month == 9 && day <= 16)) {
            zodiacSign = "Лев";
        } else if ((month == 9 && day >= 17) || (month == 10 && day <= 30)) {
            zodiacSign = "Дева";
        } else if ((month == 10 && day >= 31) || (month == 11 && day <= 23)) {
            zodiacSign = "Весы";
        } else if ((month == 11 && day >= 24 && day <= 29)) {
            zodiacSign = "Скорпион";
        } else if ((month == 11 && day >= 30) || (month == 12 && day <= 17)) {
            zodiacSign = "Змееносец";
        } else if ((month == 12 && day >= 18) || (month == 1 && day <= 20)) {
            zodiacSign = "Стрелец";
        }


        return zodiacSign;
    }
    public static String getZodiacSign2(int day, int month) {
        String zodiacSign = "";

        if ((month == 12 && day >= 23) || (month == 1 && day <= 20)) {
            zodiacSign = "Козерог";
        } else if ((month == 1 && day >= 21) || (month == 2 && day <= 19)) {
            zodiacSign = "Водолей";
        } else if ((month == 2 && day >= 20) || (month == 3 && day <= 20)) {
            zodiacSign = "Рыбы";
        } else if ((month == 3 && day >= 21) || (month == 4 && day <= 20)) {
            zodiacSign = "Овен";
        } else if ((month == 4 && day >= 21) || (month == 5 && day <= 21)) {
            zodiacSign = "Телец";
        } else if ((month == 5 && day >= 22) || (month == 6 && day <= 21)) {
            zodiacSign = "Близнецы";
        } else if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) {
            zodiacSign = "Рак";
        } else if ((month == 7 && day >= 23) || (month == 8 && day <= 21)) {
            zodiacSign = "Лев";
        } else if ((month == 8 && day >= 22) || (month == 9 && day <= 23)) {
            zodiacSign = "Дева";
        } else if ((month == 9 && day >= 24) || (month == 10 && day <= 23)) {
            zodiacSign = "Весы";
        } else if ((month == 10 && day >= 24) || (month == 11 && day <= 22)) {
            zodiacSign = "Скорпион";
        } else if ((month == 11 && day >= 23) || (month == 12 && day <= 22)) {
            zodiacSign = "Стрелец";
        }


        return zodiacSign;
    }
}
