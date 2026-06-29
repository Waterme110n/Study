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

namespace lab4_5
{
    public partial class DeleteServ : Window
    {
        private UndoRedoManager undoRedoManager;

        public DeleteServ()
        {
            InitializeComponent();
            undoRedoManager = new UndoRedoManager();
        }

        private ICommand deleteProductCommand;

        public ICommand DeleteProductCommand
        {
            get
            {
                if (deleteProductCommand == null)
                    deleteProductCommand = new RelayCommand(delService_Click);

                return deleteProductCommand;
            }
        }

        private void DeleteServiceByName(string serviceName)
        {
            
                string filePath = "services.txt";
                string[] lines = File.ReadAllLines(filePath);

                List<string> updatedLines = new List<string>();
                bool serviceFound = false;

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

                    if (serviceNameFromFile == serviceName)
                    {
                        serviceFound = true;
                        continue;
                    }

                    updatedLines.Add(nameLine);
                    updatedLines.Add(costLine);
                    updatedLines.Add(descriptionLine);
                    updatedLines.Add(imageLine);
                    updatedLines.Add(categoryLine);
                    updatedLines.Add(doctorLine);
                    updatedLines.Add(cabinetLine);
                }

                if (!serviceFound)
                {
                    MessageBox.Show("Услуга не найдена.", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }

            File.WriteAllText("undo.txt", string.Empty);
            File.WriteAllLines("undo.txt", lines);

            File.WriteAllLines(filePath, updatedLines);
            MessageBox.Show("Услуга успешно удалена из файла.");

            Servises servicesss = new Servises();
            servicesss.Show();
            this.Close();
        }

        private void delService_Click(object sender, RoutedEventArgs e)
        {
            string serviceName = ProcedureNameTextBox.Text;
            DeleteServiceByName(serviceName);
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
