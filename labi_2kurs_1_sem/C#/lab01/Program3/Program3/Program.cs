using System;

class Program3
{
    static void Main()
    {
        // Задание кортежа
        var tuple = (42, "Hello", 'A', "World", 1234567890UL);

        // Вывод значений кортежа
        Console.WriteLine("Tuple values:");
        Console.WriteLine(tuple);
        Console.WriteLine("Item1: " + tuple.Item1);
        Console.WriteLine("Item3: " + tuple.Item3);
        Console.WriteLine("Item4: " + tuple.Item4);

        // Распаковка кортежа в отдельные переменные
        var (item1, item2, item3, item4, item5) = tuple;
        Console.WriteLine("Using deconstruction:");
        Console.WriteLine("item1: " + item1);
        Console.WriteLine("item2: " + item2);
        Console.WriteLine("item3: " + item3);
        Console.WriteLine("item4: " + item4);
        Console.WriteLine("item5: " + item5);

        // Распаковка кортежа в переменные с использованием _
        (_, var message, _, _, _) = tuple;
        Console.WriteLine("Using _:");
        Console.WriteLine("message: " + message);

        var tuple1 = (1, "Hello", 'A');
        var tuple2 = (1, "World", 'B');

        // Сравнение кортежей
        bool isEqual = tuple1 == tuple2;
        bool isNotEqual = tuple1 != tuple2;

        Console.WriteLine("Tuple1 == Tuple2: " + isEqual);
        Console.WriteLine("Tuple1 != Tuple2: " + isNotEqual);
    }
}