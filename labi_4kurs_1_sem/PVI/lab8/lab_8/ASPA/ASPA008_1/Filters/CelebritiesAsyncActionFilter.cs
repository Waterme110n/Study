using DAL_Celebrity_MSSQL;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Net.Http;
using System.Text.Json;
using System.Web;

namespace ASPA008_1.Filters
{
    public class InfoAsyncActionFilter : Attribute, IAsyncActionFilter
    {
        public static readonly string Wikipedia = "WIKI";

        private readonly string infotype;

        public InfoAsyncActionFilter(string infotype = "")
        {
            this.infotype = infotype?.Trim() ?? "";
        }

        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            Console.WriteLine($"Filter called! infotype = '{infotype}'");

            var repo = context.HttpContext.RequestServices.GetService<IRepository>();
            if (repo == null)
            {
                Console.WriteLine("Repository not found in DI container");
                await next();
                return;
            }

            if (!context.ActionArguments.TryGetValue("id", out var idObj) || idObj is not int id || id <= 0)
            {
                Console.WriteLine("Invalid or missing id parameter");
                await next();
                return;
            }

            var celebrity = repo.GetCelebrityById(id);
            if (celebrity == null)
            {
                Console.WriteLine($"Celebrity with id {id} not found");
                await next();
                return;
            }

            var requestedTypes = infotype.ToUpperInvariant()
                .Split(new[] { ',', ';', ' ' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(t => t.Trim())
                .ToHashSet();

            if (requestedTypes.Contains(Wikipedia))
            {
                Console.WriteLine($"Wikipedia requested for: {celebrity.FullName}");
                try
                {
                    var wikiData = await WikiInfoCelebrity.GetReferences(celebrity.FullName);
                    Console.WriteLine($"Wiki data count: {wikiData.Count}");
                    context.HttpContext.Items[Wikipedia] = wikiData;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error fetching Wikipedia data: {ex.Message}");
                }
            }


            await next();
        }
    }

    public static class WikiInfoCelebrity
    {
        private static readonly HttpClient _httpClient = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(12)
        };

        static WikiInfoCelebrity() 
        {
            _httpClient = new HttpClient
            {
                Timeout = TimeSpan.FromSeconds(15)
            };


            _httpClient.DefaultRequestHeaders.UserAgent.ParseAdd(
                "CelebrityInfoApp/1.0 " +
                "(https://github.com/Waterme110n/testHTML; " +              
                "pavelasadchy@gmail.com) " +                                  
                "ASP.NET-Core/8.0 " +                                        
                "(Educational project for university)"                       
            );
        }

        public static async Task<Dictionary<string, string>> GetReferences(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                return new();

            var references = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

            string requestUrl = $"https://en.wikipedia.org/w/api.php?" +
                               $"action=opensearch" +
                               $"&search={Uri.EscapeDataString(fullName.Trim())}" +
                               $"&limit=8" +
                               $"&namespace=0" +
                               $"&format=json";

            Console.WriteLine($"Wikipedia API URL: {requestUrl}");

            try
            {
                using var response = await _httpClient.GetAsync(requestUrl);

                if (!response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"Wikipedia HTTP error: {response.StatusCode} - {await response.Content.ReadAsStringAsync()}");
                    return references;
                }

                var json = await response.Content.ReadAsStringAsync();

                var doc = JsonDocument.Parse(json);
                var root = doc.RootElement;

                if (root.ValueKind == JsonValueKind.Array && root.GetArrayLength() >= 4)
                {
                    var titles = root[1];
                    var urls = root[3];

                    for (int i = 0; i < titles.GetArrayLength(); i++)
                    {
                        var title = titles[i].GetString();
                        var url = urls[i].GetString();

                        if (!string.IsNullOrEmpty(title) && !string.IsNullOrEmpty(url))
                        {
                            references[title] = url;
                        }
                    }
                }

                Console.WriteLine($"Wiki references count: {references.Count}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching Wikipedia: {ex.Message}");
            }

            return references;
        }
    }
}