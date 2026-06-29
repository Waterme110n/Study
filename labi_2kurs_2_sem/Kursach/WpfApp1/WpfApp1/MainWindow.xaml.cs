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
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Data.SqlClient;
using Npgsql;

namespace WpfApp1
{
    /// <summary>
    /// Логика взаимодействия для MainWindow.xaml
    /// </summary>

    public partial class MainWindow : Window
    {
        private NpgsqlConnection connection;

        public MainWindow()
        {
            InitializeComponent();
            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=author_01;Password=auth01;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();
        }
        private void LoadStyles(ComboBox comboBox, NpgsqlConnection connection)
        {
            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM ALL_STYLES()", connection))
            {
                using (NpgsqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int index = reader.GetInt32(0);
                        string styleName = reader.GetString(1);
                        ComboBoxItem item = new ComboBoxItem();
                        item.Content = styleName;
                        item.Tag = index;
                        comboBox.Items.Add(item);
                    }
                }
            }
        }
    }


}