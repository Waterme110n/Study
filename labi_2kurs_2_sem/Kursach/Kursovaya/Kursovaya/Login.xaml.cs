using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using Npgsql;

namespace Kursovaya
{
    /// <summary>
    /// Логика взаимодействия для Login.xaml
    /// </summary>
    public partial class Login : Window
    {

        private NpgsqlConnection connection;

        public Login()
        {
            InitializeComponent();

            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=user_reg;Password=user_reg;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();
        }

        private void RegistrationClick(object sender, RoutedEventArgs e)
        {
            MainWindow RegistrationWindow = new MainWindow();
            RegistrationWindow.Show();
            this.Close();
        }


        private void SignInClick(object sender, RoutedEventArgs e)
        {
            var securePassword = Password.SecurePassword;

            string name = username.Text.TrimEnd();
            string password = new System.Net.NetworkCredential(string.Empty, securePassword).Password;
            int userId = GetUserId(name);

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM login_function(@p_username,@p_password);", connection))
            {
                command.Parameters.AddWithValue("@p_username", name);
                command.Parameters.AddWithValue("@p_password", password);
                try
                {
                    using (NpgsqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string role = reader.GetString(0);
                            

                            if (role == "customer")
                            {
                                CustomerMenu customerWindow = new CustomerMenu();
                                customerWindow.UserId = userId;
                                customerWindow.Show();
                                this.Close();
                            }
                            else if (role == "seller")
                            {
                                SellerMenu sellerWindow = new SellerMenu();
                                sellerWindow.UserId = userId;
                                sellerWindow.Show();
                                this.Close();
                            }
                            else if (role == "author")
                            {
                                AuthorMenu authorWindow = new AuthorMenu();
                                authorWindow.UserId = userId;
                                authorWindow.Show();
                                this.Close();
                            }
                        }
                    }
                }
                catch (NpgsqlException ex)
                {
                    MessageBox.Show(ex.Message);
                }
            }
        }
        private int GetUserId(string username)
        {
            using (var command = new NpgsqlCommand("SELECT * FROM ID_FROM_USERNAME(@username);", connection))
            {
                command.Parameters.AddWithValue("username", username);
                try
                {
                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return reader.GetInt32(0);
                        }
                    }
                }
                catch (NpgsqlException ex) 
                {
                }

            }
            return -1; 
        }
    }
}
