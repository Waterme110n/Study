using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;

namespace lab8
{
    /// <summary>
    /// Логика взаимодействия для App.xaml
    /// </summary>
    public partial class App : Application
    {
        private void Application_Startup(object sender, StartupEventArgs e)
        {
            string connectionString = "Data Source=USER-PC\\SQLEXPRESS;Initial Catalog=lab8db;Integrated Security=True";
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connectionString);
            string databaseName = builder.InitialCatalog;

            using (SqlConnection connection = new SqlConnection(builder.ConnectionString))
            {
                connection.Open();

                string checkDatabaseExistsQuery = $"SELECT COUNT(*) FROM sys.databases WHERE name = '{databaseName}'";
                using (SqlCommand command = new SqlCommand(checkDatabaseExistsQuery, connection))
                {
                    int databaseCount = (int)command.ExecuteScalar();
                    if (databaseCount == 0)
                    {
                        string createDatabaseScript = $"CREATE DATABASE {databaseName}";
                        using (SqlCommand createDatabaseCommand = new SqlCommand(createDatabaseScript, connection))
                        {
                            createDatabaseCommand.ExecuteNonQuery();
                        }

                        builder.InitialCatalog = databaseName;
                        string newConnectionString = builder.ConnectionString;

                        using (SqlConnection newConnection = new SqlConnection(newConnectionString))
                        {
                            newConnection.Open();

                            string createAirplaneTableScript = @"
                        CREATE TABLE Airplane (
                            ID INT PRIMARY KEY,
                            Type NVARCHAR(50),
                            Model NVARCHAR(50),
                            Passenger_Seats INT,
                            Year_of_Manufacture INT,
                            Cargo_Capacity DECIMAL(10, 2),
                            Last_Maintenance_Date DATE
                        )";
                            using (SqlCommand createAirplaneTableCommand = new SqlCommand(createAirplaneTableScript, newConnection))
                            {
                                createAirplaneTableCommand.ExecuteNonQuery();
                            }

                            string createCrewMemberTableScript = @"
                        CREATE TABLE CrewMember (
                            ID INT PRIMARY KEY,
                            Full_Name NVARCHAR(100),
                            Position NVARCHAR(50),
                            Age INT,
                            Experience INT,
                            Photo NVARCHAR(200),
                            Airplane_ID INT,
                            FOREIGN KEY (Airplane_ID) REFERENCES Airplane(ID)
                        )";
                            using (SqlCommand createCrewMemberTableCommand = new SqlCommand(createCrewMemberTableScript, newConnection))
                            {
                                createCrewMemberTableCommand.ExecuteNonQuery();
                            }
                        }
                    }
                }
            }

        }
    }
}
