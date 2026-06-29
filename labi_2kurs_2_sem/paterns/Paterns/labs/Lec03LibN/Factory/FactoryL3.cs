using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Lec03LibN.Abstraction;
using Lec03LibN.BonusCalculator;

namespace Lec03LibN.Factory;
public class FactoryL3 : IFactory
{
	public float a { get; set; }
	public float b { get; set; }

	public FactoryL3(float a, float b)
	{
		this.a = a;
		this.b = b;
	}

	public IBonus getA(float cost1hour)
	{
		return new BonusCalculatorL3A(cost1hour, a, b);
	}

	public IBonus getB(float cost1hour, float x)
	{
		return new BonusCalculatorL3B(cost1hour, a, b, x);
	}

	public IBonus getC(float cost1hour, float x, float y)
	{
		return new BonusCalculatorL3C(cost1hour, a, b, x, y);
	}
}
