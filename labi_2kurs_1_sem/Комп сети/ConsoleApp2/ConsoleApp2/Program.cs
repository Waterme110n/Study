using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp2
{
    class Program
    {
        static void Main(string[] args)
        {
            Date date = new Date(30, 12);
            date.NextDay();
            Console.WriteLine(date);
            Date date2 = new Date(30, 12, 2019);
            date2.NextDay();
            Console.WriteLine(date2);
            Console.WriteLine(date > date2);
            Console.ReadKey();
        }
    }
    class Date
    {
        private int day;
        private int month;
        private int year;
        public Date(int day, int month, int year)
        {
            if (day > 0 && day < 32)
            {
                this.day = day;
            }
            else
            {
                Console.WriteLine("Wrong day");
            }
            if (month > 0 && month < 13)
            {
                this.month = month;
            }
            else
            {
                Console.WriteLine("Wrong month");
            }
            this.year = year;
        }
        public Date(int day, int month)
        {
            if (day > 0 && day < 32)
            {
                this.day = day;
            }
            else
            {
                Console.WriteLine("Wrong day");
            }
            if (month > 0 && month < 13)
            {
                this.month = month;
            }
            else
            {
                Console.WriteLine("Wrong month");
            }
        }
        public void NextDay()
        {
            if (this.day < 31)
            {
                this.day++;
            }
            else
            {
                this.day = 1;
                if (this.month < 12)
                {
                    this.month++;
                }
                else
                {
                    this.month = 1;
                    this.year++;
                }
            }
        }
        public override string ToString()
        {
            return day + "." + month + "." + year;
        }
        public static bool operator >(Date date1, Date date2)
        {
            if (date1.year > date2.year)
            {
                return true;
            }
            else if (date1.year == date2.year)
            {
                if (date1.month > date2.month)
                {
                    return true;
                }
                else if (date1.month == date2.month)
                {
                    if (date1.day > date2.day)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
}


