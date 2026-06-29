using Lec03LibN.Abstraction;

namespace Lec03LibN.BonusCalculator;
public class BonusCalculatorL3C : IBonus
{
	public float cost1hour { get; set; }
	public float a { get; set; }
	public float b { get; set; }
	public float x { get; set; }
	public float y { get; set; }


	public BonusCalculatorL3C(float cost1hour, float a, float b, float x, float y)
	{
		this.cost1hour = cost1hour;
		this.a = a;
		this.b = b;
		this.x = x;
		this.y = y;
	}

	public float calc(float numberOfHours)
	{
		Console.WriteLine(a.ToString());
		Console.WriteLine(b.ToString());
		Console.WriteLine(x.ToString());
		Console.WriteLine(y.ToString());
		return (numberOfHours + a) * (cost1hour + b) * x + y;
	}
}