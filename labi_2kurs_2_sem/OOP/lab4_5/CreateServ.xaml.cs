using Microsoft.Win32;
using System;
using System.Collections.Generic;
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

            if (string.IsNullOrEmpty(serviceCost) || !decimal.TryParse(serviceCost, out decimal cost2) || cost2 < 0)
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

            int serviceCabinett;
            if (int.TryParse(serviceCabinet, out serviceCabinett))
            {
                if (serviceCabinett < 0)
                {
                    MessageBox.Show("Кабинет не может быть отрицательным числом.");
                    return;
                }
            }
            else
            {
                MessageBox.Show("Кабинет должен быть числом.");
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
                writer.WriteLine("Кабинет: " + serviceCabinett);

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
