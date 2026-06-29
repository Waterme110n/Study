using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Data;

namespace Kursovaya
{
    public class FavoriteImageConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            bool isFavorite = (bool)value;

            if (isFavorite)
                return "C:/labi_2kurs_2_sem/Kursach/Kursovaya/Kursovaya/images/star_clicked.png";
            else
                return "C:/labi_2kurs_2_sem/Kursach/Kursovaya/Kursovaya/images/star.png";
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
