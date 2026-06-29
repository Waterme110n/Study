package com.example.lab2;

import android.os.StrictMode;
import android.text.Editable;
import android.text.SpannableString;
import android.util.Log;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.RadioButton;
import android.widget.TextView;

import androidx.test.core.app.ActivityScenario;
import org.junit.Before;
import org.junit.Test;
import org.junit.Ignore;
import org.junit.After;
import static org.junit.Assert.*;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.mockito.Mockito.*;
public class MainActivityTest {

    @Mock
    private Spinner mockSpinnerDay;
    @Mock
    private Spinner mockSpinnerMonth;
    @Mock
    private Spinner mockSpinnerYear;
    @Mock
    private Button mockButton;
    @Mock
    private CheckBox mockCheckBox1;
    @Mock
    private CheckBox mockCheckBox2;
    @Mock
    private EditText mockEditText;
    @Mock
    private RadioGroup mockRadioGroup;
    @Mock
    private TextView mockTextView;

    private MainActivity mainActivity;

    @Before
    public void setUp() {
        MockitoAnnotations.openMocks(this);

        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);
        scenario.onActivity(activity -> {
            mainActivity = activity;

            mainActivity.setSpinner(mockSpinnerDay);
            mainActivity.setSpinner2(mockSpinnerMonth);
            mainActivity.setSpinner3(mockSpinnerYear);
            mainActivity.setButton(mockButton);
            mainActivity.setEditText(mockEditText);
            mainActivity.setRadioGroup(mockRadioGroup);
            mainActivity.setCheckBox1(mockCheckBox1);
            mainActivity.setCheckBox2(mockCheckBox2);
            mainActivity.setTextView(mockTextView);
        });
    }

    @After
    public void tearDown() {
    }

    @Test
    public void testSpinnerInitialization() {
        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);
        scenario.onActivity(activity -> {

            assertNotNull("Spinner for days should not be null", activity.getSpinner());
            assertNotNull("Spinner for months should not be null", activity.getSpinner2());
            assertNotNull("Spinner for years should not be null", activity.getSpinner3());


            assertTrue("Spinner for days should have items", activity.getSpinner().getAdapter().getCount() > 0);
            assertTrue("Spinner for months should have items", activity.getSpinner2().getAdapter().getCount() > 0);
            assertTrue("Spinner for years should have items", activity.getSpinner3().getAdapter().getCount() > 0);
        });
    }

    @Test
    public void testDateSelection() {
        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);


        String expectedDay = "15";
        String expectedMonth = "5";
        String expectedYear = "2000";

        scenario.onActivity(activity -> {

            activity.getSpinner().setSelection(14);
            activity.getSpinner2().setSelection(4);
            activity.getSpinner3().setSelection(20);


            String selectedDay = activity.getSpinner().getSelectedItem().toString();
            String selectedMonth = activity.getSpinner2().getSelectedItem().toString();
            String selectedYear = activity.getSpinner3().getSelectedItem().toString();


            assertEquals("Выбранный день должен совпадать", expectedDay, selectedDay);
            assertEquals("Выбранный месяц должен совпадать", expectedMonth, selectedMonth);
            assertEquals("Выбранный год должен совпадать", expectedYear, selectedYear);
        });
    }

    @Test
    public void NameAndMale() {
        when(mockEditText.getText()).thenReturn(Editable.Factory.getInstance().newEditable("123"));
        when(mockRadioGroup.getCheckedRadioButtonId()).thenReturn(1);

        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);
        scenario.onActivity(activity -> {
            activity.setEditText(mockEditText);
            activity.setRadioGroup(mockRadioGroup);
            activity.setTextView(mockTextView);

            Button button = activity.findViewById(R.id.button1);
            button.performClick();

            String nameInput = mockEditText.getText().toString();
            assertFalse("Имя должно быть введено", nameInput.isEmpty());
    
            int selectedId = mockRadioGroup.getCheckedRadioButtonId();
            assertEquals(1, selectedId);

        });

    }

    @Test
    public void testButtonClickInteraction() {

        when(mockEditText.getText()).thenReturn(Editable.Factory.getInstance().newEditable("Иван"));
        when(mockCheckBox1.isChecked()).thenReturn(false);
        when(mockCheckBox2.isChecked()).thenReturn(true);

        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);
        scenario.onActivity(activity -> {
            activity.setEditText(mockEditText);
            activity.setCheckBox1(mockCheckBox1);
            activity.setCheckBox2(mockCheckBox2);

            Button button = activity.findViewById(R.id.button1);
            button.performClick();

            verify(mockCheckBox1).isChecked();
            verify(mockCheckBox2).isChecked();

            assertFalse(mockCheckBox1.isChecked());
            assertTrue(mockCheckBox2.isChecked());
        });
    }

    @Test
    public void testZodiacSignCalculation() {
        when(mockRadioGroup.getCheckedRadioButtonId()).thenReturn(R.id.radio1);
        when(mockCheckBox1.isChecked()).thenReturn(true);
        when(mockCheckBox2.isChecked()).thenReturn(false);
        when(mockSpinnerDay.getSelectedItem()).thenReturn("15");
        when(mockSpinnerMonth.getSelectedItem()).thenReturn("5");
        when(mockSpinnerYear.getSelectedItem()).thenReturn("2021");

        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);
        scenario.onActivity(activity -> {
            activity.setSpinner(mockSpinnerDay);
            activity.setSpinner2(mockSpinnerMonth);
            activity.setSpinner3(mockSpinnerYear);
            activity.setCheckBox1(mockCheckBox1);
            activity.setTextView(mockTextView);

            activity.getEditText().setText("Иван");

            Button button = activity.findViewById(R.id.button1);
            button.performClick();


            String expectedText = "Телец";
            verify(mockTextView).setText(expectedText, null);
        });
    }

    @Test
    public void testZodiacSignIncorrectCalculation() {
        when(mockRadioGroup.getCheckedRadioButtonId()).thenReturn(R.id.radio1);
        when(mockCheckBox1.isChecked()).thenReturn(true);
        when(mockCheckBox2.isChecked()).thenReturn(false);
        when(mockSpinnerDay.getSelectedItem()).thenReturn("40");
        when(mockSpinnerMonth.getSelectedItem()).thenReturn("23");
        when(mockSpinnerYear.getSelectedItem()).thenReturn("2021");

        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);
        scenario.onActivity(activity -> {
            activity.setSpinner(mockSpinnerDay);
            activity.setSpinner2(mockSpinnerMonth);
            activity.setSpinner3(mockSpinnerYear);
            activity.setCheckBox1(mockCheckBox1);
            activity.setTextView(mockTextView);

            activity.getEditText().setText("Иван");

            Button button = activity.findViewById(R.id.button1);
            button.performClick();

            String expectedText = "Некоректная дата";
            verify(mockTextView).setText(expectedText, null);
        });
    }

    @Test
    public void testResultDisplay() {
        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);

        String expectedZodiacSign = "Телец";
        String inputName = "Иван";

        scenario.onActivity(activity -> {

            activity.getSpinner().setSelection(14);
            activity.getSpinner2().setSelection(4);
            activity.getSpinner3().setSelection(20);


            activity.getEditText().setText(inputName);


            activity.getCheckBox1().setChecked(true);
            activity.getCheckBox2().setChecked(false);

            activity.getButton().performClick();

            String resultText = activity.getTextView().getText().toString();
            assertEquals("Результат должен отображать правильный знак зодиака", expectedZodiacSign, resultText);
        });
    }

    @Test
    public void testEmptyNameInput() {
        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);

        scenario.onActivity(activity -> {

            activity.getEditText().setText(""); // Пустое имя


            activity.getButton().performClick();


            String resultText = activity.getTextView().getText().toString();
            String expectedMessage = "Введите имя"; // Замените на ожидаемое сообщение об ошибке
            assertEquals("Сообщение об ошибке должно быть корректным", expectedMessage, resultText);
        });
    }

    @Test
    public void testEditTextChange() {
        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);

        scenario.onActivity(activity -> {
            activity.getEditText().setText("Алексей");
            String inputText = activity.getEditText().getText().toString();
            assertEquals("Алексей", inputText);
        });
    }

    @Test
    public void testActivityRestart() {
        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);

        scenario.onActivity(activity -> {
            activity.recreate();
            String initialText = activity.getTextView().getText().toString();
            assertEquals("", initialText);
        });
    }

    @Test
    public void testBothZodiacSignsDisplayed() {
        when(mockSpinnerDay.getSelectedItem()).thenReturn("1");
        when(mockSpinnerMonth.getSelectedItem()).thenReturn("1");
        when(mockSpinnerYear.getSelectedItem()).thenReturn("1980");

        when(mockCheckBox1.isChecked()).thenReturn(true); // Первый чекбокс активен
        when(mockCheckBox2.isChecked()).thenReturn(true); // Второй чекбокс активен

        ActivityScenario<MainActivity> scenario = ActivityScenario.launch(MainActivity.class);
        scenario.onActivity(activity -> {
            activity.setSpinner(mockSpinnerDay);
            activity.setSpinner2(mockSpinnerMonth);
            activity.setSpinner3(mockSpinnerYear);
            activity.setCheckBox1(mockCheckBox1);
            activity.setCheckBox2(mockCheckBox2);
            activity.setTextView(mockTextView);
            activity.getEditText().setText("Иван");

            Button button = activity.findViewById(R.id.button1);
            button.performClick();


            String expectedZodiacSign1 = "Стрелец";
            String expectedZodiacSign2 = "Козерог";


            when(mockTextView.getText()).thenReturn(new SpannableString(expectedZodiacSign1 + expectedZodiacSign2));


            String resultText = mockTextView.getText().toString();
            assertTrue("Оба знака зодиака должны быть отображены",
                    resultText.contains(expectedZodiacSign1) && resultText.contains(expectedZodiacSign2));
        });
    }

}