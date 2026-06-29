using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Lab5Lib.Abstraction;

namespace Lab5Lib;
public class StrWriter : IWriter
{
	public string? Save(string? message)
	{
		return message;
	}
}
