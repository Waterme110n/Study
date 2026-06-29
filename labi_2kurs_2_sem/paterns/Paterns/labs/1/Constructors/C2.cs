using _1.Inerfaces;

namespace ConsoleApp1
{
    internal partial class Program
    {
        public class C2 : C1, I1
        {
            public event EventHandler I1_event;
            public int I1_property { get; set; }

            public int this[int index] { get { return protInt; } set { protInt = 200; } }

            public C2()
            {
                Console.WriteLine("Конструктор по умолчанию 2");
            }
            public C2(C2 c)
            {
                Console.WriteLine("Конструктор копирования 2");
                PInt = c.Int;
                PStr = c.Str;
            }
            public C2(int pi2, string ps2)
            {
                Console.WriteLine("Конструктор с параметрами 2");
                this.Int = pi2;
                this.Str = ps2;
            }

            public void I1_method()
            {
                Console.WriteLine("Метод I1 в C2");
            }
        }
    }
}