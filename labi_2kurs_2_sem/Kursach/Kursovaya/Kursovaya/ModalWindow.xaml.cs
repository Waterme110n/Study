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
using static Kursovaya.EditImagePathsMenu;

namespace Kursovaya
{
    /// <summary>
    /// Логика взаимодействия для ModalWindow.xaml
    /// </summary>
    public partial class ModalWindow : Window
    {
        public ImageInfo SelectedImage { get; set; }
        public int UserId { get; set; }
        private NpgsqlConnection connection;


        public ModalWindow(ImageInfo selectedImage, int UserID)
        {
            UserId = UserID;
            SelectedImage = selectedImage;
            InitializeComponent();
            DataContext = selectedImage;

            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=customer_01;Password=cust01;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();
        }

        private void Buy_Click(object sender, RoutedEventArgs e)
        {
            using (NpgsqlCommand command_reg = new NpgsqlCommand("make_purchase", connection))
            {
                int IdImage = SelectedImage.ImageId;
                command_reg.CommandType = CommandType.StoredProcedure;

                command_reg.Parameters.AddWithValue("p_product_id", IdImage);
                command_reg.Parameters.AddWithValue("p_customer_id", UserId);

                try
                {
                    command_reg.ExecuteNonQuery();
                    MessageBox.Show($"Your purchase successfull!");
                    Purchases purchases = new Purchases(UserId);
                    purchases.ShowDialog();
                    this.Close();
                }
                catch (NpgsqlException ex)
                {
                    MessageBox.Show(ex.Message);
                }
            }
        }
    }
}
