using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Globalization;
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
    /// Логика взаимодействия для CustomerMenu.xaml
    /// </summary>  

    
    public partial class CustomerMenu : Window
    {
        public int UserId { get; set; }

        private NpgsqlConnection connection;

        public CustomerMenu()
        {
            InitializeComponent();
            Loaded += CustomerMenu_Loaded;


            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=customer_01;Password=cust01;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();


        }

        private void CustomerMenu_Loaded(object sender, RoutedEventArgs e)
        {
            Refresh_Click(sender, e);
        }

        public class ImageInfo
        {
            public int ImageId { get; set; }
            public string ImageName { get; set; }
            public string AuthorName { get; set; }
            public string Descriptions { get; set; }
            public int DateOfCreation { get; set; }
            public string StyleName { get; set; }
            public string SizeValue { get; set; }
            public string FrameType { get; set; }
            public string MaterialName { get; set; }
            public string[] ImagePaths { get; set; }
            public bool IsFavorite { get; set; }
        }

        private void GridClicked(object sender, MouseButtonEventArgs e)
        {
            // Получаем элемент, на который был выполнен щелчок
            var clickedGrid = sender as Grid;

            // Получаем связанный объект ImageInfo из контекста данных элемента Grid
            if (clickedGrid.DataContext is ImageInfo selectedImage)
            {
                // Открываем окно с информацией о картинке, используя selectedImage
                OpenImageInfoWindow(selectedImage);
            }
        }

        private void OpenImageInfoWindow(ImageInfo selectedImage)
        {
            ModalWindow imageInfoWindow = new ModalWindow(selectedImage,UserId); // Передача userId в ModalWindow
            imageInfoWindow.ShowDialog();
        }

        private void OpenFavoritesWindow_Click(object sender, RoutedEventArgs e)
        {
            Favorites favoritesWindow = new Favorites(UserId);
            favoritesWindow.ShowDialog();
            Refresh_Click(sender,e);
        }
        private void Purchases_Click(object sender, RoutedEventArgs e)
        {
            Purchases purcharesWindow = new Purchases(UserId);
            purcharesWindow.ShowDialog();
            Refresh_Click(sender, e);
        }
        private void Back_click(object sender, RoutedEventArgs e)
        {
            MainWindow BackToReg = new MainWindow();
            BackToReg.Show();
            this.Close();
        }

        private void Refresh_Click(object sender, RoutedEventArgs e)
        {
            string searchValue = searchTextBox.Text;

            using (var command = new NpgsqlCommand("select * from sort_images_for_wpf(@Style_id_vvod,@Size_id_vvod,@Frame_id_vvod,@Materials_id_vvod,@SearchValue)", connection))
            {
                command.Parameters.AddWithValue("Style_id_vvod", stylesIds.Count > 0 ? stylesIds.ToArray() : (object)DBNull.Value);
                command.Parameters.AddWithValue("Size_id_vvod", SizesIds.Count > 0 ? SizesIds.ToArray() : (object)DBNull.Value);
                command.Parameters.AddWithValue("Frame_id_vvod", FramesIds.Count > 0 ? FramesIds.ToArray() : (object)DBNull.Value);
                command.Parameters.AddWithValue("Materials_id_vvod", MaterialsIds.Count > 0 ? MaterialsIds.ToArray() : (object)DBNull.Value);
                command.Parameters.AddWithValue("SearchValue", searchValue);

                using (var reader = command.ExecuteReader())
                {
                    var imageInfoList = new List<ImageInfo>();

                    while (reader.Read())
                    {
                        var imageInfo = new ImageInfo
                        {
                            ImageId = reader.GetInt32(0),
                            ImageName = reader.GetString(1),
                            AuthorName = reader.GetString(2),
                            Descriptions = reader.GetString(3),
                            DateOfCreation = reader.GetInt32(4),
                            StyleName = reader.GetString(5),
                            SizeValue = reader.GetString(6),
                            FrameType = reader.GetString(7),
                            MaterialName = reader.GetString(8),
                            ImagePaths = (string[])reader[9]
                        };

                        int imageId = imageInfo.ImageId;
                        bool isFavorite = CheckIfFavoriteExistsForUser(imageId, UserId);
                        imageInfo.IsFavorite = isFavorite;
                        imageInfoList.Add(imageInfo);

                    }
                    imageListView.ItemsSource = imageInfoList;
                }
            }
        }

        private bool CheckIfFavoriteExistsForUser(int imageId, int userId)
        {
            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=postgres;Password=PashA2005;";
            using (var connection = new NpgsqlConnection(connectionString))
            {
                connection.Open();

                using (var command = new NpgsqlCommand("SELECT * FROM IsFavorite(@p_Image_id,@p_user_id)", connection))
                {
                    command.Parameters.AddWithValue("p_Image_id", imageId);
                    command.Parameters.AddWithValue("p_user_id", userId);

                    object result = command.ExecuteScalar();
                    int count = result != null ? Convert.ToInt32(result) : 0;
                    return count > 0;
                }
            }
        }

        private List<int> stylesIds = new List<int>();

        private void CheckBox_styles_Checked(object sender, RoutedEventArgs e)
        {
            CheckBox checkBox = (CheckBox)sender;
            object tagValue = checkBox.Tag;
            int styleId = Convert.ToInt32(tagValue);
            stylesIds.Add(styleId);
        }

        private void CheckBox_styles_Unchecked(object sender, RoutedEventArgs e)
        {
            CheckBox checkBox = (CheckBox)sender;
            object tagValue = checkBox.Tag;
            int styleId = Convert.ToInt32(tagValue);
            stylesIds.Remove(styleId);
        }

        private List<int> SizesIds = new List<int>();

        private void CheckBox_Sizes_Checked(object sender, RoutedEventArgs e)
        {
            CheckBox checkBox = (CheckBox)sender;
            object tagValue = checkBox.Tag;
            int styleId = Convert.ToInt32(tagValue);
            SizesIds.Add(styleId);
        }

        private void CheckBox_Sizes_Unchecked(object sender, RoutedEventArgs e)
        {
            CheckBox checkBox = (CheckBox)sender;
            object tagValue = checkBox.Tag;
            int styleId = Convert.ToInt32(tagValue);
            SizesIds.Remove(styleId);
        }

        private List<int> FramesIds = new List<int>();

        private void CheckBox_Frames_Checked(object sender, RoutedEventArgs e)
        {
            CheckBox checkBox = (CheckBox)sender;
            object tagValue = checkBox.Tag;
            int styleId = Convert.ToInt32(tagValue);
            FramesIds.Add(styleId);
        }

        private void CheckBox_Frames_Unchecked(object sender, RoutedEventArgs e)
        {
            CheckBox checkBox = (CheckBox)sender;
            object tagValue = checkBox.Tag;
            int styleId = Convert.ToInt32(tagValue);
            FramesIds.Remove(styleId);
        }

        private List<int> MaterialsIds = new List<int>();

        private void CheckBox_Mat_Checked(object sender, RoutedEventArgs e)
        {
            CheckBox checkBox = (CheckBox)sender;
            object tagValue = checkBox.Tag;
            int styleId = Convert.ToInt32(tagValue);
            MaterialsIds.Add(styleId);
        }

        private void CheckBox_Mat_Unchecked(object sender, RoutedEventArgs e)
        {
            CheckBox checkBox = (CheckBox)sender;
            object tagValue = checkBox.Tag;
            int styleId = Convert.ToInt32(tagValue);
            MaterialsIds.Remove(styleId);
        }

        private void Favorite_click(object sender, RoutedEventArgs e)
        {
            Button button = (Button)sender;
            Grid grid = (Grid)button.Parent;
            Image starImage = (Image)grid.FindName("starImage");
            string currentImagePath = starImage.Source.ToString();
            currentImagePath = currentImagePath.Substring(8);
            string addedImagePath = "C:/labi_2kurs_2_sem/Kursach/Kursovaya/Kursovaya/images/star_clicked.png";
            string deletedImagePath = "C:/labi_2kurs_2_sem/Kursach/Kursovaya/Kursovaya/images/star.png";
            if (currentImagePath == addedImagePath)
            {
                starImage.Source = new BitmapImage(new Uri(deletedImagePath));
                if (grid.DataContext is ImageInfo selectedImage)
                {
                    int imageId = selectedImage.ImageId;
                    using (var command = new NpgsqlCommand("delete_from_favorites", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("p_user_id", UserId);
                        command.Parameters.AddWithValue("p_image_id", imageId);

                        try
                        {
                            command.ExecuteNonQuery();
                        }
                        catch (NpgsqlException ex)
                        {
                            MessageBox.Show(ex.Message);
                        }
                    }

                }

            }
            else if (currentImagePath == deletedImagePath) 
            {
                starImage.Source = new BitmapImage(new Uri(addedImagePath));
                if (grid.DataContext is ImageInfo selectedImage)
                {
                    int imageId = selectedImage.ImageId;
                    using (var command = new NpgsqlCommand("add_to_favorites", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("p_user_id", UserId);
                        command.Parameters.AddWithValue("p_image_id", imageId);

                        try
                        {
                            command.ExecuteNonQuery();
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
}
