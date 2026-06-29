namespace ConsoleApp1
{
    internal partial class Program
    {
        static void Main()
        {
            C1 first_c1 = new();
            C1 second_c1 = new(1, "second_c1_text");
            C1 third_c1 = new(second_c1);

            Console.WriteLine($"{first_c1.Int} {first_c1.Str}");
            Console.WriteLine($"{second_c1.Int} {second_c1.Str}");
            Console.WriteLine($"{third_c1.PInt} {third_c1.PStr}");
            first_c1.PublicMethod();

            Console.WriteLine("\n---------------\n");

            C2 first_c2 = new();
            C2 second_c2 = new(2, "second_c2_text");
            C2 third_c2 = new(second_c2);

            first_c2.I1_method();
            first_c2.I1_property = 11111;
            Console.WriteLine($"Свойство: {first_c2.I1_property} Поле: {first_c2.Str}");

            Console.WriteLine("\n---------------\n");

            C3 first_c3 = new();
            C4 first_c4 = new();

            string _string = first_c4.Show_private_string;

            first_c3.Method();
            first_c4.Method();

            Console.WriteLine($"Наследуем от C3 приватную строку {_string}");
        }
    }
}