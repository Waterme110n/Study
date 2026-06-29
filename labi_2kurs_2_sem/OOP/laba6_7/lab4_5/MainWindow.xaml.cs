using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
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

        private bool isRussian = false;
        private void Button_Click(object sender, RoutedEventArgs e)
        {
            if (isRussian)
            {
                LanguageManager.CurrentLanguage = new CultureInfo("en");
            }
            else
            {
                LanguageManager.CurrentLanguage = new CultureInfo("ru");
            }

            isRussian = !isRussian;
        }

        private void DefaulTheme_Click(object sender, RoutedEventArgs e)
        {
                ResourceDictionary defaultTheme = new ResourceDictionary();
                defaultTheme.Source = new Uri("DefaultTheme.xaml", UriKind.Relative);

                ThemeManager.CurrentTheme = defaultTheme;
        }

        private void DarkTheme_Click(object sender, RoutedEventArgs e)
        {
            ResourceDictionary darkTheme = new ResourceDictionary();
            darkTheme.Source = new Uri("DarkTheme.xaml", UriKind.Relative);

            ThemeManager.CurrentTheme = darkTheme;
        }

        private void GreenTheme_Click(object sender, RoutedEventArgs e)
        {
            ResourceDictionary greenTheme = new ResourceDictionary();
            greenTheme.Source = new Uri("GreenTheme.xaml", UriKind.Relative);

            ThemeManager.CurrentTheme = greenTheme;
        }
    }



    public static class LanguageManager
    {
        public static event EventHandler LanguageChanged;

        private static CultureInfo currentLanguage = CultureInfo.DefaultThreadCurrentUICulture;

        public static CultureInfo CurrentLanguage
        {
            get { return currentLanguage; }
            set
            {
                if (value != currentLanguage)
                {
                    currentLanguage = value;
                    LanguageChanged?.Invoke(null, EventArgs.Empty);

                    UpdateResources();
                }
            }
        }

        public static void UpdateResources()
        {
            string resourceFile = $"Resources.{currentLanguage.Name}.xaml";
            Uri resourceUri = new Uri(resourceFile, UriKind.Relative);

            ResourceDictionary newDictionary = new ResourceDictionary();
            newDictionary.Source = resourceUri;

            Application.Current.Resources.MergedDictionaries.Add(newDictionary);
        }
    }


    public static class ThemeManager
    {
        public static event EventHandler ThemeChanged;

        private static ResourceDictionary currentTheme;

        public static ResourceDictionary CurrentTheme
        {
            get { return currentTheme; }
            set
            {
                if (value != currentTheme)
                {
                    currentTheme = value;
                    ThemeChanged?.Invoke(null, EventArgs.Empty);

                    UpdateResources();
                }
            }
        }

        public static void UpdateResources()
        {
            Application.Current.Resources.MergedDictionaries.Add(CurrentTheme);
        }
    }


    public class UndoRedoManager
    {
        private string undoFilePath = "undo.txt";
        private string redoFilePath = "redo.txt";
        private string servicesFilePath = "services.txt";

        public void PerformUndo()
        {
            if (File.Exists(undoFilePath))
            {
                string undoData = File.ReadAllText(undoFilePath);
                File.WriteAllText(redoFilePath, GetCurrentData());
                File.Delete(undoFilePath);
            }
        }

        public void PerformRedo()
        {
            if (File.Exists(redoFilePath))
            {
                string redoData = File.ReadAllText(redoFilePath);
                File.WriteAllText(undoFilePath, GetCurrentData());
                File.Delete(redoFilePath);
            }
        }

        private void RestoreData(string data)
        {
            File.WriteAllText(servicesFilePath, data);
        }

        private string GetCurrentData()
        {
            return File.ReadAllText(servicesFilePath);
        }
    }


    public static class CustomCommands
    {
        public static readonly RoutedUICommand MyCustomCommand = new RoutedUICommand(
            "My Custom Command",
            "MyCustomCommand", 
            typeof(CustomCommands),
            new InputGestureCollection()
            {
            new KeyGesture(Key.F5, ModifierKeys.Control)
            });
    }
}
