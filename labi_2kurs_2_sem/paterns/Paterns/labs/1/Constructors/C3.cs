namespace ConsoleApp1
{
    internal partial class Program
    {
        public class C3
        {
            public string public_string = "Публичная строка C3";
            private string private_string = "Приватная строка C3";
            protected string protected_string = "Защищенная строка C3";

            public string Show_private_string
            {
                get { return private_string; }
            }

            public virtual void Method()
            {
                Console.WriteLine("Вызван метод в C3");
            }
        }
    }
}