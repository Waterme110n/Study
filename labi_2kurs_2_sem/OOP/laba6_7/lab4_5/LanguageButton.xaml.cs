using System;
using System.Collections.Generic;
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
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace lab4_5
{
    /// <summary>
    /// Логика взаимодействия для LanguageButton.xaml
    /// </summary>
    public partial class LanguageButton : UserControl
    {
        public LanguageButton()
        {
            InitializeComponent();
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

        public static readonly DependencyProperty LanguageTextProperty =
            DependencyProperty.Register("LanguageText", typeof(string), typeof(LanguageButton),
                new FrameworkPropertyMetadata(null, FrameworkPropertyMetadataOptions.None, OnLanguageTextChanged, CoerceLanguageText),ValidateLanguageText);

        public string LanguageText
        {
            get { return (string)GetValue(LanguageTextProperty); }
            set { SetValue(LanguageTextProperty, value); }
        }

        private static bool ValidateLanguageText(object value)
        {
            
                string text = (string)value;
                return text == null || !string.IsNullOrEmpty(text);
            
        }

        private static object CoerceLanguageText(DependencyObject d, object baseValue)
        {
            string coercedValue = (string)baseValue;
            return coercedValue;
        }

        private static void OnLanguageTextChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
        }
    }
}