using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection.Emit;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml.Linq;
using static lab2.Form1;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace lab2
{
    public partial class Form3 : Form
    {
        public Form3()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Form1 form1 = new Form1();
            try
            {
                if (textBox1.Text == "" || textBox2.Text == "" || textBox3.Text == "")
                {
                    MessageBox.Show("Заполните форму");
                    return;
                }

                string name = textBox1.Text;
                if (!IsValidName(name))
                {
                    MessageBox.Show("Неверный формат названия");
                    return;
                }

                string country = textBox2.Text;
                if (!IsValidName(country))
                {
                    MessageBox.Show("Неверный формат страны");
                    return;
                }

                int yearFound;
                bool isYearValid = int.TryParse(textBox3.Text, out yearFound);
                if (!isYearValid)
                {
                    MessageBox.Show("Неверный формат страны");
                    return;
                }

                if(Convert.ToInt32(textBox3.Text) >= 2024 || Convert.ToInt32(textBox3.Text) < 1800)
                {
                    MessageBox.Show("Неверное значение года выпуска");
                    return;
                }

                string selectedItems = "";

                foreach (var item in checkedListBox1.CheckedItems)
                {
                    selectedItems += item.ToString() + ", ";
                }

                var manufItem = new Manufacturer
                {
                    Name = name,
                    Country = country,
                    YearFounded = yearFound,
                    AircraftTypes = selectedItems,
                };

                manufacturers.Add(manufItem);

                DialogResult = DialogResult.OK;
            }
            catch
            {
                MessageBox.Show("Заполните форму");
            }
        }

        private bool IsValidName(string input)
        {
            return !Regex.IsMatch(input, @"\d");
        }
    }
}
