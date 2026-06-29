namespace DAL003;

public interface IRepository:IDisposable
{
    string BasePath { get; }
    Celebrity[] getAllCelebrities();
    Celebrity? getCelebrityById(int id);
    Celebrity[] getCelebritiesBySurname(string Surname);
    string? getPhotoPathById(int id);
}