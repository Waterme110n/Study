using System;

class Program
{
    static void Main()
    {
        Console.WriteLine("bool");
        bool BoolVariable = Convert.ToBoolean(Console.ReadLine());

        Console.WriteLine("byte ");
        byte ByteVariable = Convert.ToByte(Console.ReadLine());

        Console.WriteLine("sbyte ");
        sbyte SByteVariable = Convert.ToSByte(Console.ReadLine());

        Console.WriteLine("char variable");
        char CharVariable = Convert.ToChar(Console.ReadLine());

        Console.WriteLine("float");
        float FloatVariable = Convert.ToSingle(Console.ReadLine());

        Console.WriteLine("double");
        double DoubleVarible = Convert.ToDouble(Console.ReadLine());

        Console.WriteLine("decimal");
        decimal DecimalVariable = Convert.ToDecimal(Console.ReadLine());

        Console.WriteLine("int");
        int IntVariable = Convert.ToInt32(Console.ReadLine());

        Console.WriteLine("uint");
        uint UintVariable = Convert.ToUInt32(Console.ReadLine());

        Console.WriteLine("");
        Console.WriteLine(" bool: {0}", BoolVariable);
        Console.WriteLine(" byte: {0}", ByteVariable);
        Console.WriteLine(" sbyte: {0}", SByteVariable);
        Console.WriteLine(" char: {0}", CharVariable);
        Console.WriteLine(" float: {0}", FloatVariable);
        Console.WriteLine(" double: {0}", DoubleVarible);
        Console.WriteLine(" decimal: {0}", DecimalVariable);
        Console.WriteLine(" int: {0}", IntVariable);
        Console.WriteLine(" uint: {0}", UintVariable);
    }

    public void taskB()
    {
        //неявные преобразования
        byte a = 1;
        int b = a;

        sbyte c = 2;
        double d = c;

        int e = 3;
        decimal f = e;

        uint g = 9;
        decimal h = g;

        float t = 1.1f;
        double m = t;


        //явные преобразования
        int i = 1;
        byte p = (byte)i;

        double o = 2.2;
        int n = (int)o;

        float j = 1.1f;
        byte l = (byte)j;

        decimal q = 1.23456789876543213M;
        uint s = (uint)q;

        int r = 5;
        char v = (char)r;
    }

    public void taskC()
    {

        // Упаковка значимого типа
        int intValue = 42;
        object boxedValue = intValue; // Упаковка значения типа int в объект

        // Распаковка объекта в значимый тип
        int unboxedValue = (int)boxedValue; // Распаковка объекта в тип int

    }

    public void taskD()
    {
        var EXA = 5;
    }

    public void taskE()
    {
        int? val = null;
        Console.WriteLine(val);    // null
        val = 22;
        Console.WriteLine(val);
    }
}
