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
    /// Логика взаимодействия для AuthorChoiceCreate.xaml
    /// </summary>
    public partial class AuthorChoiceCreate : Window
    {
        public int UserId { get; set; }
        
        private NpgsqlConnection connection;

        public AuthorChoiceCreate(int userId)
        {
            UserId = userId;
            InitializeComponent();

            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=seller_01;Password=sell01;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();

            LoadAuthors(choiceAuthor, connection);
            
        }



        private void LoadAuthors(ComboBox comboBox, NpgsqlConnection connection)
        {

            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM Author_name_and_id_colab(@p_user_id)", connection))
            {
                command.Parameters.AddWithValue("p_user_id", UserId);

                try
                {
                    using (NpgsqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int index = reader.GetInt32(0);
                            string AuthorName = reader.GetString(1);
                            ComboBoxItem item = new ComboBoxItem();
                            item.Content = AuthorName;
                            item.Tag = index;
                            comboBox.Items.Add(item);
                        }
                    }
                }
                catch (NpgsqlException ex)
                {
                    MessageBox.Show(ex.Message);
                }
                
            }
        }

        private void ClosedClick(object sender, RoutedEventArgs e)
        {
            Close();
        }

        private void ChooseClick(object sender, RoutedEventArgs e)
        {
            if (choiceAuthor.SelectedItem is ComboBoxItem selectedItem)
            {
                int selectedUserId = (int)selectedItem.Tag;
                CreateImage createImage = new CreateImage();
                createImage.UserId = selectedUserId;
                Close();
                createImage.ShowDialog();
            }
            else
            {
                MessageBox.Show("Please select an author.");
            }

        }
    }
}
