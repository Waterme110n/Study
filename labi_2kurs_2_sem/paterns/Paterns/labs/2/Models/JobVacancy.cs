using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace _2.Models
{
    public class JobVacancy
    {
        public string Title { get; set; }
        public string Vacancy { get; set; }

        public JobVacancy(JobTitle title, string vacancy)
        {
            Title = title.Title;
            Vacancy = vacancy;
        }
    }
}
