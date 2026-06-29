using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;  

namespace ConsoleApp1
{
    public class Program
    {

        static void Main(string[] args)
        {
            try
            {
                int choose;
                Console.WriteLine("Выберите действие:\n1.НОД 2 чисел\n2.НОД 3 чисел\n3.Поиск простых чисел" +
                    "\n4.Проверка числа на простоту\n5.Разложение на простые множители.\n6.Решето эрастофена\n7.Выход");
                do
                {
                    choose = Convert.ToInt32(Console.ReadLine());
                    switch (choose)
                    {
                        case 1: FindNod2(); break;
                        case 2: FindNod3(); break;
                        case 3: FindPrimeNumber(); break;
                        case 4:
                            if (isSimple())
                            {
                                Console.WriteLine("Число простое"); 
                            }
                            else
                            {
                                Console.WriteLine("Число не простое"); 
                            }
                            break;
                        case 5: PrimeFactorization(); break;
                        case 6: Eratosthenes(); break;
                        case 7: return;
                        default: Console.WriteLine("Не корректные данные"); break;
                    }
                }
                while (choose != 7);
            }
            catch { Console.WriteLine("Не корректные данные"); }
        }

        static void FindNod2()
        {
            int n1, n2, nod;
            Console.WriteLine("Введите 2 числа через пробел");
            string[] k = Console.ReadLine().Split(" ");
            n1 = Convert.ToInt32(k[0]);
            n2 = Convert.ToInt32(k[1]);
            Console.WriteLine("Ответ:" + NOD(n1, n2));
        }

        static void FindNod3()
        {
            int n1, n2, n3, nod;
            Console.WriteLine("Введите 3 числа через пробел");
            string[] k = Console.ReadLine().Split(" ");
            n1 = Convert.ToInt32(k[0]);
            n2 = Convert.ToInt32(k[1]);
            n3 = Convert.ToInt32(k[2]);
            Console.WriteLine("Ответ:" + NOD(NOD(n1, n2), n3));
        }

        static void FindPrimeNumber()
        {
            int n1, n2;
            Console.WriteLine("Введите числа через пробел");
            string[] k = Console.ReadLine().Split(" ");
            n1 = Convert.ToInt32(k[0]);
            n2 = Convert.ToInt32(k[1]);
            n1 += n1 == 1 ? 1 : 0;
            int min = Math.Min(n1, n2);
            for (;  min<=Math.Max(n1,n2) ; min++)
            {
                bool PrimeNumber = true;
                if(min.ToString().Last()!='0' || min.ToString().Last() != '5' || min.ToString().Last() != '2' || (min.ToString().First()!='1' && min.ToString().Length==1))
                    for (int i = 2; i <= Math.Sqrt(min); i++)
                    {
                        if (min % i == 0)
                        {
                            PrimeNumber = false;
                            break;
                        }
                    }
                if(PrimeNumber)
                Console.WriteLine(min);
            }
        }

        private static bool isSimple()
        {
            Console.WriteLine("Введите число");
            var N = Convert.ToInt32(Console.ReadLine());
            for (int i = 2; i <= (int)(N / 2); i++)
            {
                if (N % i == 0)
                    return false;
            }
            return true;
        }

        static void PrimeFactorization()
        {
            Console.WriteLine("Введите число");
            var N = Convert.ToInt32(Console.ReadLine());
            Console.Write("{0} = 1", N);
            for (int i = 0; N % 2 == 0; N /= 2)
            {
                Console.Write(" * {0}", 2);
            }
            for (int i = 3; i <= N;)
            {
                if (N % i == 0)
                {
                    Console.Write(" * {0}", i);
                    N /= i;
                }
                else
                {
                    i += 2;
                }
            }
            Console.WriteLine();
        }

        static List<uint> Eratosthenes()
        {
            Console.WriteLine("Введите число");
            var N = Convert.ToInt32(Console.ReadLine());
            var numbers = new List<uint>();
            for (var i = 2u; i < N; i++)
            {
                numbers.Add(i);
            }

            for (var i = 0; i < numbers.Count; i++)
            {
                for (var j = 2u; j < N; j++)
                {
                    numbers.Remove(numbers[i] * j);
                }
            }
            foreach (var i in numbers)
            {
                Console.Write(i + " ");
            }
            Console.WriteLine();
            return numbers;
        }

        static int NOD(int x,int y)
        {
            while (x!=0 && y!=0)
            {
                if (x > y)
                    x = x % y;
                else
                    y = y % x;
            }
            return (x + y);
        }
    }
}
