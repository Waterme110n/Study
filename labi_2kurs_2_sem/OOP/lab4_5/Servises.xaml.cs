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
   
    public partial class Servises : Window
    {
        public Servises()
        {
            InitializeComponent();
            MainPage.Click += MainPage_Click;
            AdminPage.Click += AdminPage_Click;
            primButton.Click += primButton_Click;
            ReadServicesFromFile();
            DisplayServices();
        }

        private ICommand editProductCommand;
        public ICommand EditProductCommand
        {
            get
            {
                if (editProductCommand == null)
                    editProductCommand = new RelayCommand(Button_Click);

                return editProductCommand;
            }
        }

        private void AdminPage_Click(object sender, RoutedEventArgs e)
        {
            AdminPanel adminPanel = new AdminPanel();
            adminPanel.Show();
            this.Close();
        }

        private void MainPage_Click(object sender, RoutedEventArgs e)
        {
            MainWindow mainWindow = new MainWindow();
            mainWindow.Show();
            this.Close();
        }

        List<Service> services = new List<Service>();

        private List<Service> ReadServicesFromFile()
        {
            services.Clear();
            string[] lines = File.ReadAllLines("services.txt");

            for (int i = 0; i < lines.Length; i += 7)
            {
                string nameLine = lines[i];
                string costLine = lines[i + 1];
                string descriptionLine = lines[i + 2];
                string imageLine = lines[i + 3];
                string categoryLine  = lines[i + 4];
                string doctorLine = lines[i + 5];
                string cabinetLine = lines[i + 6];

                string serviceName = nameLine.Substring(nameLine.IndexOf(":") + 1).Trim();
                float serviceCost = float.Parse(costLine.Substring(costLine.IndexOf(":") + 1).Trim());
                string serviceDescription = descriptionLine.Substring(descriptionLine.IndexOf(":") + 1).Trim();
                string serviceImage = imageLine.Substring(imageLine.IndexOf(":") + 1).Trim();
                string serviceCategory = categoryLine.Substring(categoryLine.IndexOf(":") + 1).Trim();
                string serviceDoctor = doctorLine.Substring(doctorLine.IndexOf(":") + 1).Trim();
                int serviceCabinet = Convert.ToInt32(cabinetLine.Substring(cabinetLine.IndexOf(":") + 1).Trim());

                Service service = new Service
                {
                    Name = serviceName,
                    Cost = serviceCost,
                    Description = serviceDescription,
                    Image = serviceImage,
                    Category = serviceCategory,
                    Doctor = serviceDoctor,
                    Cabinet = serviceCabinet
                };

                services.Add(service);
            }

            return services;
        }

        private Dictionary<StackPanel, string> doctors = new Dictionary<StackPanel, string>();
        private Dictionary<StackPanel, int> cabinets = new Dictionary<StackPanel, int>();
        private Dictionary<StackPanel, string> descriptions = new Dictionary<StackPanel, string>();


        private void Button_Click(object sender, RoutedEventArgs e)
        {
            Button button1 = (Button)sender;
            StackPanel serviceContainer1 = (StackPanel)button1.Parent;

            TextBlock nameTextBlock1 = (TextBlock)serviceContainer1.Children[0];
            TextBlock categoryBlock1 = (TextBlock)serviceContainer1.Children[1];
            TextBlock costTextBlock1 = (TextBlock)serviceContainer1.Children[2];

            string name = nameTextBlock1.Text;
            string description = descriptions[serviceContainer1];
            string category = categoryBlock1.Text.Substring("Категория: ".Length);
            string cost = costTextBlock1.Text.Substring("Стоимость: ".Length);
            string doctor = doctors[serviceContainer1];
            int cabinet = cabinets[serviceContainer1];

            UpdateServ updateServ = new UpdateServ();
            updateServ.FillFields(name, description, cost, category, doctor, cabinet);
            updateServ.Show();
            this.Close();
        }


        private void NameTextBlock_Click(object sender, RoutedEventArgs e)
        {
            TextBlock nameTextBlock = (TextBlock)sender;
            StackPanel serviceContainer1 = (StackPanel)nameTextBlock.Parent;

            TextBlock nameTextBlock1 = (TextBlock)serviceContainer1.Children[0];
            TextBlock categoryBlock1 = (TextBlock)serviceContainer1.Children[1];
            TextBlock costTextBlock1 = (TextBlock)serviceContainer1.Children[2];
            Image image = (Image)((Grid)serviceContainer1.Parent).Children[0];

            string name = nameTextBlock1.Text;
            string description = descriptions[serviceContainer1];
            string category = categoryBlock1.Text.Substring("Категория: ".Length);
            string cost = costTextBlock1.Text.Substring("Стоимость: ".Length);
            string doctor = doctors[serviceContainer1];
            int cabinet = cabinets[serviceContainer1];
            string imagePath = ((BitmapImage)image.Source).UriSource.AbsoluteUri;

            ServiceDetailsWindow detailsWindow = new ServiceDetailsWindow();
            detailsWindow.FillFields(name, description, cost, category, doctor, cabinet, imagePath);
            detailsWindow.ShowDialog();
        }
        
       


        public void DisplayServices()
        {
            ServicesStackPanel.Children.Clear();

            foreach (var service in services)
            {
                string doc = service.Doctor;
                int cab = service.Cabinet;
                string descr = service.Description;

                Grid serviceContainer = new Grid();
                serviceContainer.Margin = new Thickness(30,0,30,0);
                serviceContainer.Background = Brushes.White;

                Border border = new Border();
                border.BorderBrush = Brushes.Aqua;
                border.BorderThickness = new Thickness(2);
                border.CornerRadius = new CornerRadius(5);
                border.Margin = new Thickness(5);
                border.Child = serviceContainer;

                ColumnDefinition c1 = new ColumnDefinition()
                {
                    Width = new GridLength(1, GridUnitType.Star)
                };
                ColumnDefinition c2 = new ColumnDefinition()
                {
                    Width = new GridLength(2, GridUnitType.Star)
                };

                serviceContainer.ColumnDefinitions.Add(c1);
                serviceContainer.ColumnDefinitions.Add(c2);

                StackPanel nearImageContainer = new StackPanel();

                TextBlock nameTextBlock = new TextBlock();
                nameTextBlock.Text = service.Name;
                nameTextBlock.FontSize = 16;
                nameTextBlock.Margin = new Thickness(10, 10, 0, 10);
                nameTextBlock.MouseLeftButtonUp += NameTextBlock_Click;


                TextBlock categoryTextBlock = new TextBlock();
                categoryTextBlock.Text = "Категория: " + service.Category;
                categoryTextBlock.Margin = new Thickness(10, 0, 0, 10);

                TextBlock costTextBlock = new TextBlock();
                costTextBlock.Text = "Стоимость: " + service.Cost.ToString();
                costTextBlock.Margin = new Thickness(10, 0, 0, 10);


                Image image = new Image();
                image.Source = new BitmapImage(new Uri(service.Image));
                image.Width = 250;
                image.Height = 180;

                Button button = new Button();
                button.HorizontalAlignment = HorizontalAlignment.Right;
                button.VerticalAlignment = VerticalAlignment.Bottom;
                button.Margin = new Thickness(5);
                button.Background = Brushes.White;
                button.Foreground = Brushes.DarkSlateBlue;
                button.BorderBrush = Brushes.LightBlue;
                button.BorderThickness = new Thickness(1);
                button.Click += Button_Click;

                if (isRussian == true)
                {
                    button.Content = "Редактировать";
                }
                else
                {
                    button.Content = "Edit";
                }

                Grid.SetColumn(image, 0);
                Grid.SetColumn(nearImageContainer, 1);

                nearImageContainer.Children.Add(nameTextBlock);
                nearImageContainer.Children.Add(categoryTextBlock);
                nearImageContainer.Children.Add(costTextBlock);
                nearImageContainer.Children.Add(button);

                serviceContainer.Children.Add(image);
                serviceContainer.Children.Add(nearImageContainer);

                ServicesStackPanel.Children.Add(border);


                doctors[nearImageContainer] = doc;
                cabinets[nearImageContainer] = cab;
                descriptions[nearImageContainer] = descr;
            }
        }

        private void primButton_Click(object sender, RoutedEventArgs e)
        {
            List<Service> allServices = ReadServicesFromFile();

            string minPrice = MinPriceTextBox.Text;
            string maxPrice = MaxPriceTextBox.Text;
            string selectedCategory = ((ComboBoxItem)CategoryComboBox.SelectedItem)?.Content.ToString();

            List<Service> filteredServices = FilterServices(allServices, minPrice, maxPrice, selectedCategory);

            DisplayFilteredServices(filteredServices);
        }

        private List<Service> FilterServices(List<Service> services, string minPrice, string maxPrice, string selectedCategory)
        {
            List<Service> filteredServices = new List<Service>(services);

            if (!string.IsNullOrEmpty(minPrice))
            {
                float minPriceValue = float.Parse(minPrice);
                filteredServices = filteredServices.Where(s => s.Cost >= minPriceValue).ToList();
            }

            if (!string.IsNullOrEmpty(maxPrice))
            {
                float maxPriceValue = float.Parse(maxPrice);
                filteredServices = filteredServices.Where(s => s.Cost <= maxPriceValue).ToList();
            }

            if (selectedCategory != "Все")
            {
                filteredServices = filteredServices.Where(s => s.Category == selectedCategory).ToList();
            }

            return filteredServices;
        }

        private void DisplayFilteredServices(List<Service> filteredServices)
        {
            ServicesStackPanel.Children.Clear();

            foreach (var service in filteredServices)
            {
                string doc = service.Doctor;
                int cab = service.Cabinet;
                string descr = service.Description;

                Grid serviceContainer = new Grid();
                serviceContainer.Margin = new Thickness(30, 0, 30, 0);
                serviceContainer.Background = Brushes.White;

                Border border = new Border();
                border.BorderBrush = Brushes.Aqua;
                border.BorderThickness = new Thickness(2);
                border.CornerRadius = new CornerRadius(5);
                border.Margin = new Thickness(5);
                border.Child = serviceContainer;

                ColumnDefinition c1 = new ColumnDefinition()
                {
                    Width = new GridLength(1, GridUnitType.Star)
                };
                ColumnDefinition c2 = new ColumnDefinition()
                {
                    Width = new GridLength(2, GridUnitType.Star)
                };

                serviceContainer.ColumnDefinitions.Add(c1);
                serviceContainer.ColumnDefinitions.Add(c2);

                StackPanel nearImageContainer = new StackPanel();

                TextBlock nameTextBlock = new TextBlock();
                nameTextBlock.Text = service.Name;
                nameTextBlock.FontSize = 16;
                nameTextBlock.Margin = new Thickness(10, 10, 0, 10);

                TextBlock categoryTextBlock = new TextBlock();
                categoryTextBlock.Text = "Категория: " + service.Category;
                categoryTextBlock.Margin = new Thickness(10, 0, 0, 10);

                TextBlock costTextBlock = new TextBlock();
                costTextBlock.Text = "Стоимость: " + service.Cost.ToString();
                costTextBlock.Margin = new Thickness(10, 0, 0, 10);


                Image image = new Image();
                image.Source = new BitmapImage(new Uri(service.Image));
                image.Width = 250;
                image.Height = 180;

                Button button = new Button();
                button.HorizontalAlignment = HorizontalAlignment.Right;
                button.VerticalAlignment = VerticalAlignment.Bottom;
                button.Margin = new Thickness(5);
                button.Background = Brushes.White;
                button.Foreground = Brushes.DarkSlateBlue;
                button.BorderBrush = Brushes.LightBlue;
                button.BorderThickness = new Thickness(1);
                button.Click += Button_Click;

                if (isRussian == true)
                {
                    button.Content = "Редактировать";
                }
                else
                {
                    button.Content = "Edit";
                }

                Grid.SetColumn(image, 0);
                Grid.SetColumn(nearImageContainer, 1);

                nearImageContainer.Children.Add(nameTextBlock);
                nearImageContainer.Children.Add(categoryTextBlock);
                nearImageContainer.Children.Add(costTextBlock);
                nearImageContainer.Children.Add(button);

                serviceContainer.Children.Add(image);
                serviceContainer.Children.Add(nearImageContainer);

                ServicesStackPanel.Children.Add(border);


                doctors[nearImageContainer] = doc;
                cabinets[nearImageContainer] = cab;
                descriptions[nearImageContainer] = descr;
            }
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            string searchQuery = SearchTextBox.Text;

            List<Service> matchingServices = services.Where(service => service.Name.Contains(searchQuery)).ToList();

            ServicesStackPanel.Children.Clear(); 

            foreach (var service in matchingServices)
            {
                string doc = service.Doctor;
                int cab = service.Cabinet;
                string descr = service.Description;

                Grid serviceContainer = new Grid();
                serviceContainer.Margin = new Thickness(30, 0, 30, 0);
                serviceContainer.Background = Brushes.White;

                Border border = new Border();
                border.BorderBrush = Brushes.Aqua;
                border.BorderThickness = new Thickness(2);
                border.CornerRadius = new CornerRadius(5);
                border.Margin = new Thickness(5);
                border.Child = serviceContainer;

                ColumnDefinition c1 = new ColumnDefinition()
                {
                    Width = new GridLength(1, GridUnitType.Star)
                };
                ColumnDefinition c2 = new ColumnDefinition()
                {
                    Width = new GridLength(2, GridUnitType.Star)
                };

                serviceContainer.ColumnDefinitions.Add(c1);
                serviceContainer.ColumnDefinitions.Add(c2);

                StackPanel nearImageContainer = new StackPanel();

                TextBlock nameTextBlock = new TextBlock();
                nameTextBlock.Text = service.Name;
                nameTextBlock.FontSize = 16;
                nameTextBlock.Margin = new Thickness(10, 10, 0, 10);



                TextBlock categoryTextBlock = new TextBlock();
                categoryTextBlock.Text = "Категория: " + service.Category;
                categoryTextBlock.Margin = new Thickness(10, 0, 0, 10);

                TextBlock costTextBlock = new TextBlock();
                costTextBlock.Text = "Стоимость: " + service.Cost.ToString();
                costTextBlock.Margin = new Thickness(10, 0, 0, 10);


                Image image = new Image();
                image.Source = new BitmapImage(new Uri(service.Image));
                image.Width = 250;
                image.Height = 180;

                Button button = new Button();
                button.HorizontalAlignment = HorizontalAlignment.Right;
                button.VerticalAlignment = VerticalAlignment.Bottom;
                button.Margin = new Thickness(5);
                button.Background = Brushes.White;
                button.Foreground = Brushes.DarkSlateBlue;
                button.BorderBrush = Brushes.LightBlue;
                button.BorderThickness = new Thickness(1);
                button.Click += Button_Click;

                if (isRussian == true)
                {
                    button.Content = "Редактировать";
                }
                else
                {
                    button.Content = "Edit";
                }

                Grid.SetColumn(image, 0);
                Grid.SetColumn(nearImageContainer, 1);

                nearImageContainer.Children.Add(nameTextBlock);
                nearImageContainer.Children.Add(categoryTextBlock);
                nearImageContainer.Children.Add(costTextBlock);
                nearImageContainer.Children.Add(button);

                serviceContainer.Children.Add(image);
                serviceContainer.Children.Add(nearImageContainer);

                ServicesStackPanel.Children.Add(border);


                doctors[nearImageContainer] = doc;
                cabinets[nearImageContainer] = cab;
                descriptions[nearImageContainer] = descr;
            }
        }

        private bool isRussian = false;
        private void LanguageButton_Click(object sender, RoutedEventArgs e)
        {
            if (isRussian)
            {
                int russianIndex = Resources.MergedDictionaries.Count - 1;
                if (russianIndex >= 0)
                {
                    Resources.MergedDictionaries.RemoveAt(russianIndex);
                    isRussian = false;
                    DisplayServices();
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
