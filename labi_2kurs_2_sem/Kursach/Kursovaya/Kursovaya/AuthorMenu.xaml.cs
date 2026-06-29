using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using Npgsql;
using static Kursovaya.CustomerMenu;

namespace Kursovaya
{
    /// <summary>
    /// Логика взаимодействия для AuthorMenu.xaml
    /// </summary>
    public partial class AuthorMenu : Window
    {

        public int UserId { get; set; }

        private NpgsqlConnection connection;

        public AuthorMenu()
        {
            InitializeComponent();
            Loaded += CustomerMenu_Loaded;

            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=author_01;Password=auth01;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();
        }

        private void CustomerMenu_Loaded(object sender, RoutedEventArgs e)
        {
            Refresh_Click(sender, e);
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
            ModalWindow imageInfoWindow = new ModalWindow(selectedImage, UserId); // Передача userId в ModalWindow

            imageInfoWindow.ShowDialog();
        }
        private void Back_click(object sender, RoutedEventArgs e)
        {
            MainWindow BackToReg = new MainWindow();
            BackToReg.Show();
            this.Close();
        }


        private void Refresh_Click(object sender, RoutedEventArgs e)
        {
            using (var command = new NpgsqlCommand("SELECT * FROM Author_images_wpf(@p_user_id)", connection))
            {
                command.Parameters.AddWithValue("p_user_id", UserId);

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

                        imageInfoList.Add(imageInfo);

                    }
                    imageListView.ItemsSource = imageInfoList;
                }
            }
        }
        private void Create_Image_Click(object sender, RoutedEventArgs e)
        {
            CreateImage createImage = new CreateImage();
            createImage.UserId = UserId;
            createImage.ShowDialog();
            Refresh_Click(sender, e);

        }

        private void Delete_Image_Click(object sender, RoutedEventArgs e)
        {
            Button button = (Button)sender;
            Grid grid = (Grid)button.Parent;

            if (grid.DataContext is ImageInfo selectedImage)
            {
                int imageId = selectedImage.ImageId;
                using (NpgsqlCommand command_reg = new NpgsqlCommand("delete_image", connection))
                {
                    command_reg.CommandType = CommandType.StoredProcedure;


                    command_reg.Parameters.AddWithValue("p_author_id", UserId);
                    command_reg.Parameters.AddWithValue("p_image_id", imageId);

                    try
                    {
                        command_reg.ExecuteNonQuery();
                        MessageBox.Show($"Your image deleted successfully!");
                        Refresh_Click(sender, e);
                    }
                    catch (NpgsqlException ex)
                    {
                        MessageBox.Show(ex.Message);
                    }
                }
            }
        }

        private void Edit_Image_Click(object sender, RoutedEventArgs e)
        {
            Button button = (Button)sender;
            Grid grid = (Grid)button.Parent;
            if (grid.DataContext is ImageInfo selectedImage)
            {
                EditImage editImage = new EditImage(selectedImage, UserId);
                editImage.UserId = UserId;
                editImage.selectedImages = selectedImage;
                editImage.ShowDialog();

                Refresh_Click(sender, e);
            }
        }
    }
}
