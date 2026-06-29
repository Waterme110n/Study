using DAL003;
using Microsoft.Extensions.FileProviders;
using Microsoft.AspNetCore.StaticFiles;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

string celebritiesPath = Path.Combine(Environment.CurrentDirectory, "Celebrities");
if (!Directory.Exists(celebritiesPath))
{
    Console.WriteLine($"Папка не найдена: {celebritiesPath}");
}
var fileProvider = new PhysicalFileProvider(celebritiesPath);

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = fileProvider,
    RequestPath = "/Photo"
});

const string downloadRequestPath = "/Celebrities/Download";

app.UseDirectoryBrowser(new DirectoryBrowserOptions
{
    FileProvider = fileProvider,
    RequestPath = downloadRequestPath
});

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = fileProvider,
    RequestPath = downloadRequestPath,
    OnPrepareResponse = ctx =>
    {
        if (!ctx.Context.Request.Path.Value!.EndsWith("/"))
        {
            ctx.Context.Response.Headers.Append("Content-Disposition", "attachment");
        }
    }
});

Repository.JSONFileName = "Celebrities.json";

using (IRepository repository = Repository.Create("Celebrities"))
{
    app.MapGet("/Celebrities", () => repository.getAllCelebrities());
    app.MapGet("/Celebrities/{id:int}", (int id) => repository.getCelebrityById(id));
    app.MapGet("/Celebrities/BySurname/{surname}", (string surname) => repository.getCelebritiesBySurname(surname));
    app.MapGet("/Celebrities/PhotoPathById/{id:int}", (int id) =>
    {
        var path = repository.getPhotoPathById(id);
        return path ?? "";
    });

    app.Run();
}
