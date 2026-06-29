using Lec03LibN.Abstraction;

namespace Lec03LibN.BonusCalculator;
public class BonusCalculatorL3A : IBonus
{
	public float cost1hour { get; set; }
	public float a { get; set;  }
	public float b { get; set;  }

	public BonusCalculatorL3A(float cost1hour, float a, float b)
	{
		this.cost1hour = cost1hour;
		this.a = a;
		this.b = b;
	}

	public float calc(float numberOfHours)
	{
		return (numberOfHours + a) * (cost1hour + b);
	}
}