using System;
using static System.Net.Mime.MediaTypeNames;
using System.Data.SqlTypes;
using System.Text;

namespace first_lab
{
	public class Strings
	{

        public void pointA()
        {

            string s1 = "hello ";
            string s2 = "world";

            Console.WriteLine($"s1: {s1}");
            Console.WriteLine($"s2: {s2}");



            int result = string.Compare(s1, s2);
            if (result < 0)
            {
                Console.WriteLine("s1 is higher s2");
            }
            else if (result > 0)
            {
                Console.WriteLine("s2 is higher s1");
            }
            else
            {
                Console.WriteLine(" s1 and s2 are equal");
            }

        }

        public void pointB()
        {
            string s1 = "hello ";
            string s2 = "world";
            string s3 = "!!!";

            Console.WriteLine($"s1: {s1}");
            Console.WriteLine($"s2: {s2}");
            Console.WriteLine($"s1: {s3}");

            string s4 = s1 + " " + s2; // результат: строка "hello world"

            Console.WriteLine($" s1 + s2 = {s4}");

            string s5 = string.Concat(s4, s3); // результат: строка "hello world!!!"

            Console.WriteLine($"  = {s4}");


            Console.WriteLine(s5);


            //////copy////////
            var original = s1;
            var duplicate = original.Substring(0, original.IndexOf("l") + 1);
            Console.WriteLine(original);
            Console.WriteLine(duplicate);

            ///////
            string s = "You win some. You lose some.";

            string[] subs = s.Split(' ');

            foreach (var sub in subs)
            {
                Console.WriteLine($"Substring: {sub}");
            }

            var text = s4.Insert(5, s3);
            Console.WriteLine(text);

            ////////Remove Substring///////
            int ind = s2.Length - 1;
            var remove_string = s2.Remove(ind);
            Console.WriteLine(remove_string);

            //String interpolation:
            double x = 15.59;
            double y = 19.17;
            Console.WriteLine($"{x} + {y} = {x + y}"); // 15,59 + 19,17 = 34,76
        }


        public void pointC()
		{

            string empty = "";
            string null_string = null;

            Console.WriteLine(String.IsNullOrEmpty(empty));
            Console.WriteLine(String.IsNullOrEmpty(null_string));

        }

        public void pointD()
        {

            var sb = new StringBuilder(" is ");

            sb.Append("cool ");
            sb.Insert(1, "Nikita ");

            Console.WriteLine(sb);


            sb.Remove(7, 3);
            Console.WriteLine(sb);

        }

    }
}

