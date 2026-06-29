using Lec03LibN.Abstraction;

namespace PP03;

public class Employee
{
	public IBonus bonus { get; private set; }

	public Employee(IBonus bonus)
	{
		this.bonus = bonus;
	}

	public float calcBonus(float number_hour)
	{
		return bonus.calc(number_hour);
	}
}