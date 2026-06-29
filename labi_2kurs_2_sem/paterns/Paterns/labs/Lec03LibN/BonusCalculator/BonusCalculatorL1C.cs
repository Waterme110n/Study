using Lec03LibN.Abstraction;

namespace Lec03LibN.BonusCalculator;
public class BonusCalculatorL1C : IBonus
{
	public float cost1hour { get; set; }
	public float x { get; set; }
	public float y { get; set; }


	public BonusCalculatorL1C(float cost1hour, float x, float y)
	{
		this.cost1hour = cost1hour;
		this.x = x;
		this.y = y;
	}

	public float calc(float numberOfHours)
	{
		return numberOfHours * cost1hour * x + y;
	}
}