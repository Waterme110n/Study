using Lec03LibN.Abstraction;

namespace Lec03LibN.BonusCalculator;
public class BonusCalculatorL1A : IBonus
{
	public float cost1hour { get; set; }

	public BonusCalculatorL1A(float cost1hour)
	{
		this.cost1hour = cost1hour;
	}

	public float calc(float numberOfHours)
	{
		return numberOfHours * cost1hour;
	}
}