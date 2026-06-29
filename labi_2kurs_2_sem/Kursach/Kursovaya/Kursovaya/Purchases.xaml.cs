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
using static Kursovaya.CustomerMenu;

namespace Kursovaya
{
    /// <summary>
    /// Логика взаимодействия для Purchases.xaml
    /// </summary>
    public partial class Purchases : Window
    {
        public int UserId { get; set; }
        private NpgsqlConnection connection;

        public Purchases(int UserID)
        {
            UserId = UserID;
            InitializeComponent();
            Loaded += CustomerMenu_Loaded;


            string connectionString = "Server=localhost;Port=5432;Database=Kursach;User id=customer_01;Password=cust01;";
            connection = new NpgsqlConnection(connectionString);
            connection.Open();
        }

        private void CustomerMenu_Loaded(object sender, RoutedEventArgs e)
        {
            Load_purchases(sender, e);
        }

        public class PurchaseWithImage
        {
            public int PurchaseId { get; set; }
            public int ProductId { get; set; }
            public int CustomerId { get; set; }
            public DateTime PurchaseDate { get; set; }
            public decimal TotalPrice { get; set; }
            public string ImageName { get; set; }
            public string[] ImagePaths { get; set; }
            public string AuthorName { get; set; }
        }

        private void Load_purchases(object sender, RoutedEventArgs e)
        {
            using (var command = new NpgsqlCommand("SELECT * FROM ALL_PURCHASES(@p_user_id);", connection))
            {
                command.Parameters.AddWithValue("p_user_id", UserId);

                using (var reader = command.ExecuteReader())
                {
                    var imagePurchases = new List<PurchaseWithImage>();

                    
                    while (reader.Read())
                    {
                        var purchase = new PurchaseWithImage
                        {
                            PurchaseId = reader.GetInt32(0),
                            ProductId = reader.GetInt32(1),
                            CustomerId = reader.GetInt32(2),
                            PurchaseDate = reader.GetDateTime(3),
                            TotalPrice = reader.GetDecimal(4),
                            ImageName = reader.GetString(5),
                            ImagePaths = (string[])reader.GetValue(6),
                            AuthorName = reader.GetString(7),
                            
                        };

                        imagePurchases.Add(purchase);
                    }

                    PurchasesList.ItemsSource = imagePurchases;
                }
            }
        }

        private void Back_click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }    
    }
}
