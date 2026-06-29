using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using _2.Abstraction;
using _2.Models.Base;

namespace _2.Models
{
	public class Faculty : Organization
	{
		protected List<Department> departments = new List<Department>();

		public Faculty()
		{

		}

		public Faculty(Faculty faculty)
		{
			departments = faculty.departments;
		}

		public Faculty(string name, string address, Type shortName) : base(name, address, shortName)
		{
		}

		public int AddDepartment(Department department)
		{
			departments.Add(department);
			return departments.IndexOf(department);
		}

		public bool DeleteDepartment(string name)
		{
			int count = departments.Count;

			departments.RemoveAll(d => d.Name == name);

			int countAfter = departments.Count;

			if (count <= countAfter)
			{
				return false;
			}

			return true;
		}

		public bool UpdateDepartment(Department department)
		{
			Department old = departments.Find(d => d.Name == department.Name);

			if (old == null)
			{
				return false;
			}

			int index = departments.IndexOf(old);

			departments[index] = department;

			return true;
		}

		private bool VerifyDepartment(string department)
		{
			Department find = departments.FirstOrDefault(d => d.Name == department);

			if (find == null)
			{
				return false;
			}

			return true;
		}

		public void PrintDepartments()
		{
			foreach (Department department in departments)
			{
				Console.WriteLine(department.Name);
			}
		}
	}
}
