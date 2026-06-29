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
    public partial class MaxPriceField : UserControl
    {

        public static readonly DependencyProperty ValueProperty =
        DependencyProperty.Register(
            "Value",
            typeof(object),
            typeof(MaxPriceField),
            new FrameworkPropertyMetadata(string.Empty, FrameworkPropertyMetadataOptions.None, OnValueChanged, CoerceValue), ValidateValue);

        public object Value
        {
            get { return GetValue(ValueProperty); }
            set { SetValue(ValueProperty, value); }
        }

        public MaxPriceField()
        {
            InitializeComponent();
        }

        private void TextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            string newValue = ((TextBox)sender).Text;
            Value = newValue;
        }

        private static bool ValidateValue(object value)
        {
            return true;
        }

        private static void OnValueChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
        }

        private static object CoerceValue(DependencyObject d, object value)
        {
            string newValue = (string)value;
            if (decimal.TryParse(newValue, out decimal decimalValue))
            {
                int decimalPlaces = BitConverter.GetBytes(decimal.GetBits(decimalValue)[3])[2];
                if (decimalPlaces > 2)
                {
                    decimalValue = Math.Round(decimalValue, 2);
                }
                return decimalValue;
            }
            return string.Empty;
        }
    }
        
}
