using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace _2.Models
{
    public class Reason
    {
        public string ReasonString {  get; set; }

        public Reason(string reason)
        {
			ReasonString = reason;
        }
    }
}
