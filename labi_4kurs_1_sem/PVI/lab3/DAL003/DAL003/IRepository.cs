using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL003
{
    public interface IRepository : IDisposable
    {
        string BasePath { get; } 
        Celebrity[] getAllCelebrities(); 
        Celebrity? getCelebrityById(int id);
        Celebrity[] getCelebritiesBySurname(string surname);
        string? getPhotoPathById(int id);
    }
}
