namespace ConsoleApp1
{
    internal partial class Program
    {
        public class C1
        {
            private const int _const = 100;
            public const int Const = 200;
            protected const int protConst = 300;

            private int _int = 1;
            private string _string = "Private";

            public int Int = 2;
            public string Str = "Public";

            protected int protInt = 3;
            protected string protStr = "Protected";

            private int _pint { get; set; }
            public int PInt { get; set; }
            public string PStr { get; set; }
            protected int ProtInt { get; set; }

            public C1()
            {
                Console.WriteLine("Конструктор по умолчанию 1");
            }
            public C1(C1 c)
            {
                Console.WriteLine("Конструктор копирования 1");
                PInt = c.Int;
                PStr = c.Str;
            }
            public C1(int Int, string Str)
            {
                Console.WriteLine("Конструктор с параметрами 1");
                this.Int = Int;
                this.Str = Str;
            }

            private void PrivateMethod()
            {
                Console.WriteLine("Вызван приватный метод.");
            }
            public void PublicMethod()
            {
                Console.WriteLine("Вызван публичный метод.");
                PrivateMethod();
            }
            protected void ProtectedMethod()
            {
                Console.WriteLine("Вызван защищенный метод.");
            }
        }
    }
}