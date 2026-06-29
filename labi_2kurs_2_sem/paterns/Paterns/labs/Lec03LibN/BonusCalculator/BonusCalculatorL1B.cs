using Lec03LibN.Abstraction;

namespace Lec03LibN.BonusCalculator;
public class BonusCalculatorL1B : IBonus
{
	public float cost1hour { get; set; }
	public float x { get; set; }

	public BonusCalculatorL1B(float cost1hour, float x)
	{
		this.cost1hour = cost1hour;
		this.x = x;
	}

	public float calc(float numberOfHours)
	{
		return numberOfHours * cost1hour * x;
	}
}
