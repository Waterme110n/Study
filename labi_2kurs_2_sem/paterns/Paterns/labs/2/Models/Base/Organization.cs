using System;
using System.Collections.Generic;
using System.Diagnostics.SymbolStore;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using _2.Abstraction;

namespace _2.Models.Base
{
	public class Organization : IStaff
	{
		public int Id { get; private set; }
		public string Name { get; protected set; }
		public Type ShortName { get; protected set; }
		public string Address { get; protected set; }
		public DateTime TimeStamp { get; protected set; }

		List<JobVacancy> vacancies = new();
		List<JobTitle> titles = new();
		List<Employee> employees = new();

		public Organization()
		{
			//Id = 0;
			//Name = "";
			//ShortName = typeof(Organization);
			//Address = "";
		}

		public Organization(Organization organization)
		{
			Name = organization.Name;
			ShortName = organization.ShortName;
			Address = organization.Address;
		}

		public Organization(string name, string address, Type shortName)
		{
			Name = name;
			ShortName = shortName;
			Address = address;
		}

		public void PrintInfo()
		{
			Console.WriteLine("\nOrganization:");
			Console.WriteLine($"\t-{Name}");
			Console.WriteLine($"\t-{Address}");
			Console.WriteLine($"\t-{ShortName}\n");
		}

		public List<JobVacancy> GetJobVacancies()
		{
			JobVacancy vacancy1 = new(titles[0], "developer");
			JobVacancy vacancy2 = new(titles[1], "developer2");

			vacancies.Add(vacancy1);
			vacancies.Add(vacancy2);

			return vacancies;
		}

		public void OpenJobVacancy(JobTitle title, string name)
		{
			vacancies.Add(new JobVacancy(title, name));
		}

		public bool CloseJobVacancy(JobVacancy vacancy)
		{
			int count = vacancies.Count;

			vacancies.RemoveAll(v => v.Vacancy == vacancy.Vacancy);

			int countAfter = vacancies.Count;

			if (count <= countAfter)
			{
				return false;
			}

			return true;
		}

		public int AddJobTitle(JobTitle title)
		{
			titles.Add(title);
			return titles.IndexOf(title);
		}

		public void GetAllJobTitle()
		{
			foreach (JobTitle title in titles)
			{
				Console.WriteLine(title);
			}
		}

		public JobTitle GetJobTitle(int index)
		{
			return titles[index];
		}

		public bool DeleteJobTitle(JobTitle title)
		{
			int count = titles.Count;

			titles.RemoveAll(t => t.Title == title.Title);

			int countAfter = titles.Count;

			if (count <= countAfter)
			{
				return false;
			}

			return true;
		}

		public Employee Recruit(JobVacancy vacancy, Person person)
		{
			Employee employee = new (vacancy, person);
			employees.Add(employee);
			return employee;
		}

		public bool Dismiss(string Name, Reason reason)
		{
			int count = employees.Count;

			Employee find = employees.Find(t => t.Name == Name);

			employees.Remove(find);

			int countAfter = employees.Count;

			if (count <= countAfter)
			{
				Console.WriteLine("\nEmployee not found");
				return false;
			}

			Console.WriteLine($"\nEmployee {find.Name} dismised, reason: {reason.ReasonString}");

			return true;
		}

		public List<Employee> GetEmployees()
		{
			return employees;
		}

		public List<JobTitle> GetJobTitles()
		{
			return titles;
		}

		public void PrintJobVacancies()
		{
			foreach(JobVacancy vacancy in vacancies)
			{
				Console.WriteLine("JobVacancy: " + vacancy.Vacancy);
			}
		}

		public void PrintEmployyes()
		{
			foreach(Employee emp in employees)
			{
				Console.WriteLine("Employee:");
				Console.WriteLine(emp.Name);
				Console.WriteLine(emp.Vacancy.Vacancy);
			}
		}

		public JobVacancy GetJobVacancy(int index)
		{
			return vacancies[index];
		}
	}
}
