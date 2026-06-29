using Lec03LibN.Abstraction;

namespace Lec03LibN.BonusCalculator;
public class BonusCalculatorL3B : IBonus
{
	public float cost1hour { get; set; }
	public float a { get; set; }
	public float b { get; set; }
	public float x { get; set; }

	public BonusCalculatorL3B(float cost1hour, float a, float b, float x)
	{
		this.cost1hour = cost1hour;
		this.a = a;
		this.b = b;
		this.x = x;
	}

	public float calc(float numberOfHours)
	{
		return (numberOfHours + a) * (cost1hour + b) * x;
	}
}
