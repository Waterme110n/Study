using _2.Models;
using _2.Models.Base;

namespace _2
{
	public class Program
	{
		static void Main()
		{
			University university = new("БГТУ", "свердлова", typeof(University));
			University university2 = new("БГУ", "...", typeof(University));


			Faculty faculty = new("ФИТ", "4 копрпус", typeof(Faculty));
			Faculty faculty2 = new("ИСИТ", "4 копрпус", typeof(Faculty));

			university.AddFaculty(faculty);
			university.AddFaculty(faculty2);

			var list = university.GetFaculties();

			foreach (var item in list)
			{
				Console.WriteLine($"{item.Name}, {item.Address}");
			}

			university.PrintInfo();

			Console.WriteLine(university.DeleteFaculty("ФИТ"));
			Console.WriteLine(university.DeleteFaculty("ФИТn"));

			var list2 = university.GetFaculties();

			foreach (var item in list2)
			{
				Console.WriteLine(item.Name);
			}

			Console.WriteLine();

			university.AddJobTitle(new JobTitle("разработчик"));
			university.AddJobTitle(new JobTitle("разработчик2"));

			var vacansies = university.GetJobVacancies();

			foreach (var item in vacansies)
			{
				Console.WriteLine("vacancy:");
				Console.WriteLine(item.Title);
				Console.WriteLine(item.Vacancy);
			}

			Console.WriteLine();

			faculty.AddDepartment(new Department("department"));
			faculty.AddDepartment(new Department("department2"));

			faculty.PrintDepartments();

			Console.WriteLine("\n----------------------------\n")
				;

			university.AddJobTitle(new JobTitle("hr"));
			university.OpenJobVacancy(university.GetJobTitle(0), "hr");

		    university.Recruit(
				university.GetJobVacancy(2),
				new Person("nikita")
			);

			university.PrintEmployyes();

			university.Dismiss("nikitaaa", new Reason("сторчался"));
			university.Dismiss("nikita", new Reason("сторчался"));

			university.PrintEmployyes();
		}
	}
}