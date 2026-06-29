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

namespace lab4_5
{
    
    public partial class AdminPanel : Window
    {
        public AdminPanel()
        {
            InitializeComponent();
            CreatePage.Click += CreatePage_Click;
            DeletePage.Click += DeletePage_Click;
        }

        private void DeletePage_Click(object sender, RoutedEventArgs e)
        {
            DeleteServ deleteServ = new DeleteServ();
            deleteServ.ShowDialog();
            this.Close();
        }

        private void CreatePage_Click(object sender, RoutedEventArgs e)
        {
            CreateServ createServ = new CreateServ();
            createServ.ShowDialog();
            this.Close();
        }

        private bool isRussian = false;

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            if (isRussian)
            {
                int russianIndex = Resources.MergedDictionaries.Count - 1;
                if (russianIndex >= 0)
                {
                    Resources.MergedDictionaries.RemoveAt(russianIndex);
                    isRussian = false;
                }
            }
            else
            {
                var dictionary2 = new ResourceDictionary();
                dictionary2.Source = new Uri("Resources.en.xaml", UriKind.RelativeOrAbsolute);
                Resources.MergedDictionaries.Add(dictionary2);
                isRussian = true;
            }
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            Servises servicess = new Servises();
            servicess.Show();
            this.Close();
        }
    }
}
