using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL004
{
    public interface IRepository : IDisposable
    {
        string BasePath { get; }                      // полный путь к папке с JSON и фото
        Celebrity[] getAllCelebrities();               // получить всех знаменитостей
        Celebrity? getCelebrityById(int id);           // получить по Id
        Celebrity[] getCelebritiesBySurname(string surname); // получить по фамилии
        string? getPhotoPathById(int id);              // получить путь к фото
        int? addCelebrity(Celebrity celebrity);        // добавить знаменитость
        bool delCelebrityById(int id);                 // удалить знаменитость по Id
        int? updCelebrityById(int id, Celebrity celebrity); // обновить знаменитость по Id
        int SaveChanges();                             // сохранить изменения в JSON
    }
}
