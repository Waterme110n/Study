using Lec03LibN.Abstraction;

namespace Lec03LibN.BonusCalculator;
public class BonusCalculatorL2A : IBonus
{
	public float cost1hour { get; set; }
	public float a { get; set;  }

	public BonusCalculatorL2A(float cost1hour, float a)
	{
		this.cost1hour = cost1hour;
		this.a = a;
	}

	public float calc(float numberOfHours)
	{
		return (numberOfHours + a) * cost1hour;
	}
}