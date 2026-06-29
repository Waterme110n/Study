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
using System.Xml.Linq;
using Npgsql;
using static Kursovaya.EditImagePathsMenu;

namespace Kursovaya
{
    /// <summary>
    /// Логика взаимодействия для CreateImage.xaml
    /// </summary>
    public partial class CreateImage : Window
    {
        private NpgsqlConnection connection;

        public int UserId { get; set; }
        private List<int> existingImagePathsIds = new List<int>();


        public CreateImage()
        {
            InitializeComponent();

            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=author_01;Password=auth01;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();

            LoadStyles(StyleComboBox, connection);
            LoadSizes(SizeComboBox, connection);
            LoadFrames(FrameComboBox, connection);
            LoadMaterials(MaterialComboBox, connection);
        }

        private void MainWindow_Closing(object sender, CancelEventArgs e)
        {
            if (connection != null && connection.State == ConnectionState.Open)
            {
                connection.Close();
            }
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
        private void LoadSizes(ComboBox comboBox, NpgsqlConnection connection)
        {
            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM ALL_SIZES();", connection))
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
        private void LoadFrames(ComboBox comboBox, NpgsqlConnection connection)
        {
            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM ALL_FRAMES()", connection))
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
        private void LoadMaterials(ComboBox comboBox, NpgsqlConnection connection)
        {
            using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM ALL_MATERIALS()", connection))
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


        private void GoToImages(object sender, RoutedEventArgs e)
        {
            EditImagePathsMenu ImagePaths = new EditImagePathsMenu(existingImagePathsIds);
            ImagePaths.ShowDialog();
            List<int> selectedImagePathsIds = ImagePaths.SelectedImagePathsIds;
            foreach (int id in selectedImagePathsIds)
            {
                if (existingImagePathsIds.Contains(id))
                {
                    existingImagePathsIds.Remove(id); // Удаление элемента, если уже существует
                }
                else
                {
                    existingImagePathsIds.Add(id); // Добавление элемента, если не существует
                }
            }
            ImagesString();
            DisplayImagePaths();
        }

        private void ImagesString()
        {
            string selectedImages = string.Join(", ", existingImagePathsIds);

            TextBlock selectedImageIdsTextBlock = images_id_paths;

            // Установка значения строки в свойство Text элемента TextBlock
            selectedImageIdsTextBlock.Text = selectedImages;
        }

        private void DisplayImagePaths()
        {
            List<ImagePaths> imagePathsList = new List<ImagePaths>();

            using (var command = new NpgsqlCommand("SELECT * FROM PATH_FROM_IMAGE_ID(@P_Image_path_id)", connection))
            {
                foreach (int id in existingImagePathsIds)
                {
                    command.Parameters.Clear();
                    command.Parameters.AddWithValue("P_Image_path_id", id);

                    try
                    {
                        using (var reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string imagePath = reader.GetString(0);

                                ImagePaths imagePathObject = new ImagePaths();
                                imagePathObject.Id = id;
                                imagePathObject.ImagePath = imagePath;

                                imagePathsList.Add(imagePathObject);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error retrieving image path for id {id}: {ex.Message}");
                    }
                }
            }

            imagePathsListView.ItemsSource = imagePathsList;
        }
        
        private void ClosedClick(object sender, RoutedEventArgs e)
        {
            Close();
        }
        private void CreateClick(object sender, RoutedEventArgs e)
        {
            using (NpgsqlCommand command_reg = new NpgsqlCommand("add_image", connection))
            {
                command_reg.CommandType = CommandType.StoredProcedure;

                string imageName = TextboxName.Text;
                string descriptions = TextboxDesc.Text;
                double sliderValue = slider.Value;
                int sliderIntValue = Convert.ToInt32(sliderValue);

                ComboBoxItem selectedStyleItem = (ComboBoxItem)StyleComboBox.SelectedItem;
                int Style_id = (int)selectedStyleItem.Tag;

                ComboBoxItem selectedSizeItem = (ComboBoxItem)SizeComboBox.SelectedItem;
                int Size_id = (int)selectedSizeItem.Tag;

                ComboBoxItem selectedFrameItem = (ComboBoxItem)FrameComboBox.SelectedItem;
                int Frame_id = (int)selectedFrameItem.Tag;

                ComboBoxItem selectedMaterialsItem = (ComboBoxItem)MaterialComboBox.SelectedItem;
                int Material_id = (int)selectedMaterialsItem.Tag;

                int[] Paths = existingImagePathsIds.ToArray();

                command_reg.Parameters.AddWithValue("p_image_name", imageName);
                command_reg.Parameters.AddWithValue("p_image_paths_id", Paths);
                command_reg.Parameters.AddWithValue("p_author_id", UserId);
                command_reg.Parameters.AddWithValue("p_descriptions", descriptions);
                command_reg.Parameters.AddWithValue("p_style_id", Style_id);
                command_reg.Parameters.AddWithValue("p_date_of_creation", sliderIntValue);
                command_reg.Parameters.AddWithValue("p_size_id", Size_id);
                command_reg.Parameters.AddWithValue("p_frame_id", Frame_id);
                command_reg.Parameters.AddWithValue("p_materials_id", Material_id);

                try
                {
                    command_reg.ExecuteNonQuery();
                    MessageBox.Show($"Your image created successfully!");
                    Close();
                }
                catch (NpgsqlException ex)
                {
                    MessageBox.Show(ex.Message);
                }
            }
        }

    }
}
