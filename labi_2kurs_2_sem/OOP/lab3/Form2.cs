using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using static lab2.Form1;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace lab2
{
    public partial class Form2 : Form
    {
        Form1 form1 = new Form1();
        public Form2()
        {
            InitializeComponent();
            checkedListBox1.SelectionMode = SelectionMode.One;
        }
   
        private void button1_Click(object sender, EventArgs e)
        {
            try
            {

                if (textBox1.Text == "" || textBox2.Text == "" || textBox4.Text == "")
                {
                    MessageBox.Show("Заполните форму");
                    return;
                }

                string name = textBox1.Text;
                if (!IsValidName(name))
                {
                    MessageBox.Show("Неверный формат фамилии");
                    return;
                }

                string firstName = textBox2.Text;
                if (!IsValidName(firstName))
                {
                    MessageBox.Show("Неверный формат имени");
                    return;

                }

                string patronomic = textBox3.Text;
                if (!IsValidName(patronomic))
                {
                    MessageBox.Show("Неверный формат отчества");
                    return;
                }

                string b;
                if (checkBox1.Checked)
                {
                    b = checkBox1.Text;
                }
                else
                {
                    b = checkBox2.Text;
                }

                string selectedItems = "";

                foreach (var item in checkedListBox1.CheckedItems)
                {
                    selectedItems += item.ToString();
                }

                int age;
                bool isAgeValid = int.TryParse(textBox4.Text, out age);
                if (!isAgeValid)
                {
                    MessageBox.Show("Неверный формат возраста");
                    return;
                }


                if(Convert.ToInt32(textBox4.Text) < 18)
                {
                    MessageBox.Show("Возраст должен быть не меньше 18 лет");
                    return;
                }

                if (Convert.ToInt32(textBox4.Text) > 100)
                {
                    MessageBox.Show("Возраст должен быть не больше 100 лет");
                    return;
                }

                if (Convert.ToInt32(textBox4.Text) <= 23 && checkBox2.Checked){
                    MessageBox.Show("Недопустимое значене стажа относительно возраста");
                    return;
                }


                var newItem = new CrewMember
                {
                    Name = firstName,
                    FirstName = name,
                    Patronomic = patronomic,
                    Position = Convert.ToString(selectedItems),
                    Age = age,
                    Experience = b,
                };

                memberList.Add(newItem);
                DialogResult = DialogResult.OK;

            }
            catch
            {
                MessageBox.Show("Заполните форму");
            }
            

        }

        public bool IsValidName(string input)
        {
            return !Regex.IsMatch(input, @"\d");
        }



        private void Form2_FormClosing(object sender, FormClosingEventArgs e)
        {
            
        }

        private void checkedListBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (checkedListBox1.CheckedItems.Count > 1)
            {
                for (int i = 0; i < checkedListBox1.Items.Count; i++)
                {
                    checkedListBox1.SetItemChecked(i, false);
                }
                checkedListBox1.SetItemChecked(checkedListBox1.SelectedIndex, true);
            }
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            if (checkBox1.Checked)
            {
                checkBox2.Checked = false;
            }
        }

        private void checkBox2_CheckedChanged(object sender, EventArgs e)
        {
            if (checkBox2.Checked)
            {
                checkBox1.Checked = false;
            }
        }
    }



}
