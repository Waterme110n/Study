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
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace lab4_5
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            ServPage.Click += ServPage_Click;
            AdminPage.Click += AdminPanel_Click;

            var defaultLanguageDictionary = new ResourceDictionary();
            defaultLanguageDictionary.Source = new Uri("Resources.ru.xaml", UriKind.Relative);
            Application.Current.Resources.MergedDictionaries.Add(defaultLanguageDictionary);
        }

        private void AdminPanel_Click(object sender, RoutedEventArgs e)
        {
            AdminPanel adminPanel = new AdminPanel();
            adminPanel.ShowDialog();
        }

        private void ServPage_Click(object sender, RoutedEventArgs e)
        {
            Servises servises = new Servises();
            servises.Show();
            this.Close();
        }

        private void ChangeLanguage(string language)
        {
            Application.Current.Resources.MergedDictionaries.Clear();

            var languageDictionary = new ResourceDictionary();
            languageDictionary.Source = new Uri($"Resources.{language}.xaml", UriKind.Relative);
            Application.Current.Resources.MergedDictionaries.Add(languageDictionary);
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
    }
}
