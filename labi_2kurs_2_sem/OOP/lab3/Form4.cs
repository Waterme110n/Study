using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using static lab2.Form1;

namespace lab2
{
    public partial class Form4 : Form
    {
        public int aircraftIndex;
        public List<string> a;

        public Form4()
        {
            InitializeComponent();
            a = new List<string>();
        }

        private void Form4_Load(object sender, EventArgs e)
        {

        }

        private void radioButton1_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            string jsonFilePath = "data.json";
            string json = File.ReadAllText(jsonFilePath);
            List<Aircraft> dataItemsss = JsonConvert.DeserializeObject<List<Aircraft>>(json);

            string airlineName = textBox1.Text;
            string aircraftType = radioButton1.Checked ? "пассажирский" : radioButton2.Checked ? "грузовой" : "военный";
            int minSeatCount, maxSeatCount;
            double payloadCapacity;
            
            int.TryParse(textBox2.Text, out minSeatCount);
            int.TryParse(textBox3.Text, out maxSeatCount);
            double.TryParse(textBox4.Text, out payloadCapacity);

            string pattern = @"Название\s*:\s*(.*?),";
            string b;
            string c;
            for (int i = 0; i < dataItemsss.Count; i++)
            {
                b = dataItemsss[i].ManufacturerInfo;
                Match match = Regex.Match(b, pattern);
                if (match.Success)
                {
                    c = match.Groups[1].Value;
                    a.Add(c);
                }
            }

            aircraftIndex = dataItemsss.FindIndex(item =>
                (string.IsNullOrEmpty(airlineName) || a.Contains(airlineName)) &&
                (string.IsNullOrEmpty(aircraftType) || item.Type == aircraftType) &&
                (minSeatCount == 0 || item.PassengerCapacity >= minSeatCount) &&
                (maxSeatCount == 0 || item.PassengerCapacity <= maxSeatCount) &&
                (payloadCapacity == 0 || item.PayloadCapacity >= payloadCapacity)
            );

            if (aircraftIndex != -1 && aircraftIndex < dataItemsss.Count)
            {
                StringBuilder sbbb = new StringBuilder();
                sbbb.AppendLine($"ID: {dataItemsss[aircraftIndex].ID}");
                sbbb.AppendLine($"Тип: {dataItemsss[aircraftIndex].Type}");
                sbbb.AppendLine($"Модель: {dataItemsss[aircraftIndex].Model}");
                foreach (CrewMember crewMember in dataItemsss[aircraftIndex].Crew)
                {
                    sbbb.AppendLine(crewMember.ToString());
                }
                sbbb.AppendLine($"Вместимость: {dataItemsss[aircraftIndex].PassengerCapacity}");
                sbbb.AppendLine($"Год основания: {dataItemsss[aircraftIndex].YearOfManufacture}");
                sbbb.AppendLine($"Грузоподёмность: {dataItemsss[aircraftIndex].PayloadCapacity}");
                sbbb.AppendLine($"Дата последнего ТО: {dataItemsss[aircraftIndex].LastMaintenanceDate}");
                sbbb.AppendLine($"Информация о производителе: {dataItemsss[aircraftIndex].ManufacturerInfo}");
                sbbb.AppendLine($"-------------------------------------------------------");
                sbbb.AppendLine();

                textBox5.Text  = sbbb.ToString();
            }
            else
            {
                MessageBox.Show("ошибка");
                return;
            }
        }
    }


}
