using System;
using System.Globalization;

namespace first_lab
{
	public class Variables
	{

        public void pointA() {

            //Console.WriteLine("Input bool variable");
            //bool BoolVariable = Convert.ToBoolean(Console.ReadLine());

            //Console.WriteLine("Input byte variable");
            //byte ByteVariable = Convert.ToByte(Console.ReadLine());

            //Console.WriteLine("Input sbyte variable");
            //sbyte SByteVariable = Convert.ToSByte(Console.ReadLine());

            //Console.WriteLine("Input char variable");
            //char CharVariable = Convert.ToChar(Console.ReadLine());

            Console.WriteLine("Input float variable");
            float FloatVariable = Convert.ToSingle(Console.ReadLine());

            //Console.WriteLine("Input double variable");
            //double DoubleVarible = Convert.ToDouble(Console.ReadLine());

            //Console.WriteLine("Input decimal variable");
            //decimal DecimalVariable = Convert.ToDecimal(Console.ReadLine());

            //Console.WriteLine("Input int variable");
            //int IntVariable = Convert.ToInt32(Console.ReadLine());

            //Console.WriteLine("Input uint variable");
            //uint UintVariable = Convert.ToUInt32(Console.ReadLine());


            Console.WriteLine("variables:");
            //Console.WriteLine(" bool variable is: {0}", BoolVariable);
            //Console.WriteLine(" byte variable is: {0}", ByteVariable);
            //Console.WriteLine(" sbyte variable is: {0}", SByteVariable);
            //Console.WriteLine(" char variable is: {0}", CharVariable);
            Console.WriteLine(" float variable is: {0}", FloatVariable);
            //Console.WriteLine(" double variable is: {0}", DoubleVarible);
            //Console.WriteLine(" decimal variable is: {0}", DecimalVariable);
            //Console.WriteLine(" int variable is: {0}", IntVariable);
            //Console.WriteLine(" uint variable is: {0}", UintVariable);
            Console.ReadKey();

        }

        public void pointB() {
            byte a = 1;
            int b = a;

            sbyte c = 2;
            double d = c;

            int f = 3;
            decimal g = f;

            uint p = 9;
            decimal y = p;

            float t = 1.1f;
            double r = t;



            int i = 1;
            byte e = (byte)i;

            double o = 2.2;
            int n = (int)o;

            float j = 1.1f;
            byte l = (byte)j;

            decimal q = 1.23456789876543213M;
            uint s = (uint)q;

            int h = 5;
            char v = (char)h;
        }

        public void pointC() {

            int value = 13; // "value" is a value type
            object Object = value; // boxing "value" into "Object"
            int NewValue = (int)Object; // unboxing "Object" into "NewValue"

        }

        public void pointD()
        {

            var VAR = 5;

        }

        public void pointE() {

            int? nullValue = null;
            Console.WriteLine(nullValue);

        }


       

        
    }
}

