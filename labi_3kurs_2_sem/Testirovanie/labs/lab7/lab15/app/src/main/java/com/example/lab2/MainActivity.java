package com.example.lab2;

import android.os.Bundle;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Button;
import android.view.View;

public class MainActivity extends AppCompatActivity {
    private Spinner spinner;
    private Spinner spinner2;
    private Spinner spinner3;
    private CheckBox checkBox1;
    private CheckBox checkBox2;
    private EditText editText;
    private RadioGroup radioGroup;
    private TextView textView9;
    private Button button;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);

        spinner = findViewById(R.id.spinner2);
        spinners.initializeDay(this, spinner);

        spinner2 = findViewById(R.id.spinner3);
        spinners.initializeMonth(this, spinner2);

        spinner3 = findViewById(R.id.spinner1);
        spinners.initializeYear(this, spinner3);

        checkBox1 = findViewById(R.id.checkbox1);
        checkBox2 = findViewById(R.id.checkbox2);

        button = findViewById(R.id.button1);
        textView9 = findViewById(R.id.textView9);
        editText = findViewById(R.id.editTextText);
        radioGroup = findViewById(R.id.radioGroup);
        RadioButton radioButton1 = findViewById(R.id.radio1);


        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                int selectedMonth = Integer.parseInt(spinner2.getSelectedItem().toString());
                int selectedDay = Integer.parseInt(spinner.getSelectedItem().toString());
                int selectedYear = Integer.parseInt(spinner3.getSelectedItem().toString());


                String zodiacSign1 = "";
                String zodiacSign2 = "";


                String name = editText.getText() != null ? editText.getText().toString().trim() : "";
                if (name.isEmpty()) {
                    textView9.setText("Введите имя");
                    return;
                }



                int selectedId = radioGroup.getCheckedRadioButtonId();

                String resultText = "";

                if (checkBox1.isChecked()) {
                    zodiacSign1 = spinners.getZodiacSign(selectedDay, selectedMonth);
                    resultText += zodiacSign1;
                }

                if (checkBox2.isChecked()) {
                    zodiacSign2 = spinners.getZodiacSign2(selectedDay, selectedMonth);
                    resultText += zodiacSign2;
                }

                textView9.setText(resultText);

            }
        });

    }
    public Spinner getSpinner() {
        return spinner;
    }

    public void setSpinner(Spinner spinner) {
        this.spinner = spinner;
    }

    public Spinner getSpinner2() {
        return spinner2;
    }

    public void setSpinner2(Spinner spinner) {
        this.spinner2 = spinner;
    }

    public Spinner getSpinner3() {
        return spinner3;
    }

    public void setSpinner3(Spinner spinner) {
        this.spinner3 = spinner;
    }

    public CheckBox getCheckBox1() {
        return checkBox1;
    }

    public void setCheckBox1(CheckBox checkBox) {
        this.checkBox1 = checkBox;
    }

    public CheckBox getCheckBox2() {
        return checkBox2;
    }

    public void setCheckBox2(CheckBox checkBox) {
        this.checkBox2 = checkBox;
    }

    public EditText getEditText() {
        return editText;
    }

    public void setEditText(EditText editText) {
        this.editText = editText;
    }

    public RadioGroup getRadioGroup() {
        return radioGroup;
    }

    public void setRadioGroup(RadioGroup radio) {
        this.radioGroup = radio;
    }

    public TextView getTextView() {
        return textView9;
    }

    public void setTextView(TextView text) {
        this.textView9 = text;
    }

    public TextView getButton() {
        return button;
    }

    public void setButton(Button button) {
        this.button = button;
    }
}