using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;
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


        public Form1()
        {
            InitializeComponent();
        }

        

        public class Aircraft
        {
            private static int lastId = 0;

            public int ID { get; set; }
            public string Type { get; set; }
            public string Model { get; set; }
            public List<CrewMember> Crew { get; set; }
            public int PassengerCapacity { get; set; }
            public int YearOfManufacture { get; set; }
            public int PayloadCapacity { get; set; }
            public DateTime LastMaintenanceDate { get; set; }
            public string ManufacturerInfo { get; set; }

            public Aircraft()
            {
                Crew = new List<CrewMember>();
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



        private void trackBar1_Scroll(object sender, EventArgs e)
        {
            label5.Text = string.Format("Количество пассижирских мест: {0}", trackBar1.Value);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Form2 form2 = new Form2();
            if (form2.ShowDialog() == DialogResult.OK) {
                CrewMember lastMember = memberList.LastOrDefault();
                if (lastMember != null)
                {
                    sb.Clear();
                    sb.AppendLine($"Имя: {lastMember.Name}, Фамилия: {lastMember.FirstName}, Отчество: {lastMember.Patronomic}, Должность: {lastMember.Position}, Возраст: {lastMember.Age}, Стаж: {lastMember.Experience}");
                }

                textBox1.Text += sb.ToString();
            }          
        }

        private void button3_Click(object sender, EventArgs e)
        {
            if (textBox1.Text == "")
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
            if (yearOfManufacture >= datee.Year)
            {
                MessageBox.Show("Год ТО должен быть больше, чем год выпуска");
                return;
            }

            if (DateTime.Now <= datee)
            {
                MessageBox.Show("Дата ТО должна быть меньше, чем нынешний момент");
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
            };

            existingDataItems.Add(newData);

            string updatedJson = JsonConvert.SerializeObject(existingDataItems, Formatting.None);
            File.WriteAllText("data.json", updatedJson);

            textBox1.Clear();
            textBox3.Clear();
        }



        public static int count = 0;
        private void button4_Click(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";

            if (File.Exists(jsonFilePath))
            {
                string json = File.ReadAllText(jsonFilePath);

                List<Aircraft> dataItems = JsonConvert.DeserializeObject<List<Aircraft>>(json);

                StringBuilder sb = new StringBuilder();

                foreach (Aircraft aircraft in dataItems)
                {
                    sb.AppendLine($"ID: {aircraft.ID}");
                    sb.AppendLine($"Тип: {aircraft.Type}");
                    sb.AppendLine($"Модель: {aircraft.Model}");
                    sb.AppendLine($"Экипаж:");

                    foreach (CrewMember crewMember in aircraft.Crew)
                    {
                        sb.AppendLine(crewMember.ToString());
                    }

                    sb.AppendLine($"Вместимость: {aircraft.PassengerCapacity}");
                    sb.AppendLine($"Год основания: {aircraft.YearOfManufacture}");
                    sb.AppendLine($"Грузоподёмность: {aircraft.PayloadCapacity}");
                    sb.AppendLine($"Дата последнего ТО: {aircraft.LastMaintenanceDate}");
                    sb.AppendLine($"Информация о производителе: {aircraft.ManufacturerInfo}");
                    sb.AppendLine($"-------------------------------------------------------");
                }

                textBox2.Text = sb.ToString();
            }
            else
            {
                textBox2.Text = "Файл JSON не найден.";
            }
        }


    }
}
