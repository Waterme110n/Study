using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
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
using static System.Net.Mime.MediaTypeNames;
using static Kursovaya.CustomerMenu;
using static Kursovaya.Favorites;

namespace Kursovaya
{
    /// <summary>
    /// Логика взаимодействия для Favorites.xaml
    /// </summary>
    public partial class Favorites : Window
    {
 
        private int userId;
        private NpgsqlConnection connection;
        

        public Favorites(int userId)
        {
            InitializeComponent();
            this.userId = userId;
            Loaded += CustomerMenu_Loaded;

            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=customer_01;Password=cust01;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();
        }

        private void CustomerMenu_Closing(object sender, CancelEventArgs e)
        {
            if (connection != null && connection.State == ConnectionState.Open)
            {
                connection.Close();
            }
        }

        private void CustomerMenu_Loaded(object sender, RoutedEventArgs e)
        {
            LoadDataFromDatabase();
        }

        public class FavoriteItem
        {
            public string ImageName { get; set; }
            public string AuthorName { get; set; }
            public string[] ImagePaths { get; set; }
        }

        private void LoadDataFromDatabase()
        {
            using (var command = new NpgsqlCommand("SELECT * FROM get_favorites(@p_user_id)", connection))
            {
                command.Parameters.AddWithValue("p_user_id", userId);

                using (var reader = command.ExecuteReader())
                {

                    var favoritesList = new List<FavoriteItem>();

                    while (reader.Read())
                    {
                        var imageInfo = new FavoriteItem
                        {
                            ImageName = reader.GetString(0),
                            AuthorName = reader.GetString(1),
                            ImagePaths = (string[])reader[2]
                        };

                        favoritesList.Add(imageInfo);
                    }
                    imageListView.ItemsSource = favoritesList;
                }
            }
        }

        private void DeleteFromFavorites_Click(object sender, RoutedEventArgs e)
        {
            Button button = (Button)sender;
            FavoriteItem favoriteItem = button.DataContext as FavoriteItem;
            if (favoriteItem != null)
            {
                string imageName = favoriteItem.ImageName;

                using (var command = new NpgsqlCommand("SELECT * FROM ID_FROM_IMAGE_NAME(@p_image_name);", connection))
                {
                    command.Parameters.AddWithValue("p_image_name", imageName);

                    try
                    {
                        var result = command.ExecuteScalar();

                        if (result != null)
                        {
                            int imageId = Convert.ToInt32(result);
                            using (var deleteCommand = new NpgsqlCommand("delete_from_favorites", connection))
                            {
                                deleteCommand.CommandType = CommandType.StoredProcedure;
                                deleteCommand.Parameters.AddWithValue("p_user_id", userId);
                                deleteCommand.Parameters.AddWithValue("p_image_id", imageId);

                                try
                                {
                                    deleteCommand.ExecuteNonQuery();

                                    LoadDataFromDatabase();
                                }
                                catch (NpgsqlException ex)
                                {
                                    MessageBox.Show(ex.Message);
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
        }
    }
}
