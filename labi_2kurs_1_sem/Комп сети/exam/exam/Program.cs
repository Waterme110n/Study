using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Authentication.ExtendedProtection;
using System.Text;
using System.Threading.Tasks;

namespace exam
{

    public class Rectangle
    {
        private double height { get; set; }
        private double width { get; set; }
        private string borderColor;
        public double Area => Width * Height;

        public double Height
        {
            get { return height; }
            set
            {
                if (value > 0)
                    height = value;
                else
                    throw new ArgumentException("Высота должна быть положительным числом.");

            }
        }
        public double Width
        {
            get { return width; }
            set
            {
                if (value > 0)
                    width = value;
                else
                    throw new ArgumentException("Высота должна быть положительным числом.");

            }
        }
        public string BorderColor
        {
            get { return borderColor; }
            set
            {
                if (!string.IsNullOrEmpty(value))
                    borderColor = value;
                else
                    throw new ArgumentException("Цвет границы должен быть указан.");
            }
        }
        public Rectangle(double height, double width, string borderColor)
        {
            Height = height;
            Width = width;
            BorderColor = borderColor;

        }

        public double CalculateArea()
        {
            return Height * Width;
        }

        public double CalculatePerimeter()
        {
            return 2 * (Height + Width);
        }

    }

    public class InsufficientExecutionStackException : Exception
    {
        public InsufficientExecutionStackException(string message) : base(message)
        {
        }
    }

    public class GoodStack<T> : Stack<T>
    {
        public new void Push(T item)
        {
            base.Push(item);
        }

        public new T Pop()
        {
            if (Count == 0)
            {
                throw new InsufficientExecutionStackException("Стек пустой");
            }

            return base.Pop();
        }
    }

    public class Point
    {
        public int X { get; set; }
        public int Y { get; set; }

        public Point(int x, int y)
        {
            X = x;
            Y = y;
        }
    }
    
    internal class Program
    {
        public static void Main()
        {
            Rectangle rectangle = new Rectangle(5, 10, "Red");
            Console.WriteLine("Высота: " + rectangle.Height);
            Console.WriteLine("Ширина: " + rectangle.Width);
            Console.WriteLine("Цвет границы: " + rectangle.BorderColor);
            Console.WriteLine("Площадь: " + rectangle.CalculateArea());
            Console.WriteLine("Периметр: " + rectangle.CalculatePerimeter());

            try
            {
                GoodStack<Point> pointStack = new GoodStack<Point>();
                pointStack.Push(new Point(1, 2));
                pointStack.Push(new Point(3, 4));

                Console.WriteLine("добавленный эллемент: " + pointStack.Pop());
                Console.WriteLine("добавленный эллемент: " + pointStack.Pop());
                Console.WriteLine("добавленный эллемент: " + pointStack.Pop()); 
            }
            catch (InsufficientExecutionStackException ex)
            {
                Console.WriteLine("Error: " + ex.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Unexpected error: " + ex.Message);
            }

            List<Rectangle> rectangleList = new List<Rectangle>();

            rectangleList.Add(new Rectangle(5, 10, "Red"));
            rectangleList.Add(new Rectangle(8, 6, "blue"));
            rectangleList.Add(new Rectangle(3, 3, "Yellow"));
            rectangleList.Add(new Rectangle(12, 4, "green"));
            rectangleList.Add(new Rectangle(7, 9, "black"));

            foreach (Rectangle rectangles in rectangleList)
            {
                Console.WriteLine("Width: " + rectangles.Width + ", Height: " + rectangles.Height + ", Color: " + rectangle.BorderColor);
            }

            var sortedRectangles = rectangleList.OrderBy(rectangles => rectangle.Height)
                                           .ThenBy(rectangles => rectangle.Width)
                                           .ThenBy(rectangles => rectangle.Area);

            Rectangle firstRectangle = sortedRectangles.First();
            Rectangle lastRectangle = sortedRectangles.Last();

            Console.WriteLine("First Rectangle - Width: {0}, Height: {1}", firstRectangle.Width, firstRectangle.Height);
            Console.WriteLine("Last Rectangle - Width: {0}, Height: {1}", lastRectangle.Width, lastRectangle.Height);
        }
    }
}

