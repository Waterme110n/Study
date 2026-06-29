using Lab_11.Model;
using Lab_11.View;
using Lab_11.ViewModel;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;

namespace Lab_11
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {

        List<Consultation> consultations = new();
        private void OnStartup(object sender, StartupEventArgs e)
        {
            connectToDB();
            MainWindow window = new();
            MainViewModel viewModel = new(consultations);
            window.DataContext = viewModel;
            window.Show();

        }

        private void connectToDB()
        {
                string sql = "select * from consultation;";
                SqlConnection connection = null;
                DataTable dataTable = new DataTable();
                string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            Consultation cons;

            using (connection = new SqlConnection(connectionString))
            {
                connection.Open();

                SqlCommand command = new SqlCommand(sql, connection);
                SqlDataReader reader = command.ExecuteReader();

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        int id = reader.GetInt32(0);
                        string name = reader.GetString(1);
                        string subject = reader.GetString(2);
                        string time = reader.GetString(3);
                        DateOnly date = DateOnly.FromDateTime(reader.GetDateTime(4));
                        bool isFree = reader.GetBoolean(5);
                        cons = new(name, subject, time, date, isFree);
                        consultations.Add(cons);
                    }
                }

                reader.CloseAsync();
            }
        }

        private void OnWindowClosing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            SaveToDB();
        }

        private void SaveToDB()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                SqlCommand deleteCommand = new SqlCommand("DELETE FROM consultation", connection);
                deleteCommand.ExecuteNonQuery();

                SqlCommand insertCommand = new SqlCommand("INSERT INTO consultation (Name, Subject, Time, Date, IsFree) VALUES (@Name, @Subject, @Time, @Date, @IsFree)", connection);
                insertCommand.Parameters.Add("@Name", SqlDbType.VarChar);
                insertCommand.Parameters.Add("@Subject", SqlDbType.VarChar);
                insertCommand.Parameters.Add("@Time", SqlDbType.VarChar);
                insertCommand.Parameters.Add("@Date", SqlDbType.Date);
                insertCommand.Parameters.Add("@IsFree", SqlDbType.Bit);

                foreach (Consultation consultation in consultations)
                {
                    insertCommand.Parameters["@Name"].Value = consultation.Name;
                    insertCommand.Parameters["@Subject"].Value = consultation.Subject;
                    insertCommand.Parameters["@Time"].Value = consultation.time;
                    insertCommand.Parameters["@IsFree"].Value = consultation.isFree;

                    insertCommand.ExecuteNonQuery();
                }
            }
        }
    }
}
