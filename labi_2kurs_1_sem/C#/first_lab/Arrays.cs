using System;
namespace first_lab
{
	public class Arrays
	{
        public void pointA() {

            int[,] numbers = { { 13, 24, 33 }, { 44, 65, 76 } };

            int rows = numbers.GetUpperBound(0) + 1;    // количество строк
            int columns = numbers.Length / rows;        // количество столбцов


            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < columns; j++)
                {
                    Console.Write($"{numbers[i, j]} \t");
                }
                Console.WriteLine();
            }

        }

        public void pointB()
        {

            string[] footbalTeams = { "Arsenal", "Real", "Inter",
      "Milan", "Napoli", "Lester", "PSG" };

            Console.WriteLine($"Длина массива: {footbalTeams.Length}");

            Console.WriteLine("Введите индекс элемента массива, что должен изменится:");
            int indexModifiedElement = Convert.ToInt32(Console.ReadLine());

            Console.WriteLine("Введите значение элемента массива, что должен изменится:");
            footbalTeams[indexModifiedElement] = Console.ReadLine();

            Console.WriteLine("Содержание массив:");
            // Вывод массива строк 
            for (int i = 0; i < footbalTeams.Length; i++)
            {
                Console.WriteLine("AS[{0}] = {1}", i, footbalTeams[i]);
            }

        }

        public void pointC() {


            double[][] stepwiseArray = new double[3][];


            stepwiseArray[0] = new double[2];
            stepwiseArray[1] = new double[3];
            stepwiseArray[2] = new double[4];

            Console.WriteLine("Инициализация первой строки:");
            for (int i = 0; i < 2; i++)
            {
                stepwiseArray[0][i] = Convert.ToDouble(Console.ReadLine());
            }

            Console.WriteLine("Инициализация второй строки:");
            for (int i = 0; i < 3; i++)
            {
                stepwiseArray[1][i] = Convert.ToDouble(Console.ReadLine());
            }

            Console.WriteLine("Инициализация третей строки:");
            for (int i = 0; i < 4; i++)
            {
                stepwiseArray[2][i] = Convert.ToDouble(Console.ReadLine());
            }



            for (int i = 0; i < 2; i++)
            {
                Console.Write($"\t {stepwiseArray[0][i]} ");
            }

            Console.WriteLine();

            for (int i = 0; i < 3; i++)
            {
                Console.Write($"\t {stepwiseArray[1][i]}");
            }

            Console.WriteLine();

            for (int i = 0; i < 4; i++)
            {
                Console.Write($"\t {stepwiseArray[2][i]}");
            }


        }

        public void pointD()
        {

            var varArray = new[] { 1, 2, 3, 4, 5 }; // неявно типизированный массив
            var vartring = "Hello, World!"; // неявно типизированная строка

        }
    }
}




