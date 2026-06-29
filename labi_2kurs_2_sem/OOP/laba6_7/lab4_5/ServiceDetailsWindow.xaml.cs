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
using System.Xml.Linq;
using static System.Net.Mime.MediaTypeNames;

namespace lab4_5
{
    public partial class ServiceDetailsWindow : Window
    {

        private string serviceName;
        private string serviceDescription;
        private string serviceCost;
        private string serviceCategory;
        private string serviceDoctor;
        private string serviceCabinet;

        public ServiceDetailsWindow()
        {
            InitializeComponent();
        }

        public void FillFields(string name, string description, string cost, string category, string doctor, string cabinet, string imagePath)
        {
            serviceName = name;
            serviceDescription = description;
            serviceCost = cost;
            serviceCategory = category;
            serviceDoctor = doctor;
            serviceCabinet = cabinet;


            NameTextBlock.Text = serviceName;
            DescriptionTextBlock.Text = "Описание услуги: " + serviceDescription;
            CostTextBlock.Text = "Стоимость: " + serviceCost;
            CategoryTextBlock.Text = "Категогия: " + serviceCategory;
            DoctorTextBlock.Text = "Врач, ответственный за проведение: " + serviceDoctor;
            CabinetTextBlock.Text = "Кабинет проведения: " + serviceCabinet.ToString();

            BitmapImage image = new BitmapImage(new Uri(imagePath));
            ServiceImage.Source = image;
        }
    }
}
