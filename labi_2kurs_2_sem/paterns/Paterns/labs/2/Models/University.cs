using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using _2.Models.Base;

namespace _2.Models
{
    public class University : Organization
    {
        protected List<Faculty> faculties = new();

        public University()
        {

        }

        public University(University university)
        {
            faculties = university.faculties;
        }

        // конструктор от родителя
        public University(string name, string address, Type shortName) : base(name, address, shortName)
        {

        }

        public int AddFaculty(Faculty faculty)
        {
            faculties.Add(faculty);
            return faculties.IndexOf(faculty);
        }

        public bool DeleteFaculty(string name)
        {
            if (!VerFaculty(name))
            {
                return false;
			}

			int count = faculties.Count;

			faculties.RemoveAll(d => d.Name == name);

			int countAfter = faculties.Count;

			if (count <= countAfter)
			{
				return false;
			}

			return true;
		}

        public bool UpdateFaculty(Faculty faculty)
        {
			Faculty old = faculties.Find(f => f.Name == faculty.Name);

			if (old == null)
			{
				return false;
			}

			int index = faculties.IndexOf(old);

			faculties[index] = faculty;

			return true;
		}

        private bool VerFaculty(string name)
        {
			Faculty find = faculties.FirstOrDefault(d => d.Name == name);

			if (find == null)
			{
				return false;
			}

			return true;
		}

        public List<Faculty> GetFaculties()
        {
            return faculties;
        }

    }
}
