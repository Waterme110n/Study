using System;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace DAL003
{
    public class Repository : IRepository
    {
        public string BasePath { get; }
        private readonly string _jsonFullPath;
        private readonly Celebrity[] _celebrities;

        public Repository(string basePath, string jsonFileName)
        {
            if (string.IsNullOrWhiteSpace(jsonFileName))
                throw new ArgumentException("Имя JSON файла не может быть пустым", nameof(jsonFileName));

            BasePath = Path.GetFullPath(basePath);
            _jsonFullPath = Path.Combine(BasePath, jsonFileName);

            if (!File.Exists(_jsonFullPath))
                throw new FileNotFoundException($"JSON файл не найден: {_jsonFullPath}");

            string jsonText = File.ReadAllText(_jsonFullPath);
            _celebrities = JsonSerializer.Deserialize<Celebrity[]>(jsonText)
                ?? throw new Exception("Ошибка чтения данных из JSON");
        }

        public static IRepository Create(string basePath, string jsonFileName) => new Repository(basePath, jsonFileName);

        public Celebrity[] getAllCelebrities() => _celebrities;

        public Celebrity? getCelebrityById(int id) =>
            _celebrities.FirstOrDefault(c => c.Id == id);

        public Celebrity[] getCelebritiesBySurname(string surname) =>
            _celebrities
                .Where(c => c.Surname.Equals(surname, StringComparison.OrdinalIgnoreCase))
                .ToArray();

        public string? getPhotoPathById(int id)
        {
            var celeb = getCelebrityById(id);
            if (celeb == null) return null;

            string photoPath = Path.Combine(BasePath, celeb.PhotoPath.TrimStart('/', '\\'));
            return File.Exists(photoPath) ? photoPath : null;
        }

        public void Dispose() { }
    }
}