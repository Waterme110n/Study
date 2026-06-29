using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Npgsql;
using System.Security;
using System.Runtime.InteropServices;

namespace Kursovaya
{

    /// <summary>
    /// Логика взаимодействия для MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private NpgsqlConnection connection;
        public string SelectedItem { get; set; }

        public MainWindow()
        {
            InitializeComponent();

            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=user_reg;Password=user_reg;";
            connection = new NpgsqlConnection(connectionString);

            connection.Open();
        }

        public ObservableCollection<string> ComboBoxItems { get; set; } = new ObservableCollection<string>
        {
            "customer",
            "seller",
            "author"
        };

        


        private bool ValidateEmail(string email)
        {
            // Регулярное выражение для проверки формата email
            string emailPattern = @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";

            // Проверка соответствия email формату
            return Regex.IsMatch(email, emailPattern);
        }

        private string ValidatePassword(string password)
        {
            // Проверка длины пароля
            if (password.Length < 8)
            {
                return "Password should contain at least 8 characters.";
            }

            // Проверка наличия букв русского и английского алфавитов
            if (!Regex.IsMatch(password, @"[\p{IsCyrillic}\p{IsBasicLatin}]+"))
            {
                return "Password should contain letters from Russian and English alphabets.";
            }

            // Проверка наличия цифр
            if (!Regex.IsMatch(password, @"\d+"))
            {
                return "Password should contain numbers.";
            }

            // Проверка отсутствия специальных символов
            if (Regex.IsMatch(password, @"[^a-zA-Zа-яА-Я0-9]"))
            {
                return "Password should not contain special characters.";
            }

            return "Password is valid.";
        }

        private void RegisterClick(object sender, RoutedEventArgs e)
        {
            var securePassword = Password.SecurePassword;

            string name = username.Text.TrimEnd();
            string password = new System.Net.NetworkCredential(string.Empty, securePassword).Password;
            string fstN = Name.Text.TrimEnd();
            string secN = Second.Text.TrimEnd(); 
            string email = Email.Text.TrimEnd();
            string selectedRole = (role.SelectedItem as ComboBoxItem)?.Content as string;

            if (!ValidateEmail(email))
            {
                MessageBox.Show("Некорректный формат email.");
                return;
            }
            if (ValidatePassword(password) != "Password is valid.")
            {
                MessageBox.Show(ValidatePassword(password));
                return;
            }

            using (NpgsqlCommand command_reg = new NpgsqlCommand("registration_procedure", connection))
            {
                command_reg.CommandType = CommandType.StoredProcedure;

                command_reg.Parameters.AddWithValue("p_username", name);
                command_reg.Parameters.AddWithValue("p_password", password);
                command_reg.Parameters.AddWithValue("p_role", selectedRole);

                try
                {
                    command_reg.ExecuteNonQuery();

                    int userId = GetUserId(name); // Получение userId после регистрации

                    using (NpgsqlCommand command_add_info = new NpgsqlCommand("add_information_procedure", connection))
                    {
                        command_add_info.CommandType = CommandType.StoredProcedure;

                        command_add_info.Parameters.AddWithValue("p_username", name);
                        command_add_info.Parameters.AddWithValue("p_fst_name", fstN);
                        command_add_info.Parameters.AddWithValue("p_sec_name", secN);
                        command_add_info.Parameters.AddWithValue("p_mail", email);

                        try { command_add_info.ExecuteNonQuery(); }
                        catch (NpgsqlException ex) { MessageBox.Show(ex.Message); }
                    }

                    if (selectedRole == "customer")
                    {
                        CustomerMenu customerWindow = new CustomerMenu();
                        customerWindow.UserId = userId; // Передача userId в экземпляр CustomerMenu
                        customerWindow.Show();
                        this.Close();
                    }
                    else if (selectedRole == "seller")
                    {
                        SellerMenu sellerWindow = new SellerMenu();
                        sellerWindow.UserId = userId;
                        sellerWindow.Show();
                        this.Close();
                    }
                    else if (selectedRole == "author")
                    {
                        AuthorMenu authorWindow = new AuthorMenu();
                        authorWindow.UserId = userId;
                        authorWindow.Show();
                        this.Close();
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
               

                using (var reader = command.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return reader.GetInt32(0);
                    }
                }
            }

            return -1; // Если не удалось найти идентификатор пользователя
        }

        private void SignInClick(object sender, RoutedEventArgs e)
        {
                Login LoginWindow = new Login();
                LoginWindow.Show();
                this.Close();
        }
    }
}
