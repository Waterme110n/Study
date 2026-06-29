using Lec03LibN.Abstraction;

namespace Lec03LibN.BonusCalculator;
public class BonusCalculatorL2C : IBonus
{
	public float cost1hour { get; set; }
	public float a { get; set; }
	public float x { get; set; }
	public float y { get; set; }


	public BonusCalculatorL2C(float cost1hour, float a, float x, float y)
	{
		this.cost1hour = cost1hour;
		this.a = a;
		this.x = x;
		this.y = y;
	}

	public float calc(float numberOfHours)
	{
		return (numberOfHours + a) * cost1hour * x + y;
	}
}