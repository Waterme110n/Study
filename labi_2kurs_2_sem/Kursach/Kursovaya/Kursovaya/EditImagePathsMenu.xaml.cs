using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Data;
using System.Data.Common;
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
using Microsoft.Win32;
using Npgsql;
using static Kursovaya.CustomerMenu;

namespace Kursovaya
{
    /// <summary>
    /// Логика взаимодействия для EditImagePathsMenu.xaml
    /// </summary>
    public partial class EditImagePathsMenu : Window
    {
        public List<int> SelectedImagePathsIds { get; set; } = new List<int>();
        private NpgsqlConnection connection;
        public List<int> ExistingImagePathsIds { get; set; }

        public EditImagePathsMenu(List<int> existingImagePathsIds)
        {
            InitializeComponent();
            Loaded += Refresh_Click;

            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=author_01;Password=auth01;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();

            ExistingImagePathsIds = existingImagePathsIds;
        }

        private void CustomerMenu_Closing(object sender, CancelEventArgs e)
        {
            if (connection != null && connection.State == ConnectionState.Open)
            {
                connection.Close();
            }
        }

        public class ImagePaths
        {
            public int Id { get; set; }
            public string ImagePath { get; set; }

        }

        private void Refresh_Click(object sender, RoutedEventArgs e)
        {
            using (var command = new NpgsqlCommand("SELECT * FROM ALL_IMAGEPATHS()", connection))
            {
                using (var reader = command.ExecuteReader())
                {
                    var ImagePathsList = new List<ImagePaths>();

                    while (reader.Read())
                    {
                        var ImagePath = new ImagePaths
                        {
                            Id = reader.GetInt32(0),
                            ImagePath = reader.GetString(1),
                        };

                        ImagePathsList.Add(ImagePath);

                    }
                    imagePathsListView.ItemsSource = ImagePathsList;
                }
            }
        }

        private List<int> selectedImagePathsIds = new List<int>();

        private void Image_Click(object sender, MouseButtonEventArgs e)
        {
            var selectedImage = (Image)sender;
            var selectedImagePath = (ImagePaths)selectedImage.DataContext;

            if (selectedImagePathsIds.Contains(selectedImagePath.Id))
            {
                selectedImagePathsIds.Remove(selectedImagePath.Id);
            }
            else
            {
                selectedImagePathsIds.Add(selectedImagePath.Id);
            }
        }
        private void Accept_Images(object sender, RoutedEventArgs e)
        {
            SelectedImagePathsIds = selectedImagePathsIds;
            Close();
        }

        private void Add_Images(object sender, RoutedEventArgs e)
        {
            SelectPhoto();
            Refresh_Click(sender, e);
        }

        private void SelectPhoto()
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "Image Files (*.png;*.jpg;*.jpeg;*.gif;*.bmp)|*.png;*.jpg;*.jpeg;*.gif;*.bmp|All Files (*.*)|*.*";

            if (openFileDialog.ShowDialog() == true)
            {
                string selectedPhotoPath = openFileDialog.FileName;
                MessageBox.Show(selectedPhotoPath);

                using (var command = new NpgsqlCommand("add_image_path_procedure", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@p_image_path", selectedPhotoPath);
                    try
                    {
                        command.ExecuteNonQuery();
                        MessageBox.Show("Your image added successfully!");
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
