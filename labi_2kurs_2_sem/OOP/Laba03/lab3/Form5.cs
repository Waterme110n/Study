using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml.Linq;
using static lab2.Form1;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace lab2
{
    public partial class Form5 : Form
    {
        protected Form1 Form1;
        public Form5(Form1 form1)
        {
            InitializeComponent();
            label2.Text = "грузоподъёмности";
            Form1 = form1;
        }

        protected virtual void button1_Click_1(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string searchResultsFilePath = "search_results.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItemsss = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            int numberToFind;

            List<Aircraft> results = new List<Aircraft>();

            if (!int.TryParse(SearchTextBox.Text, out numberToFind))
            {
                MessageBox.Show("Неверный формат числа.");
                return;
            }

            string numberPattern = @"\b" + numberToFind + @"\b";
            foreach (var item in dataItemsss)
            {
                ValidationContext validationContext = new ValidationContext(item);
                List<ValidationResult> validationResults = new List<ValidationResult>();

                bool isValid = Validator.TryValidateObject(item, validationContext, validationResults, true);

                if (isValid && Regex.IsMatch(item.PayloadCapacity.ToString(), numberPattern))
                {
                    results.Add(item);
                }
            }

            if (results.Count == 0)
            {
                MessageBox.Show("Ничего не найдено.");
                return;
            }

            StringBuilder sb = new StringBuilder();

            foreach (var item in results)
            {
                sb.AppendLine($"ID: {item.ID}");
                sb.AppendLine($"Тип: {item.Type}");
                sb.AppendLine($"Модель: {item.Model}");
                foreach (CrewMember crewMember in item.Crew)
                {
                    sb.AppendLine(crewMember.ToString());
                }
                sb.AppendLine($"Вместимость: {item.PassengerCapacity}");
                sb.AppendLine($"Год основания: {item.YearOfManufacture}");
                sb.AppendLine($"Грузоподъемность: {item.PayloadCapacity}");
                sb.AppendLine($"Дата последнего ТО: {item.LastMaintenanceDate}");
                sb.AppendLine($"Информация о производителе: {item.ManufacturerInfo}");
                sb.AppendLine($"-------------------------------------------------------");
                sb.AppendLine();
            }
            SearchedTextbox.Text = sb.ToString();

            string searchResultsJson = JsonConvert.SerializeObject(results, Formatting.Indented);
            File.WriteAllText(searchResultsFilePath, searchResultsJson);

        }
    }




    public partial class Form6 : Form5
    {
        public Form6(Form1 form1) : base(form1) 
        {
            label2.Text = "вместимости";
        }

        protected override void button1_Click_1(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string searchResultsFilePath = "search_results.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItemsss = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            int numberToFind;

            List<Aircraft> results = new List<Aircraft>();

            if (!int.TryParse(SearchTextBox.Text, out numberToFind))
            {
                MessageBox.Show("Неверный формат числа.");
                return;
            }

            string numberPattern = @"\b" + numberToFind + @"\b";
            foreach (var item in dataItemsss)
            {
                ValidationContext validationContext = new ValidationContext(item);
                List<ValidationResult> validationResults = new List<ValidationResult>();

                bool isValid = Validator.TryValidateObject(item, validationContext, validationResults, true);

                if (isValid && Regex.IsMatch(item.PassengerCapacity.ToString(), numberPattern))
                {
                    results.Add(item);
                }
            }

            if (results.Count == 0)
            {
                MessageBox.Show("Ничего не найдено.");
                return;
            }

            StringBuilder sb = new StringBuilder();

            foreach (var item in results)
            {
                sb.AppendLine($"ID: {item.ID}");
                sb.AppendLine($"Тип: {item.Type}");
                sb.AppendLine($"Модель: {item.Model}");
                foreach (CrewMember crewMember in item.Crew)
                {
                    sb.AppendLine(crewMember.ToString());
                }
                sb.AppendLine($"Вместимость: {item.PassengerCapacity}");
                sb.AppendLine($"Год основания: {item.YearOfManufacture}");
                sb.AppendLine($"Грузоподъемность: {item.PayloadCapacity}");
                sb.AppendLine($"Дата последнего ТО: {item.LastMaintenanceDate}");
                sb.AppendLine($"Информация о производителе: {item.ManufacturerInfo}");
                sb.AppendLine($"-------------------------------------------------------");
                sb.AppendLine();
            }

            SearchedTextbox.Text = sb.ToString();

            string searchResultsJson = JsonConvert.SerializeObject(results, Formatting.Indented);
            File.WriteAllText(searchResultsFilePath, searchResultsJson);
        }
    }




    public partial class Form7 : Form6
    {
        public Form7(Form1 form1) : base(form1)
        {
            label2.Text = "типу(военный/пассажирский/грузовой)";
        }

        protected override void button1_Click_1(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string searchResultsFilePath = "search_results.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItemsss = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            string typeToFind = SearchTextBox.Text;

            List<Aircraft> results = new List<Aircraft>();

            string typePattern = @"\b" + Regex.Escape(typeToFind) + @"\b";

            foreach (var item in dataItemsss)
            {
                ValidationContext validationContext = new ValidationContext(item);
                List<ValidationResult> validationResults = new List<ValidationResult>();

                bool isValid = Validator.TryValidateObject(item, validationContext, validationResults, true);

                if (isValid && Regex.IsMatch(item.Type.ToString(), typeToFind))
                {
                    results.Add(item);
                }
            }

            if (results.Count == 0)
            {
                MessageBox.Show("Ничего не найдено.");
                return;
            }

            StringBuilder sb = new StringBuilder();

            foreach (var item in results)
            {
                sb.AppendLine($"ID: {item.ID}");
                sb.AppendLine($"Тип: {item.Type}");
                sb.AppendLine($"Модель: {item.Model}");
                foreach (CrewMember crewMember in item.Crew)
                {
                    sb.AppendLine(crewMember.ToString());
                }
                sb.AppendLine($"Вместимость: {item.PassengerCapacity}");
                sb.AppendLine($"Год основания: {item.YearOfManufacture}");
                sb.AppendLine($"Грузоподъемность: {item.PayloadCapacity}");
                sb.AppendLine($"Дата последнего ТО: {item.LastMaintenanceDate}");
                sb.AppendLine($"Информация о производителе: {item.ManufacturerInfo}");
                sb.AppendLine($"-------------------------------------------------------");
                sb.AppendLine();
            }
            SearchedTextbox.Text = sb.ToString();

            string searchResultsJson = JsonConvert.SerializeObject(results, Formatting.Indented);
            File.WriteAllText(searchResultsFilePath, searchResultsJson);
        }
    }



    public partial class Form8 : Form7
    {
        public Form8(Form1 form1) : base(form1)
        {
            label2.Text = "грузоподъёмности";
            Form1 = form1;
        }

        protected override void button1_Click_1(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string searchResultsFilePath = "search_results.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            int numberToFind;

            List<Aircraft> results = new List<Aircraft>();

            if (!int.TryParse(SearchTextBox.Text, out numberToFind))
            {
                MessageBox.Show("Неверный формат числа.");
                return;
            }

            results = dataItems.Where(item =>
            {
                ValidationContext validationContext = new ValidationContext(item);
                List<ValidationResult> validationResults = new List<ValidationResult>();

                bool isValid = Validator.TryValidateObject(item, validationContext, validationResults, true);

                return isValid && item.PayloadCapacity == numberToFind;
            }).ToList();

            if (results.Count == 0)
            {
                MessageBox.Show("Ничего не найдено.");
                return;
            }

            StringBuilder sb = new StringBuilder();

            foreach (var item in results)
            {
                sb.AppendLine($"ID: {item.ID}");
                sb.AppendLine($"Тип: {item.Type}");
                sb.AppendLine($"Модель: {item.Model}");
                foreach (CrewMember crewMember in item.Crew)
                {
                    sb.AppendLine(crewMember.ToString());
                }
                sb.AppendLine($"Вместимость: {item.PassengerCapacity}");
                sb.AppendLine($"Год основания: {item.YearOfManufacture}");
                sb.AppendLine($"Грузоподъемность: {item.PayloadCapacity}");
                sb.AppendLine($"Дата последнего ТО: {item.LastMaintenanceDate}");
                sb.AppendLine($"Информация о производителе: {item.ManufacturerInfo}");
                sb.AppendLine($"-------------------------------------------------------");
                sb.AppendLine();
            }
            SearchedTextbox.Text = sb.ToString();

            string searchResultsJson = JsonConvert.SerializeObject(results, Formatting.Indented);
            File.WriteAllText(searchResultsFilePath, searchResultsJson);
        }
    }


    public partial class Form9 : Form8
    {
        public Form9(Form1 form1) : base(form1)
        {
            label2.Text = "вместимости";
            Form1 = form1;
        }

        protected override void button1_Click_1(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string searchResultsFilePath = "search_results.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            int numberToFind;

            List<Aircraft> results = new List<Aircraft>();

            if (!int.TryParse(SearchTextBox.Text, out numberToFind))
            {
                MessageBox.Show("Неверный формат числа.");
                return;
            }

            results = dataItems.Where(item => item.PassengerCapacity == numberToFind).ToList();

            if (results.Count == 0)
            {
                MessageBox.Show("Ничего не найдено.");
                return;
            }

            StringBuilder sb = new StringBuilder();

            foreach (var item in results)
            {
                sb.AppendLine($"ID: {item.ID}");
                sb.AppendLine($"Тип: {item.Type}");
                sb.AppendLine($"Модель: {item.Model}");
                foreach (CrewMember crewMember in item.Crew)
                {
                    sb.AppendLine(crewMember.ToString());
                }
                sb.AppendLine($"Вместимость: {item.PassengerCapacity}");
                sb.AppendLine($"Год основания: {item.YearOfManufacture}");
                sb.AppendLine($"Грузоподъемность: {item.PayloadCapacity}");
                sb.AppendLine($"Дата последнего ТО: {item.LastMaintenanceDate}");
                sb.AppendLine($"Информация о производителе: {item.ManufacturerInfo}");
                sb.AppendLine($"-------------------------------------------------------");
                sb.AppendLine();
            }
            SearchedTextbox.Text = sb.ToString();

            string searchResultsJson = JsonConvert.SerializeObject(results, Formatting.Indented);
            File.WriteAllText(searchResultsFilePath, searchResultsJson);
        }
    }


    public partial class Form10 : Form9
    {
        public Form10(Form1 form1) : base(form1)
        {
            label2.Text = "типу самолета";
            Form1 = form1;
        }

        protected override void button1_Click_1(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string searchResultsFilePath = "search_results.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            string typeToFind = SearchTextBox.Text.Trim();

            List<Aircraft> results = dataItems.Where(item => item.Type.Equals(typeToFind, StringComparison.OrdinalIgnoreCase)).ToList();

            if (results.Count == 0)
            {
                MessageBox.Show("Ничего не найдено.");
                return;
            }

            StringBuilder sb = new StringBuilder();

            foreach (var item in results)
            {
                sb.AppendLine($"ID: {item.ID}");
                sb.AppendLine($"Тип: {item.Type}");
                sb.AppendLine($"Модель: {item.Model}");
                foreach (CrewMember crewMember in item.Crew)
                {
                    sb.AppendLine(crewMember.ToString());
                }
                sb.AppendLine($"Вместимость: {item.PassengerCapacity}");
                sb.AppendLine($"Год основания: {item.YearOfManufacture}");
                sb.AppendLine($"Грузоподъемность: {item.PayloadCapacity}");
                sb.AppendLine($"Дата последнего ТО: {item.LastMaintenanceDate}");
                sb.AppendLine($"Информация о производителе: {item.ManufacturerInfo}");
                sb.AppendLine($"-------------------------------------------------------");
                sb.AppendLine();
            }
            SearchedTextbox.Text = sb.ToString();

            string searchResultsJson = JsonConvert.SerializeObject(results, Formatting.Indented);
            File.WriteAllText(searchResultsFilePath, searchResultsJson);
        }
        
    }

    
}
