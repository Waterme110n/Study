using System;
using System.Text;

class Program
{
    static void Main()
    {
        Console.WriteLine("строковый литерал");

        string str1 = "hello";
        string str2 = "beautiful";
        string str3 = "world";

        // Сцепление строк
        string concatenated = str1 + " " + str2;
        Console.WriteLine("Concatenated string: " + concatenated);

        // Копирование строк
        string copied = String.Copy(str1);
        Console.WriteLine("Copied string: " + copied);

        // Выделение подстроки
        string substring = str2.Substring(0, 3);
        Console.WriteLine("Substring: " + substring);

        // Разделение строки на слова
        string sentence = "hello beautiful world";
        string[] words = sentence.Split(' ');
        Console.WriteLine("Split words:");
        foreach (string word in words)
        {
            Console.WriteLine(word);
        }

        // Вставка подстроки в заданную позицию
        string original = "hello beautiful world";
        string inserted = original.Insert(6, "lazy ");
        Console.WriteLine("new string: " + inserted);

        // Удаление заданной подстроки
        string removed = original.Remove(15, 6);
        Console.WriteLine("Removed string: " + removed);

        // Интерполирование строк
        string name = "Alice";
        int age = 25;
        string interpolated = $"My name is {name} and I'm {age} years old.";
        Console.WriteLine("Interpolated string: " + interpolated);

        //пустая строка
        string emptyString = string.Empty;
        Console.WriteLine("Empty string: " + emptyString);

        //строка null
        string nullString = null;
        Console.WriteLine("Null string: " + nullString);

        Console.WriteLine("Is emptyString null or empty? " + string.IsNullOrEmpty(emptyString)); //true
        Console.WriteLine("Is nullString null or empty? " + string.IsNullOrEmpty(nullString)); //true

        // Сравнение строк
        string str4 = "Hello";
        string str5 = "World";
        bool areEqual = str1 == str2;
        Console.WriteLine("Are str1 and str2 equal? " + areEqual);

        // Длина строки
        int length = str1.Length;
        Console.WriteLine("Length of str1: " + length);

        // Приведение строки к верхнему или нижнему регистру
        string uppercase = str1.ToUpper();
        string lowercase = str2.ToLower();
        Console.WriteLine("Uppercase str1: " + uppercase);
        Console.WriteLine("Lowercase str2: " + lowercase);

        // Поиск подстроки
        string sentence1 = "The quick brown fox jumps over the lazy dog";
        bool containsFox = sentence1.Contains("fox");
        Console.WriteLine("Does the sentence contain 'fox'? " + containsFox);

        // Замена подстроки
        string replaced = sentence.Replace("brown", "red");
        Console.WriteLine("Replaced string: " + replaced);

        // Создание строки на основе StringBuilder
        StringBuilder stringBuilder = new StringBuilder("Hello, World!");

        Console.WriteLine("Original string: " + stringBuilder.ToString());

        // Удаление определенных позиций
        stringBuilder.Remove(7, 5);
        Console.WriteLine("String after removal: " + stringBuilder.ToString());

        // Добавление новых символов в начало и конец строки
        stringBuilder.Insert(0, "Greetings, ");
        stringBuilder.Append(" How are you?");
        Console.WriteLine("String after insertion: " + stringBuilder.ToString());
    }
}