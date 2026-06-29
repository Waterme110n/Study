using Microsoft.Win32;
using System;
using System.Collections.Generic;
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
using System.Xml.Linq;

namespace lab4_5
{
    public partial class UpdateServ : Window
    {
        public UpdateServ()
        {
            InitializeComponent();
        }

        string namee;
        public void FillFields(string name, string description, string cost, string category, string doctor, string cabinet)
        {
            name2.Text = name;
            namee = name;
            description2.Text = description;
            cost2.Text = cost;
            category2.Text = category;
            doctor2.Text = doctor;
            cabinet2.Text = Convert.ToString(cabinet);

        }

        string selectedImagePath;
        private void AddPicture1_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "Image Files (*.png;*.jpg;*.jpeg;*.gif;*.bmp)|*.png;*.jpg;*.jpeg;*.gif;*.bmp|All files (*.*)|*.*";

            if (openFileDialog.ShowDialog() == true)
            {
                selectedImagePath = openFileDialog.FileName;
                dd.Source = new BitmapImage(new Uri(selectedImagePath));
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

        private void updateService_Click(object sender, RoutedEventArgs e)
        {
            string serviceName = name2.Text;
            string serviceCost = cost2.Text;
            string serviceDescription = description2.Text;
            string serviceCategory = category2.Text;
            string serviceDoctor = doctor2.Text;
            string serviceCabinet = cabinet2.Text;


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

            if (int.TryParse(serviceCategory, out _))
            {
                MessageBox.Show("Категория должна состоять только из текста.");
                return;
            }
            
            if (selectedImagePath == "")
            {
                MessageBox.Show("Выберите изображение.");
                return;
            }

            if (int.TryParse(serviceDoctor, out _))
            {
                MessageBox.Show("Врач должен быть только из текста.");
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
            string[] lines = File.ReadAllLines(filePath);

            List<string> updatedLines = new List<string>();

            for (int i = 0; i < lines.Length; i += 7)
            {
                string nameLine = lines[i];
                string costLine = lines[i + 1];
                string descriptionLine = lines[i + 2];
                string imageLine = lines[i + 3];
                string categoryLine = lines[i + 4];
                string doctorLine = lines[i + 5];
                string cabinetLine = lines[i + 6];

                string serviceNameFromFile = nameLine.Substring(nameLine.IndexOf(":") + 1).Trim();
                string serviceImage = imageLine.Substring(imageLine.IndexOf(":") + 1).Trim();

                if (serviceNameFromFile == namee)
                {
                    nameLine = "Название услуги: " + serviceName;
                    costLine = "Стоимость услуги: " + serviceCost;
                    descriptionLine = "Краткое описание: " + serviceDescription;
                    categoryLine = "Категория: " + serviceCategory;
                    doctorLine = "Врач:" + serviceDoctor;
                    cabinetLine = "Кабинет:" + serviceCabinet;
                    
                    if (!string.IsNullOrEmpty(selectedImagePath))
                    {
                        imageLine = "Путь к изображению: " + selectedImagePath;
                    }
                    else
                    {
                        imageLine = "Путь к изображению: " + serviceImage;
                    }

                }

                updatedLines.Add(nameLine);
                updatedLines.Add(costLine);
                updatedLines.Add(descriptionLine);
                updatedLines.Add(imageLine);
                updatedLines.Add(categoryLine);
                updatedLines.Add(doctorLine);
                updatedLines.Add(cabinetLine);
            }

            File.WriteAllText("undo.txt", string.Empty);
            File.WriteAllLines("undo.txt", lines);

            File.WriteAllLines(filePath, updatedLines);
            MessageBox.Show("Услуга успешно обновлена.");

            Servises servicess = new Servises();
            servicess.Show();
            this.Close();
        }

        private void MyTextBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Regex regex = new Regex(@"^[0-9]*[a-zA-Z]?$");
            if (!regex.IsMatch(e.Text))
            {
                e.Handled = true;
            }
        }

        private void cost_PreviewTextInput(object sender, TextCompositionEventArgs e)
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

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            Servises servicess = new Servises();
            servicess.Show();
            this.Close();
        }
    }
}
