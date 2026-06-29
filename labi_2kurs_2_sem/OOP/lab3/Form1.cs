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
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;
using static lab2.Form5;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using Formatting = Newtonsoft.Json.Formatting;

namespace lab2
{
    public partial class Form1 : Form
    {

        private Aircraft aircraft;
        private List<CrewMember> crewMembers;
        private Manufacturer manufacturer;

        static List<Aircraft> dataItems = new List<Aircraft>();
        public static List<CrewMember> memberList = new List<CrewMember>();
        public StringBuilder sb = new StringBuilder();
        public StringBuilder sb1 = new StringBuilder();
        public static List<Manufacturer> manufacturers = new List<Manufacturer>();
        private int currentIndex = 0;

        private string lastAction = string.Empty;


        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        public class Aircraft
        {
            private static int lastId = 0;

            [AircraftIdValidation]
            public int ID { get; set; }
            public string Type { get; set; }
            public string Model { get; set; }
            public List<CrewMember> Crew { get; set; }
            public int PassengerCapacity { get; set; }
            public int YearOfManufacture { get; set; }

            [Range(0, int.MaxValue, ErrorMessage = "Грузоподъемность должна быть положительным числом.")]
            public int PayloadCapacity { get; set; }
            public DateTime LastMaintenanceDate { get; set; }

            [Required(ErrorMessage = "Год основания должен быть указан.")]
            public string ManufacturerInfo { get; set; }

            public Aircraft()
            {

            }
        }

        public class CrewMember
        {
            public string Name { get; set; }
            public string FirstName { get; set; }
            public string Patronomic { get; set; }
            public string Position { get; set; }
            public int Age { get; set; }
            public string Experience { get; set; }

            public override string ToString()
            {
                return $"{Name}, {FirstName}, {Patronomic}, {Position}, {Age}, {Experience}";
            }
        }

        public class Manufacturer
        {
            public string Name { get; set; }
            public string Country { get; set; }
            public int YearFounded { get; set; }
            public string AircraftTypes { get; set; }
        }

        private void trackBar1_Scroll(object sender, EventArgs e)
        {
            label5.Text = string.Format("Количество пассижирских мест: {0}", trackBar1.Value);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Form2 form2 = new Form2();
            if (form2.ShowDialog() == DialogResult.OK)
            {

                CrewMember lastMember = memberList.LastOrDefault();
                if (lastMember != null)
                {
                    sb.Clear();
                    sb.AppendLine($"Имя: {lastMember.Name}, Фамилия: {lastMember.FirstName}, Отчество: {lastMember.Patronomic}, Должность: {lastMember.Position}, Возраст: {lastMember.Age}, Стаж: {lastMember.Experience}");
                }

                textBox1.Text += sb.ToString();
            }
        }


        private List<CrewMember> ParseCrewMembers(string crewText)
        {
            List<CrewMember> crewMembers = new List<CrewMember>();

            string[] memberLines = crewText.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);

            foreach (string memberLine in memberLines)
            {
                string[] memberData = memberLine.Split(',');

                if (memberData.Length == 6)
                {
                    string name = memberData[0].Trim();
                    string firstName = memberData[1].Trim();
                    string patronomic = memberData[2].Trim();
                    string position = memberData[3].Trim();

                    int age;
                    bool isAgeValid = int.TryParse(memberData[4].Trim(), out age);

                    string experience = memberData[5].Trim();

                    if (!isAgeValid)
                    {
                        CrewMember crewMember = new CrewMember
                        {
                            Name = name,
                            FirstName = firstName,
                            Patronomic = patronomic,
                            Position = position,
                            Age = age,
                            Experience = experience
                        };

                        crewMembers.Add(crewMember);
                    }
                    else
                    {
                        MessageBox.Show("Ошибка в возрасте");
                    }
                }
                else
                {
                    MessageBox.Show("Не все данные введены");
                }
            }

            return crewMembers;
        }

        private void button3_Click(object sender, EventArgs e)
        {

            try
            {

                if (textBox1.Text == "" || textBox3.Text == "" || textBox4.Text == "" || comboBox1.Text == "")
                {
                    MessageBox.Show("Заполните форму");
                    return;
                }

                string a;

                if (radioButton1.Checked)
                {
                    a = radioButton1.Text;
                }
                else if (radioButton2.Checked)
                {
                    a = radioButton2.Text;
                }
                else
                {
                    a = radioButton3.Text;
                }

                int yearOfManufacture;
                bool isNum1Valid = int.TryParse(textBox3.Text, out yearOfManufacture);

                if (!isNum1Valid)
                {
                    MessageBox.Show("Неверный формат отчества");
                    return;
                }

                DateTime datee = dateTimePicker1.Value;
                if (Convert.ToInt32(textBox3.Text) >= datee.Year)
                {
                    MessageBox.Show("Год ТО должен быть больше, чем год выпуска");
                    return;
                }

                if (DateTime.Now <= datee)
                {
                    MessageBox.Show("Дата ТО должна быть быть меньше, чем нынешний момент");
                    return;
                }

                if (Convert.ToInt32(textBox3.Text) < manufacturers[0].YearFounded)
                {
                    MessageBox.Show("Самолёт не может быть выпущен раньше, чем основалась компания");
                    return;
                }

                List<CrewMember> crewMembers = ParseCrewMembers(textBox1.Text);

                List<Aircraft> existingDataItems;

                if (File.Exists("data.json"))
                {
                    string json = File.ReadAllText("data.json");
                    existingDataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);
                    if (existingDataItems == null)
                    {
                        existingDataItems = new List<Aircraft>();
                    }
                }
                else
                {
                    existingDataItems = new List<Aircraft>();
                }

                var newData = new Aircraft
                {
                    ID = existingDataItems.Count + 1,
                    Type = comboBox1.Text,
                    Model = a,
                    Crew = crewMembers,
                    PassengerCapacity = trackBar1.Value,
                    YearOfManufacture = yearOfManufacture,
                    LastMaintenanceDate = dateTimePicker1.Value,
                    PayloadCapacity = Convert.ToInt32(numericUpDown1.Value),
                    ManufacturerInfo = textBox4.Text
                };

                existingDataItems.Add(newData);

                string updatedJson = JsonConvert.SerializeObject(existingDataItems, Formatting.None);
                File.WriteAllText("data.json", updatedJson);

                textBox1.Clear();
                textBox3.Clear();
                textBox4.Clear();
            }
            catch
            {
                MessageBox.Show("Заполните форму");
            }
        }



        private void button2_Click(object sender, EventArgs e)
        {
            Form3 form3 = new Form3();
            if (form3.ShowDialog() == DialogResult.OK)
            {
                sb1.Clear();
                Manufacturer lastManufacturer = manufacturers.LastOrDefault();
                if (lastManufacturer != null)
                {
                    sb1.AppendLine($"Название: {lastManufacturer.Name}, Страна: {lastManufacturer.Country}, Год основания: {lastManufacturer.YearFounded}, Типы самолетов: {lastManufacturer.AircraftTypes}");
                }

                textBox4.Text += sb1.ToString();
            }
        }

        public static int count = 0;
        private void button4_Click(object sender, EventArgs e)
        {

            string jsonFilePath = "data.json";

            if (File.Exists(jsonFilePath))
            {
                string json = File.ReadAllText(jsonFilePath);
                List<Aircraft> dataItemss = JsonConvert.DeserializeObject<List<Aircraft>>(json);
                StringBuilder sbb = new StringBuilder();
                foreach (Aircraft aircraft in dataItemss)
                {
                    sbb.AppendLine($"ID: {aircraft.ID}");
                    sbb.AppendLine($"Тип: {aircraft.Type}");
                    sbb.AppendLine($"Модель: {aircraft.Model}");
                    sbb.AppendLine($"Экипаж:");

                    foreach (CrewMember crewMember in aircraft.Crew)
                    {
                        sbb.AppendLine(crewMember.ToString());
                    }

                    sbb.AppendLine($"Вместимость: {aircraft.PassengerCapacity}");
                    sbb.AppendLine($"Год основания: {aircraft.YearOfManufacture}");
                    sbb.AppendLine($"Грузоподёмность: {aircraft.PayloadCapacity}");
                    sbb.AppendLine($"Дата последнего ТО: {aircraft.LastMaintenanceDate}");
                    sbb.AppendLine($"Информация о производителе: {aircraft.ManufacturerInfo}");
                    sbb.AppendLine($"-------------------------------------------------------");
                }

                textBox2.Text = sbb.ToString();
            }
            else
            {
                textBox2.Text = "Файл JSON не найден.";
            }
        }

        private void ToolStripMenuItem_Click1(object sender, EventArgs e)
        {
            Form4 form4 = new Form4();
            if (form4.ShowDialog() == DialogResult.OK)
            {

            }


        }

        private void ToolStripMenuItem_Click2(object sender, EventArgs e)
        {
            Form5 form5 = new Form5(this);
            if (form5.ShowDialog() == DialogResult.OK)
            {
                
            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_Click3(object sender, EventArgs e)
        {
            Form6 form6 = new Form6(this);
            if (form6.ShowDialog() == DialogResult.OK)
            {
                
            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_Click4(object sender, EventArgs e)
        {
            Form7 form7 = new Form7(this);
            if (form7.ShowDialog() == DialogResult.OK)
            {
                
            }
            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_Click5(object sender, EventArgs e)
        {
            Form8 form8 = new Form8(this);
            if (form8.ShowDialog() == DialogResult.OK)
            {
                
            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_Click6(object sender, EventArgs e)
        {
            Form9 form9 = new Form9(this);
            if (form9.ShowDialog() == DialogResult.OK)
            {
                
            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_Click7(object sender, EventArgs e)
        {
            Form10 form10 = new Form10(this);
            if (form10.ShowDialog() == DialogResult.OK)
            {
                
            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        

        private void ToolStripMenuItem_Click8(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string sortedJsonFilePath = "sorted_data.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            if (dataItems == null || dataItems.Count == 0)
            {
                MessageBox.Show("Файл data.json не содержит данных.");
                return;
            }

            List<Aircraft> sortedDataItems = dataItems.OrderBy(item => item.YearOfManufacture).ToList();

            string sortedJson = JsonConvert.SerializeObject(sortedDataItems, Formatting.Indented);
            File.WriteAllText(sortedJsonFilePath, sortedJson);

            textBox2.Clear();

            StringBuilder sb = new StringBuilder();
            foreach (var item in sortedDataItems)
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
            textBox2.Text = sb.ToString();

            lastAction = "сортировка";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_Click9(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string sortedJsonFilePath = "sorted_data.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            if (dataItems == null || dataItems.Count == 0)
            {
                MessageBox.Show("Файл data.json не содержит данных.");
                return;
            }

            List<Aircraft> sortedDataItems = dataItems.OrderBy(item => item.LastMaintenanceDate.Year).ToList();

            string sortedJson = JsonConvert.SerializeObject(sortedDataItems, Formatting.Indented);
            File.WriteAllText(sortedJsonFilePath, sortedJson);

            textBox2.Clear();

            StringBuilder sb = new StringBuilder();
            foreach (var item in sortedDataItems)
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
            textBox2.Text = sb.ToString();

            lastAction = "сортировка";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_Click10(object sender, EventArgs e)
        {
            string version = "17.5.3";
            string developerName = "Осадчий Павел Андреевич";
            string message = $"Версия программы: {version}\nРазработчик: {developerName}";
            MessageBox.Show(message, "О программе", MessageBoxButtons.OK, MessageBoxIcon.Information);

            lastAction = "о программе";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_Click11(object sender, EventArgs e)
        {
            textBox1.Clear();
            textBox3.Clear();
            textBox4.Clear();

            lastAction = "очистка";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_Click12(object sender, EventArgs e)
        {

        }

        private void toolStripButton1_Click(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            if (dataItems.Count > 0)
            {
                dataItems.RemoveAt(dataItems.Count - 1);

                string jsonn = JsonConvert.SerializeObject(dataItems);
                File.WriteAllText("data.json", jsonn);
            }

            lastAction = "удаление последнего элемент";
            UpdateStatusStrip();
        }

        private void toolStripButton2_Click(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            if (currentIndex < dataItems.Count - 1)
            {
                currentIndex++;

                StringBuilder sb = new StringBuilder();

                sb.AppendLine($"ID: {dataItems[currentIndex].ID}");
                sb.AppendLine($"Тип: {dataItems[currentIndex].Type}");
                sb.AppendLine($"Модель: {dataItems[currentIndex].Model}");
                foreach (CrewMember crewMember in dataItems[currentIndex].Crew)
                    {
                        sb.AppendLine(crewMember.ToString());
                    }
                sb.AppendLine($"Вместимость: {dataItems[currentIndex].PassengerCapacity}");
                sb.AppendLine($"Год основания: {dataItems[currentIndex].YearOfManufacture}");
                sb.AppendLine($"Грузоподъемность: {dataItems[currentIndex].PayloadCapacity}");
                sb.AppendLine($"Дата последнего ТО: {dataItems[currentIndex].LastMaintenanceDate}");
                sb.AppendLine($"Информация о производителе: {dataItems[currentIndex].ManufacturerInfo}");
                sb.AppendLine($"-------------------------------------------------------");
                sb.AppendLine();

                textBox2.Text = sb.ToString();

                lastAction = "вперёд";
                UpdateStatusStrip();
            }
        }

        private void toolStripLabel1_Click(object sender, EventArgs e)
        {
            
        }

        private void toolStripButton3_Click(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            if (currentIndex > 0)
            {
                currentIndex--;

                StringBuilder sb = new StringBuilder();
                
                sb.AppendLine($"ID: {dataItems[currentIndex].ID}");
                sb.AppendLine($"Тип: {dataItems[currentIndex].Type}");
                sb.AppendLine($"Модель: {dataItems[currentIndex].Model}");
                foreach (CrewMember crewMember in dataItems[currentIndex].Crew)
                {
                    sb.AppendLine(crewMember.ToString());
                }
                sb.AppendLine($"Вместимость: {dataItems[currentIndex].PassengerCapacity}");
                sb.AppendLine($"Год основания: {dataItems[currentIndex].YearOfManufacture}");
                sb.AppendLine($"Грузоподъемность: {dataItems[currentIndex].PayloadCapacity}");
                sb.AppendLine($"Дата последнего ТО: {dataItems[currentIndex].LastMaintenanceDate}");
                sb.AppendLine($"Информация о производителе: {dataItems[currentIndex].ManufacturerInfo}");
                sb.AppendLine($"-------------------------------------------------------");
                sb.AppendLine();

                textBox2.Text = sb.ToString();

                lastAction = "назад";
                UpdateStatusStrip();
            }
        }

        private void toolStripStatusLabel1_Click(object sender, EventArgs e)
        {

        }

        private void UpdateStatusStrip()
        {
            string jsonFilePath = "data.json";
            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);
            int objectCount = dataItems.Count;
            string currentTime = DateTime.Now.ToString();

            string statusMessage = $"Количество объектов: {objectCount}, Последнее действие: {lastAction}, {currentTime}";
            toolStripStatusLabel1.Text = statusMessage;
        }

        private void button5_Click(object sender, EventArgs e)
        {
            if (toolStrip1.Visible)
            {
                toolStrip1.Hide();
            }
            else
            {
                toolStrip1.Show();
            }
        }

        private void toolStripButton4_Click(object sender, EventArgs e)
        {
            textBox1.Clear();
            textBox3.Clear();
            textBox4.Clear();

            lastAction = "очистка";
            UpdateStatusStrip();
        }

        private void toolStripButton5_Click(object sender, EventArgs e)
        {

        }

        private void ToolStripMenuItem_ClickPoisk1(object sender, EventArgs e)
        {
            Form5 form5 = new Form5(this);
            if (form5.ShowDialog() == DialogResult.OK)
            {

            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem1_ClickPoisk2(object sender, EventArgs e)
        {
            Form6 form6 = new Form6(this);
            if (form6.ShowDialog() == DialogResult.OK)
            {

            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem2_ClickPoisk3(object sender, EventArgs e)
        {
            Form7 form7 = new Form7(this);
            if (form7.ShowDialog() == DialogResult.OK)
            {

            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_ClickPoisk4(object sender, EventArgs e)
        {
            Form8 form8 = new Form8(this);
            if (form8.ShowDialog() == DialogResult.OK)
            {

            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_ClickPoisk5(object sender, EventArgs e)
        {
            Form9 form9 = new Form9(this);
            if (form9.ShowDialog() == DialogResult.OK)
            {

            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_ClickPoisk6(object sender, EventArgs e)
        {
            Form10 form10 = new Form10(this);
            if (form10.ShowDialog() == DialogResult.OK)
            {

            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem_ClickPoisk7(object sender, EventArgs e)
        {
            Form4 form4 = new Form4();
            if (form4.ShowDialog() == DialogResult.OK)
            {

            }

            lastAction = "поиск";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem1_ClickSort1(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string sortedJsonFilePath = "sorted_data.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            if (dataItems == null || dataItems.Count == 0)
            {
                MessageBox.Show("Файл data.json не содержит данных.");
                return;
            }

            List<Aircraft> sortedDataItems = dataItems.OrderBy(item => item.YearOfManufacture).ToList();

            string sortedJson = JsonConvert.SerializeObject(sortedDataItems, Formatting.Indented);
            File.WriteAllText(sortedJsonFilePath, sortedJson);

            textBox2.Clear();

            StringBuilder sb = new StringBuilder();
            foreach (var item in sortedDataItems)
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
            textBox2.Text = sb.ToString();

            lastAction = "сортировка";
            UpdateStatusStrip();
        }

        private void ToolStripMenuItem1_ClickSort2(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string sortedJsonFilePath = "sorted_data.json";

            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            if (dataItems == null || dataItems.Count == 0)
            {
                MessageBox.Show("Файл data.json не содержит данных.");
                return;
            }

            List<Aircraft> sortedDataItems = dataItems.OrderBy(item => item.LastMaintenanceDate.Year).ToList();

            string sortedJson = JsonConvert.SerializeObject(sortedDataItems, Formatting.Indented);
            File.WriteAllText(sortedJsonFilePath, sortedJson);

            textBox2.Clear();

            StringBuilder sb = new StringBuilder();
            foreach (var item in sortedDataItems)
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
            textBox2.Text = sb.ToString();

            lastAction = "сортировка";
            UpdateStatusStrip();
        }

        private void toolStripButton5_Click_1(object sender, EventArgs e)
        {
            string version = "17.5.3";
            string developerName = "Осадчий Павел Андреевич";
            string message = $"Версия программы: {version}\nРазработчик: {developerName}";
            MessageBox.Show(message, "О программе", MessageBoxButtons.OK, MessageBoxIcon.Information);

            lastAction = "о программе";
            UpdateStatusStrip();
        }

        private void button6_Click(object sender, EventArgs e)
        {
            if (toolStrip1.Dock == DockStyle.Bottom)
            {
                toolStrip1.Dock = DockStyle.Right;
                button6.Text = "закрепить снизу";
            }
            else
            {
                toolStrip1.Dock = DockStyle.Bottom;
                button6.Text = "закрепить справа";
            }
        }
    }


    public class AircraftIdValidationAttribute : ValidationAttribute
    {
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            if (value != null && value is string id)
            {
                if (int.TryParse(id, out _))
                {
                    return ValidationResult.Success;
                }
                else
                {
                    return new ValidationResult("ID самолета должно быть числом.");
                }
            }

            return ValidationResult.Success;
        }
    }
}
