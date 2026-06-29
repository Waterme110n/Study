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
using static Kursovaya.CustomerMenu;
using static Kursovaya.SellerMenu;

namespace Kursovaya
{
    /// <summary>
    /// Логика взаимодействия для SellerMenu.xaml
    /// </summary>
    public partial class SellerMenu : Window
    {
        public int UserId { get; set; }

        private NpgsqlConnection connection;

        public SellerMenu()
        {
            InitializeComponent();
            Loaded += CustomerMenu_Loaded;

            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=seller_01;Password=sell01;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();
        }


        private void CustomerMenu_Loaded(object sender, RoutedEventArgs e)
        {
            Refresh_Click(sender, e);
        }

        public class Cooperations
        {
            public int CooperationId { get; set; }
            public int SellerId { get; set; }
            public int AuthorId { get; set; }

        }


        private void Refresh_Click(object sender, RoutedEventArgs e)
        {
            var CooperationsList = new List<Cooperations>();

            using (var command = new NpgsqlCommand("SELECT * FROM Seller_colab_wpf(@UserId)", connection))
            {
                command.Parameters.AddWithValue("@UserId", UserId);
                try
                {
                    using (NpgsqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var Cooperations = new Cooperations
                            {
                                CooperationId = reader.GetInt32(0),
                                SellerId = reader.GetInt32(1),
                                AuthorId = reader.GetInt32(2)
                            };
                            CooperationsList.Add(Cooperations);
                        }
                    }
                }
                catch (NpgsqlException ex)
                {
                    MessageBox.Show(ex.Message);
                }

            }
            var imageInfoList = new List<ImageInfo>();
            foreach (var cooperation in CooperationsList)
            {
                using (var command2 = new NpgsqlCommand("SELECT * FROM Author_images_wpf(@p_user_id)", connection))
                {
                    command2.Parameters.AddWithValue("@p_user_id", cooperation.AuthorId);

                    using (var reader2 = command2.ExecuteReader())
                    {

                        while (reader2.Read())
                        {
                            var imageInfo = new ImageInfo
                            {
                                ImageId = reader2.GetInt32(0),
                                ImageName = reader2.GetString(1),
                                AuthorName = reader2.GetString(2),
                                Descriptions = reader2.GetString(3),
                                DateOfCreation = reader2.GetInt32(4),
                                StyleName = reader2.GetString(5),
                                SizeValue = reader2.GetString(6),
                                FrameType = reader2.GetString(7),
                                MaterialName = reader2.GetString(8),
                                ImagePaths = (string[])reader2[9]
                            };

                            imageInfoList.Add(imageInfo);
                        }
                    }
                }
            }
            imageListView.ItemsSource = imageInfoList;
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
            ModalWindow imageInfoWindow = new ModalWindow(selectedImage, UserId);
            imageInfoWindow.ShowDialog();
        }

        private void Back_click(object sender, RoutedEventArgs e)
        {
            MainWindow BackToReg = new MainWindow();
            BackToReg.Show();
            this.Close();
        }

        private void Create_Image_Click(object sender, RoutedEventArgs e)
        {
            AuthorChoiceCreate authorChoice = new AuthorChoiceCreate(UserId);
            authorChoice.ShowDialog();
            Refresh_Click(sender, e);

        }

        private void Delete_Image_Click(object sender, RoutedEventArgs e)
        {
            Button button = (Button)sender;
            Grid grid = (Grid)button.Parent;

            if (grid.DataContext is ImageInfo selectedImage)
            {
                int imageId = selectedImage.ImageId;
                string AuthorName = selectedImage.AuthorName;
                int authorId = 0;
                using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM ID_FROM_AUT_NAME(@p_fst_name_aut);", connection))
                {
                    command.Parameters.AddWithValue("p_fst_name_aut", AuthorName);
                    authorId = (int)command.ExecuteScalar();
                }

                using (NpgsqlCommand command_reg = new NpgsqlCommand("delete_image", connection))
                {
                    command_reg.CommandType = CommandType.StoredProcedure;


                    command_reg.Parameters.AddWithValue("p_author_id", authorId);
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
                string authorName = selectedImage.AuthorName;
                int authorId = 0;
                using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM ID_FROM_AUT_NAME(@p_fst_name_aut);", connection))
                {
                    command.Parameters.AddWithValue("p_fst_name_aut", authorName);
                    authorId = (int)command.ExecuteScalar();
                }

                EditImage editImage = new EditImage(selectedImage, authorId);
                editImage.ShowDialog();

                Refresh_Click(sender, e);
            }
        }
    }
}