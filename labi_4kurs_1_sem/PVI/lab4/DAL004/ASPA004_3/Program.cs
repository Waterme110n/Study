using DAL004;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.Extensions.Hosting;
using System;

namespace ASPA004_3
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            var app = builder.Build();


            string jsonFileName = "Celebrities.json";
            string basePath = "Celebrities";

            using (Repository repository = (Repository)Repository.Create(basePath, jsonFileName))
            {

                app.UseExceptionHandler("/Celebrities/Error");

                app.MapGet("/Celebrities", () => repository.getAllCelebrities());

                app.MapGet("/Celebrities/{id:int}", (int id) =>
                {
                    Celebrity? celebrity = repository.getCelebrityById(id);
                    if (celebrity == null)
                        throw new FoundByIdException($"Celebrity Id = {id}");
                    return celebrity;
                });

                app.MapPost("/Celebrities", (Celebrity celebrity) =>
                {
                    int? id = repository.addCelebrity(celebrity);
                    if (id == null)
                        throw new AddCelebrityException("/Celebrities error, id == null");

                    if (repository.SaveChanges() <= 0)
                        throw new SaveException("/Celebrities error, SaveChanges() <= 0");

                    return new Celebrity((int)id, celebrity.Firstname, celebrity.Surname, celebrity.PhotoPath);
                });

                app.MapDelete("/Celebrities/{id:int}", (int id) =>
                {
                    bool deleted = repository.delCelebrityById(id);
                    if (!deleted)
                        throw new DeleteCelebrityException($"Celebrity with Id = {id} not found or not deleted");

                    if (repository.SaveChanges() <= 0)
                        throw new SaveException($"/Celebrities DELETE error, SaveChanges() <= 0");

                    return Results.Ok(new { message = $"Celebrity Id = {id} deleted" });
                });


                app.MapPut("/Celebrities/{id:int}", (int id, Celebrity celebrity) =>
                {
                    int? newId = repository.updCelebrityById(id, celebrity);

                    if (newId == null)
                        throw new UpdateCelebrityException($"Celebrity with Id = {id} not found or update failed");

                    if (repository.SaveChanges() <= 0)
                        throw new SaveException($"/Celebrities PUT error, SaveChanges() <= 0");

                    return Results.Ok(new
                    {
                        message = $"Celebrity Id = {id} updated",
                        updated = new Celebrity((int)newId, celebrity.Firstname, celebrity.Surname, celebrity.PhotoPath)
                    });
                });


                app.MapFallback((HttpContext ctx) =>
                    Results.NotFound(new { error = $"Path {ctx.Request.Path} not supported" })
                );


                app.Map("/Celebrities/Error", (HttpContext ctx) =>
                {
                    Exception? ex = ctx.Features.Get<IExceptionHandlerFeature>()?.Error;
                    IResult rc = Results.Problem(
                        detail: "Unknown error",
                        instance: app.Environment.EnvironmentName,
                        title: "ASPA004_3",
                        statusCode: 500
                    );

                    if (ex != null)
                    {
                        rc = Results.Problem(
                            title: $"ASPA004_3/{ex.GetType().Name}",
                            detail: $"{ex.Message}\nMethod: {ctx.Request.Method}\n",
                            instance: app.Environment.EnvironmentName,
                            statusCode: ex switch
                            {
                                FoundByIdException => 404,
                                DeleteCelebrityException => 404,
                                UpdateCelebrityException => 404,
                                BadHttpRequestException => 400,
                                AddCelebrityException or SaveException => 500,
                                _ => 500
                            }
                        );
                    }

                    return rc;
                });

                app.Run();
            }
        }
    }


    public class FoundByIdException : Exception
    {
        public FoundByIdException(string message)
            : base($"Found by Id: {message}") { }
    }

    public class SaveException : Exception
    {
        public SaveException(string message)
            : base($"SaveChanges error: {message}") { }
    }

    public class AddCelebrityException : Exception
    {
        public AddCelebrityException(string message)
            : base($"Add Celebrity error: {message}") { }
    }

    public class DeleteCelebrityException : Exception
    {
        public DeleteCelebrityException(string message)
            : base($"Delete Celebrity error: {message}") { }
    }

    public class UpdateCelebrityException : Exception
    {
        public UpdateCelebrityException(string message)
            : base($"Update Celebrity error: {message}") { }
    }
}
