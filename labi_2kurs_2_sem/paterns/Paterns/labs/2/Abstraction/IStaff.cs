using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using _2.Models;

namespace _2.Abstraction
{
    interface IStaff
    {
        List<JobVacancy> GetJobVacancies();
        List<Employee> GetEmployees();
        List<JobTitle> GetJobTitles();
        int AddJobTitle(JobTitle title);
        void PrintJobVacancies();
        bool DeleteJobTitle(JobTitle title);
        void OpenJobVacancy(JobTitle title, string name);
        bool CloseJobVacancy(JobVacancy vacancy);
        Employee Recruit(JobVacancy job, Person person);
        //void Dismiss(Reason reason);
        bool Dismiss(string Name, Reason reason);
	}
}
