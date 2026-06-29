using System;
namespace first_lab
{
	public class Tuples
	{

        public void pointA()
        {

            (string, int, string, char, ulong) tuple = ("Mikita", 18, "Papko", 't', 1234567890);

        }


        public void pointB()
        {
            (string, int, string, char, ulong) tuple = ("Mikita", 18, "Papko", 't', 1234567890);


            Console.WriteLine($"Кортеж полностью: {tuple}");

            Console.WriteLine($"Кортеж полностью: {tuple.Item1} {tuple.Item3} {tuple.Item4}");

        }

        public void pointC()
        {

            //unboxing tuplel in variable

            var tupleBox = (1, "mikita", 13.13);
            var (first, second, third) = tupleBox;



            //use (_) as variable
            var tupleUnderlining = (13, "lol", 13.13);
            (int i, string s, _) = tupleUnderlining; // element 13.13 ignored

        }
    }
}

