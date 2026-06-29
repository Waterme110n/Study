using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace DAL004
{
    public class Repository : IRepository
    {
        public string BasePath { get; }
        private readonly string _jsonFullPath;
        private List<Celebrity> _celebrities;

        public Repository(string basePath, string jsonFileName)
        {
            if (string.IsNullOrWhiteSpace(jsonFileName))
                throw new ArgumentException("Имя JSON файла не может быть пустым", nameof(jsonFileName));

            BasePath = Path.GetFullPath(basePath);
            _jsonFullPath = Path.Combine(BasePath, jsonFileName);

            if (!File.Exists(_jsonFullPath))
                throw new FileNotFoundException($"JSON файл не найден: {_jsonFullPath}");

            string jsonText = File.ReadAllText(_jsonFullPath);
            _celebrities = JsonSerializer.Deserialize<List<Celebrity>>(jsonText)
                ?? throw new Exception("Ошибка чтения данных из JSON");
        }

        public static IRepository Create(string basePath, string jsonFileName) =>
            new Repository(basePath, jsonFileName);
        private void ReloadFromFile()
        {
            string jsonText = File.ReadAllText(_jsonFullPath);

            _celebrities = JsonSerializer.Deserialize<List<Celebrity>>(jsonText)
                ?? throw new Exception("Ошибка чтения данных из JSON");
        }

        public Celebrity[] getAllCelebrities()
        {
            ReloadFromFile();
            return _celebrities.ToArray();
        }

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

        public int? addCelebrity(Celebrity celebrity)
        {
            if (celebrity == null)
                return null;

            int newId = _celebrities.Count > 0 ? _celebrities.Max(c => c.Id) + 1 : 1;
            var newCelebrity = celebrity with { Id = newId };

            _celebrities.Add(newCelebrity);
            return newId;
        }

        public bool delCelebrityById(int id)
        {
            var celeb = getCelebrityById(id);
            if (celeb == null) return false;

            _celebrities.Remove(celeb);
            return true;
        }

        public int? updCelebrityById(int id, Celebrity celebrity)
        {
            var existing = getCelebrityById(id);
            if (existing == null) return null;

            _celebrities.Remove(existing);
            _celebrities.Add(celebrity with { Id = id });

            return id;
        }

        public int SaveChanges()
        {
            if (!File.Exists(_jsonFullPath))
                throw new FileNotFoundException(null, _jsonFullPath);

            string jsonText = JsonSerializer.Serialize(_celebrities, new JsonSerializerOptions
            {
                WriteIndented = true
            });

            File.WriteAllText(_jsonFullPath, jsonText);
            return _celebrities.Count;
        }

        public void Dispose() { }

    }
}
