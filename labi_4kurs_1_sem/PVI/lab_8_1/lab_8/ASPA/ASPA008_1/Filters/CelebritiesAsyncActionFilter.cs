using DAL_Celebrity_MSSQL;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Text.Json;

namespace ASPA008_1.Filters
{
    public class InfoAsyncActionFilter : Attribute, IAsyncActionFilter
    {
        public static readonly string Wikipedia = "WIKI";
        public static readonly string Facebook = "FACE";

        string infotype;
        public InfoAsyncActionFilter(string infotype = "")
        {
            this.infotype = infotype;
        }

            public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
            {
                IRepository? repo = context.HttpContext.RequestServices.GetService<IRepository>();
                int id = (int)(context.ActionArguments["id"] ?? -1);
                Celebrity? celebrity = repo?.GetCelebrityById(id);
                if (infotype.ToUpper().Contains(Wikipedia) && celebrity != null)
                {
                    var wikiRefs = await WikiInfoCelebrity.GetReferences(celebrity.FullName);
                    context.HttpContext.Items.Add(Wikipedia, wikiRefs);
                    Console.WriteLine($"Wikipedia references for '{celebrity.FullName}': {wikiRefs.Count} found");
                }
                if (infotype.ToUpper().Contains(Facebook) && celebrity != null)
                    context.HttpContext.Items.Add(Facebook, getFromFace(celebrity.FullName));
                await next();
            }

        string getFromWiki(string fullname)
        {
            string rc = "Info from Wiki";
            // WikiClient request to Wikipedia
            return rc;
        }

        string getFromFace(string fullname)
        {
            string rc = "Info from Face";
            // FacebookClient request to Facebook
            return rc;
        }


        public class WikiInfoCelebrity
        {
            HttpClient client;
            string wikiURItemplate = "https://en.wikipedia.org/w/api.php?action=opensearch&search=\"{0}\"&prop=info&format=json";
            Dictionary<string, string> wikiReferences { get; set; }
            string wikiURI;
            private WikiInfoCelebrity(string fullName)
            {
                this.client = new HttpClient();
                // Добавляем User-Agent, так как Wikipedia API требует его
                this.client.DefaultRequestHeaders.Add("User-Agent", "ASPA008_1/1.0 (Educational Project)");
                this.wikiReferences = new Dictionary<string, string>();
                // Экранируем имя для URL
                string encodedName = Uri.EscapeDataString(fullName);
                this.wikiURI = $"https://en.wikipedia.org/w/api.php?action=opensearch&search={encodedName}&format=json";
            }

            public static async Task<Dictionary<string, string>> GetReferences(string fullName)
            {
                WikiInfoCelebrity info = new WikiInfoCelebrity(fullName);
                try
                {
                    info.client.Timeout = TimeSpan.FromSeconds(10);
                    Console.WriteLine($"Запрос к Wikipedia API: {info.wikiURI}");
                    HttpResponseMessage message = await info.client.GetAsync(info.wikiURI);
                    Console.WriteLine($"Статус ответа Wikipedia: {message.StatusCode}");
                    if (message.IsSuccessStatusCode)
                    {
                        var jsonString = await message.Content.ReadAsStringAsync();
                        Console.WriteLine($"Получен JSON ответ, длина: {jsonString.Length}");
                        using (JsonDocument doc = JsonDocument.Parse(jsonString))
                        {
                            JsonElement root = doc.RootElement;
                            if (root.ValueKind == JsonValueKind.Array && root.GetArrayLength() >= 4)
                            {
                                JsonElement titlesElement = root[1];
                                JsonElement urlsElement = root[3];
                                
                                if (titlesElement.ValueKind == JsonValueKind.Array && 
                                    urlsElement.ValueKind == JsonValueKind.Array)
                                {
                                    int titlesCount = titlesElement.GetArrayLength();
                                    int urlsCount = urlsElement.GetArrayLength();
                                    int count = Math.Min(titlesCount, urlsCount);
                                    Console.WriteLine($"Найдено {count} статей Wikipedia");
                                    
                                    for (int i = 0; i < count; i++)
                                    {
                                        string? title = titlesElement[i].GetString();
                                        string? url = urlsElement[i].GetString();
                                        if (!string.IsNullOrWhiteSpace(title) && !string.IsNullOrWhiteSpace(url))
                                        {
                                            // СТРОГАЯ фильтрация: показываем только статьи, которые действительно про эту знаменитость
                                            string fullNameLower = fullName.ToLowerInvariant().Trim();
                                            string titleLower = title.ToLowerInvariant().Trim();
                                            
                                            // Разбиваем имя на слова
                                            string[] nameWords = fullNameLower.Split(new[] { ' ', '-' }, StringSplitOptions.RemoveEmptyEntries);
                                            string[] titleWords = titleLower.Split(new[] { ' ', '-' }, StringSplitOptions.RemoveEmptyEntries);
                                            
                                            bool isRelevant = false;
                                            
                                            // 1. Точное совпадение (с учетом вариантов написания)
                                            if (titleLower == fullNameLower)
                                            {
                                                isRelevant = true;
                                            }
                                            // 2. Название содержит полное имя или наоборот (для случаев типа "Albert Einstein" и "Einstein, Albert")
                                            else if (titleLower.Contains(fullNameLower) || fullNameLower.Contains(titleLower))
                                            {
                                                isRelevant = true;
                                            }
                                            // 3. СТРОГАЯ ПРОВЕРКА: все слова из имени должны быть в названии (или наоборот)
                                            // Это исключает случаи типа "Andrey Ershov" и "Andrey Arshavin"
                                            else if (nameWords.Length > 0 && titleWords.Length > 0)
                                            {
                                                // Проверяем, что все значимые слова (минимум 3 символа) из имени есть в названии
                                                int matchingWords = 0;
                                                int significantWords = 0;
                                                
                                                foreach (string nameWord in nameWords)
                                                {
                                                    if (nameWord.Length >= 3) // Только значимые слова
                                                    {
                                                        significantWords++;
                                                        // Проверяем точное совпадение слова или очень похожее (для вариантов написания)
                                                        bool wordFound = false;
                                                        foreach (string titleWord in titleWords)
                                                        {
                                                            if (titleWord == nameWord || 
                                                                titleWord.Contains(nameWord) || 
                                                                nameWord.Contains(titleWord) ||
                                                                AreNamesSimilar(nameWord, titleWord))
                                                            {
                                                                wordFound = true;
                                                                break;
                                                            }
                                                        }
                                                        if (wordFound) matchingWords++;
                                                    }
                                                }
                                                
                                                // Если все значимые слова совпадают - это релевантная статья
                                                if (significantWords > 0 && matchingWords == significantWords)
                                                {
                                                    isRelevant = true;
                                                }
                                                // Также проверяем обратное: все слова из названия в имени
                                                else if (titleWords.Length > 0)
                                                {
                                                    int titleMatchingWords = 0;
                                                    int titleSignificantWords = 0;
                                                    
                                                    foreach (string titleWord in titleWords)
                                                    {
                                                        if (titleWord.Length >= 3)
                                                        {
                                                            titleSignificantWords++;
                                                            foreach (string nameWord in nameWords)
                                                            {
                                                                if (nameWord == titleWord || 
                                                                    nameWord.Contains(titleWord) || 
                                                                    titleWord.Contains(nameWord) ||
                                                                    AreNamesSimilar(nameWord, titleWord))
                                                                {
                                                                    titleMatchingWords++;
                                                                    break;
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    if (titleSignificantWords > 0 && titleMatchingWords == titleSignificantWords)
                                                    {
                                                        isRelevant = true;
                                                    }
                                                }
                                            }
                                            
                                            if (isRelevant)
                                            {
                                                info.wikiReferences[title] = url;
                                                Console.WriteLine($"  ✓ Релевантная статья: {title}: {url}");
                                            }
                                            else
                                            {
                                                Console.WriteLine($"  ✗ Пропущена нерелевантная статья: {title} (для '{fullName}')");
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                Console.WriteLine($"Неожиданный формат JSON ответа: {root.ValueKind}, длина массива: {root.GetArrayLength()}");
                            }
                        }
                    }
                    else
                    {
                        Console.WriteLine($"Ошибка HTTP: {message.StatusCode} - {message.ReasonPhrase}");
                    }
                }
                catch (Exception ex)
                {
                    // Логируем ошибку, но не прерываем выполнение
                    Console.WriteLine($"Ошибка при получении данных из Wikipedia для '{fullName}': {ex.Message}");
                }
                finally
                {
                    info.client?.Dispose();
                }
                return info.wikiReferences;
            }
            
            // Проверяет, являются ли два имени вариантами написания одного и того же (например, Ershov/Yershov)
            private static bool AreNamesSimilar(string name1, string name2)
            {
                if (name1.Length < 3 || name2.Length < 3) return false;
                
                // Удаляем общие окончания для сравнения основы
                string base1 = name1.Length > 4 ? name1.Substring(0, name1.Length - 2) : name1;
                string base2 = name2.Length > 4 ? name2.Substring(0, name2.Length - 2) : name2;
                
                // Проверяем схожесть основы (минимум 70% совпадения)
                int minLen = Math.Min(base1.Length, base2.Length);
                int maxLen = Math.Max(base1.Length, base2.Length);
                if (minLen < 3) return false;
                
                int matches = 0;
                for (int i = 0; i < Math.Min(base1.Length, base2.Length); i++)
                {
                    if (base1[i] == base2[i]) matches++;
                }
                
                double similarity = (double)matches / maxLen;
                return similarity >= 0.7; // 70% схожести
            }
        }
    }

}
