using System;

class Program2
{
    static void Main()
    {
        int[,] matrix = new int[,]
        {
            { 1, 2, 3 },
            { 4, 5, 6 },
            { 7, 8, 9 }
        };

        // Получение размерности массива
        int rows = matrix.GetLength(0);
        int columns = matrix.GetLength(1);

        for (int i = 0; i < rows; i++)
        {
            for (int j = 0; j < columns; j++)
            {
                Console.Write(matrix[i, j] + " ");
            }
            Console.WriteLine();
        }

        // Создание одномерного массива строк
        string[] array = new string[] { "Apple", "Banana", "Orange", "Grape" };

        // Вывод содержимого массива
        Console.WriteLine("Array contents:");
        foreach (string item in array)
        {
            Console.WriteLine(item);
        }

        // Длина массива
        int length = array.Length;
        Console.WriteLine("Array length: " + length);

        // Изменение произвольного элемента
        Console.Write("Enter the index of the element to change (0 to " + (length - 1) + "): ");
        int index = int.Parse(Console.ReadLine());

        if (index >= 0 && index < length)
        {
            Console.Write("Enter the new value: ");
            string newValue = Console.ReadLine();

            array[index] = newValue;

            Console.WriteLine("Array after modification:");
            foreach (string item in array)
            {
                Console.WriteLine(item);
            }
        }
        else
        {
            Console.WriteLine("Invalid index!");
        }

        // Создание ступенчатого массива
        double[][] jaggedArray = new double[3][];

        // Заполнение массива значениями с консоли
        for (int i = 0; i < jaggedArray.Length; i++)
        {
            Console.Write("Enter the number of elements for row " + (i + 1) + ": ");
            int numElements = int.Parse(Console.ReadLine());

            jaggedArray[i] = new double[numElements];

            for (int j = 0; j < jaggedArray[i].Length; j++)
            {
                Console.Write("Enter the value for element [" + i + "][" + j + "]: ");
                jaggedArray[i][j] = double.Parse(Console.ReadLine());
            }
        }

        // Вывод содержимого массива
        Console.WriteLine("Array contents:");
        for (int i = 0; i < jaggedArray.Length; i++)
        {
            for (int j = 0; j < jaggedArray[i].Length; j++)
            {
                Console.Write(jaggedArray[i][j] + " ");
            }
            Console.WriteLine();
        }

        // Неявно типизированная переменная для массива
        var array1 = new[] { 1, 2, 3, 4, 5 };

        // Неявно типизированная переменная для строки
        var str = "Hello, World!";

        // Вывод содержимого массива
        foreach (var item in array1)
        {
            Console.WriteLine(item);
        }

        // Вывод строки
        Console.WriteLine(str);
    }
}