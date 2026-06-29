using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Lab55Lib.Abstraction;

namespace Lab55Lib.Decorator
{
    public class Decorator : IWriter
    {   
        protected IWriter? _writer;

        public Decorator(IWriter? writer)
        {
            _writer = writer;
        }

        public virtual string? Save(string? message)
        {
            return _writer?.Save(message);
        }
    }
}
