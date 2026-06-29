using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Lec03LibN.Abstraction;
using Lec03LibN.BonusCalculator;

namespace Lec03LibN.Factory;
public class FactoryL1 : IFactory
{
	public IBonus getA(float cost1hour)
	{
		return new BonusCalculatorL1A(cost1hour);
	}

	public IBonus getB(float cost1hour, float x)
	{
		return new BonusCalculatorL1B(cost1hour, x);
	}

	public IBonus getC(float cost1hour, float x, float y)
	{
		return new BonusCalculatorL1C(cost1hour, x, y);
	}
}
