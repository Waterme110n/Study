using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace _2.Models
{
    public class Employee
    {
        public JobVacancy Vacancy { get; set; }
        public string Name { get; set; }

        public Employee(JobVacancy vacancy, Person person)
        {
            Vacancy = vacancy;
            Name = person.Name;
		}
    }
}
