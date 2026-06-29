using System.Text.Json;
using System.IO;
using System;
using System.Linq;
using System.Collections.Generic;

namespace DAL003;

public class Repository : IRepository, IDisposable
{
    public static string JSONFileName { get; set; } = "Celebrities.json"; 
    private readonly List<Celebrity> _celebrities;
    public string BasePath { get; } 
    
    private Repository(string directoryName) 
    {
        BasePath = Path.Combine(Environment.CurrentDirectory, directoryName); 

        var jsonFilePath = Path.Combine(BasePath, JSONFileName);

        try
        {
            var jsonString = File.ReadAllText(jsonFilePath);
            var celebritiesArray = JsonSerializer.Deserialize<Celebrity[]>(jsonString, 
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            
            _celebrities = celebritiesArray?.ToList() ?? new List<Celebrity>();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Ошибка при загрузке данных: {ex.Message}");
            Console.WriteLine($"Попытка найти файл по пути: {jsonFilePath}");
            _celebrities = new List<Celebrity>();
        }
    }

    public static IRepository Create(string directoryName) 
    {
        return new Repository(directoryName);
    }
    
    public Celebrity[] getAllCelebrities() => _celebrities.ToArray();
    public Celebrity? getCelebrityById(int id) => _celebrities.FirstOrDefault(c => c.Id == id);
    public Celebrity[] getCelebritiesBySurname(string surname) => 
        _celebrities.Where(c => c.Surname.Equals(surname, StringComparison.OrdinalIgnoreCase)).ToArray();
    public string getPhotoPathById(int id) => getCelebrityById(id)?.PhotoPath ?? "";

    public void Dispose()
    {
    }
}