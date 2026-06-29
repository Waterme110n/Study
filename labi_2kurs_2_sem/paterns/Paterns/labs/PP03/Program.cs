
using Lec03LibN;
using Lec03LibN.Abstraction;

namespace PP03;

internal class Program
{
	static void Main()
	{
		IFactory l1 = Lec03Lib.getL1();

		Employee employee1 = new Employee(l1.getA(25));
		Console.WriteLine($"Bonus-L1-A = {employee1.calcBonus(4)}");

		Employee employee2 = new Employee(l1.getB(25, 1.1f));
		Console.WriteLine($"Bonus-L1-B = {employee2.calcBonus(4)}");

		Employee employee3 = new Employee(l1.getC(25, 1.1f, 5.0f));
		Console.WriteLine($"Bonus-L1-C = {employee3.calcBonus(4)}");

		IFactory l2 = Lec03Lib.getL2(1);

		Employee employee4 = new Employee(l2.getA(25));
		Console.WriteLine($"Bonus-L2-A = {employee4.calcBonus(4)}");

		Employee employee5 = new Employee(l2.getB(25, 1.1f));
		Console.WriteLine($"Bonus-L2-B = {employee5.calcBonus(4)}");

		Employee employee6 = new Employee(l2.getC(25, 1.1f, 5.0f));
		Console.WriteLine($"Bonus-L2-C = {employee6.calcBonus(4)}");

		IFactory l3 = Lec03Lib.getL3(1, 0.5f);

		Employee employee7 = new Employee(l3.getA(25));
		Console.WriteLine($"Bonus-L3-A = {employee7.calcBonus(4)}");

		Employee employee8 = new Employee(l3.getB(25, 1.1f));
		Console.WriteLine($"Bonus-L3-B = {employee8.calcBonus(4)}");

		Employee employee9 = new Employee(l3.getC(25, 1.1f, 0.5f));
		Console.WriteLine($"Bonus-L3-C = {employee9.calcBonus(4)}");
	}
}
