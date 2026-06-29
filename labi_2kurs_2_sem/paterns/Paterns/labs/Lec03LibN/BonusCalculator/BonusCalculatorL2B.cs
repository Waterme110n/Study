using Lec03LibN.Abstraction;

namespace Lec03LibN.BonusCalculator;
public class BonusCalculatorL2B : IBonus
{
	public float cost1hour { get; set; }
	public float a { get; set; }
	public float x { get; set; }

	public BonusCalculatorL2B(float cost1hour,  float x, float a)
	{
		this.cost1hour = cost1hour;
		this.x = x;
		this.a = a;
	}

	public float calc(float numberOfHours)
	{
		Console.WriteLine(a.ToString());
		Console.WriteLine(x.ToString());
		return (numberOfHours + a) * cost1hour * x;
	}
}
