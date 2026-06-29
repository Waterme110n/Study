using System;
using System.IO;
using DAL003;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;

namespace ASPA003
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            var app = builder.Build();

            string celebritiesPath = Path.GetFullPath("Celebrities");
            string photosPath = Path.Combine(celebritiesPath, "Photo");

            if (Directory.Exists(photosPath))
            {
                app.UseStaticFiles(new StaticFileOptions
                {
                    FileProvider = new PhysicalFileProvider(photosPath),
                    RequestPath = "/Photo"
                });

                app.UseStaticFiles(new StaticFileOptions
                {
                    FileProvider = new PhysicalFileProvider(photosPath),
                    RequestPath = "/Celebrities/download",
                    OnPrepareResponse = ctx =>
                    {
                        var fileName = Path.GetFileName(ctx.File.PhysicalPath);
                        ctx.Context.Response.Headers.Append("Content-Disposition", $"attachment; filename=\"{fileName}\"");
                    }
                });

                app.UseDirectoryBrowser(new DirectoryBrowserOptions
                {
                    FileProvider = new PhysicalFileProvider(photosPath),
                    RequestPath = "/Celebrities/download"
                });
            }

            using (IRepository repository = Repository.Create("Celebrities", "Celebrities.json"))
            {
                app.MapGet("/Celebrities", () => repository.getAllCelebrities());

                app.MapGet("/Celebrities/{id:int}", (int id) => repository.getCelebrityById(id));

                app.MapGet("/Celebrities/BySurname/{surname}",
                    (string surname) => repository.getCelebritiesBySurname(surname));

                app.MapGet("/Celebrities/PhotoPathById/{id:int}", (int id) =>
                {
                    var photoPath = repository.getPhotoPathById(id);
                    if (photoPath == null) return "null";

                    string fileName = Path.GetFileName(photoPath);
                    return $"/Photo/{fileName}";
                });
            }

            app.Run();
        }
    }
}