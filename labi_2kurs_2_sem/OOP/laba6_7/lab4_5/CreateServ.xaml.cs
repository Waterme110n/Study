using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using static System.Net.Mime.MediaTypeNames;

namespace lab4_5
{
    public partial class CreateServ : Window
    {
        public CreateServ()
        {
            InitializeComponent();
        }

        string selectedImagePath;
        private void AddPicture_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "Image Files (*.png;*.jpg;*.jpeg;*.gif;*.bmp)|*.png;*.jpg;*.jpeg;*.gif;*.bmp|All files (*.*)|*.*";

            if (openFileDialog.ShowDialog() == true)
            {
                selectedImagePath = openFileDialog.FileName;
                d.Source = new BitmapImage(new Uri(selectedImagePath));
            }
        }

        public string ValidateDoctorName(string name)
        {
            Regex regex = new Regex(@"^[А-ЯЁ][а-яё]+\s[А-ЯЁ]\.[А-ЯЁ]\.$");
            if (!regex.IsMatch(name))
            {
                return "Некорректное имя доктора. Используйте формат 'Кореневский К.Р.'";
            }
            else
            {
                return null;
            }
        }

        public string ValidateCabinetNumber(string officeNumber)
        {
            Regex regex = new Regex(@"^\d{3}([а-я])?$");
            if (!regex.IsMatch(officeNumber))
            {
                return "Некорректный номер кабинета. Используйте формат 'XXX' или 'XXXб', где X - цифра, а б - маленькая буква.";
            }
            else
            {
                return null;
            }
        }

        private void addService_Click(object sender, RoutedEventArgs e)
        {
            string serviceName = name.Text;
            string serviceCost = cost.Text;
            string serviceDescription = description.Text;
            string serviceCategory = category.Text;
            string serviceDoctor = doctor.Text;
            string serviceCabinet = cabinet.Text;

            if (int.TryParse(serviceName, out _))
            {
                MessageBox.Show("Название услуги должно состоять только из текста.");
                return;
            }

            if (string.IsNullOrEmpty(serviceName))
            {
                MessageBox.Show("Введите название услуги.");
                return;
            }

            if (string.IsNullOrEmpty(serviceCost) || !decimal.TryParse(serviceCost, out _))
            {
                MessageBox.Show("Введите корректную стоимость услуги.");
                return;
            }

            if (int.TryParse(serviceDescription, out _))
            {
                MessageBox.Show("Краткое описание услуги должно состоять только из текста.");
                return;
            }

            if (selectedImagePath == "")
            {
                MessageBox.Show("Выберите изображение.");
                return;
            }

            if (int.TryParse(serviceCategory, out _))
            {
                MessageBox.Show("Категория должна состоять только из текста.");
                return;
            }

            if (int.TryParse(serviceDoctor, out _))
            {
                MessageBox.Show("Категория должна состоять только из текста.");
                return;
            }

            string validationError = ValidateDoctorName(serviceDoctor);

            if (validationError != null)
            {
                MessageBox.Show(validationError);
                return;
            }


            string validationError2 = ValidateCabinetNumber(serviceCabinet);
            if (validationError2 != null)
            {
                MessageBox.Show(validationError2);
                return;
            }


            string filePath = "services.txt";

            using (StreamWriter writer = File.AppendText(filePath))
            {
                writer.WriteLine("Название услуги: " + serviceName);
                writer.WriteLine("Стоимость услуги: " + serviceCost);
                writer.WriteLine("Краткое описание услуги: " + serviceDescription);
                writer.WriteLine("Путь к изображению: " + selectedImagePath);
                writer.WriteLine("Категория: " + serviceCategory);
                writer.WriteLine("Врач: " + serviceDoctor);
                writer.WriteLine("Кабинет: " + serviceCabinet);

            }

            name.Text = "";
            cost.Text = "";
            description.Text = "";
            category.Text = "";
            cabinet.Text = "";
            doctor.Text = "";

            MessageBox.Show("Услуга успешно добавлена и сохранена в файл.");

            Servises servicess = new Servises();
            servicess.Show();
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

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            Servises servicess = new Servises();
            servicess.Show();
            this.Close();
        }

        private void TextBlock_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            if (!IsNumeric(e.Text) && e.Text != ".")
            {
                e.Handled = true;
            }
        }

        private bool IsNumeric(string text)
        {
            return double.TryParse(text, out _);
        }
    
    }
}
