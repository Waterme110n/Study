using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Lec03LibN.Abstraction;
using Lec03LibN.BonusCalculator;

namespace Lec03LibN.Factory;
public class FactoryL2 : IFactory
{
	public float a { get; set; }

	public FactoryL2(float a)
	{
		this.a = a;
	}

	public IBonus getA(float cost1hour)
	{
		return new BonusCalculatorL2A(cost1hour, a);
	}

	public IBonus getB(float cost1hour, float x)
	{
		return new BonusCalculatorL2B(cost1hour, a, x);
	}

	public IBonus getC(float cost1hour, float x, float y)
	{
		return new BonusCalculatorL2C(cost1hour, a, x, y);
	}
}
