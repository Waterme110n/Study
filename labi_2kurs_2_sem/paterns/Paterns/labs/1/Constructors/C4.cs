namespace ConsoleApp1
{
    internal partial class Program
    {
        public class C4 : C3, I2
        {
            public string C4_string = "Публичная строка в С4";

            public override void Method()
            {
                Console.WriteLine("Вызван метод в C4");
            }
        }
    }
}