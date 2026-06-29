using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Lab55Lib.Abstraction;

namespace Lab55Lib
{
    public class StrWriter : IWriter {
        public string? Save(string? message) {
            return message;
        }
    }
}
