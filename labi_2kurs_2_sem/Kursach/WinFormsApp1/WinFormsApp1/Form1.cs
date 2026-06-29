using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.Button;

namespace WinFormsApp1
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            dateTimePicker1.Format = DateTimePickerFormat.Custom;
            dateTimePicker1.CustomFormat = "dd.MM.yyyy HH:mm";

            string[] countries = { "Италия", "Франция", "Германия", "Беларусь", "Канада", "Латвия" };
            listBox1.Items.AddRange(countries);

            string[] numbers = { "1", "2", "3", "4", "5", "6" };
            listBox2.Items.AddRange(numbers);

            ToolStripMenuItem delete = new ToolStripMenuItem("Delete");
            ToolStripMenuItem sort = new ToolStripMenuItem("Sort");

            contextMenuStrip1.Items.AddRange(new ToolStripItem[] { delete, sort });

            listBox1.ContextMenuStrip = contextMenuStrip1;
            delete.Click += DeleteMenu_Click;
            sort.Click += SortMenu_Click;
        }


        private void Form1_Load(object sender, EventArgs e)
        {
            this.Cursor = Cursors.Hand;
        }

        private void formc_lick(object sender, EventArgs e)
        {
            this.Size = new Size(this.Width + 10, this.Height + 10);
        }


        private void SortMenu_Click(object sender, EventArgs e)
        {
            listBox1.Sorted = true;
        }

        private void DeleteMenu_Click(object sender, EventArgs e)
        {
            if (listBox1.SelectedItem != null)
            {
                listBox1.Items.Remove(listBox1.SelectedItem);
            }
        }

        private void dateTimePicker1_ValueChanged(object sender, EventArgs e)
        {
            DateTime selectedTime = dateTimePicker1.Value;
            if (selectedTime.Hour < 12)
            {
                label1.Text = "До полудня";
            }
            else
            {
                label1.Text = "После полудня";
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            dateTimePicker1.Value = dateTimePicker1.Value.AddDays(10);
        }

        private void button2_Click(object sender, EventArgs e)
        {
            string text = textBox1.Text;
            if (!string.IsNullOrEmpty(text))
            {
                int half = text.Length / 2;
                string first = text.Substring(0, half);
                string second = text.Substring(half);
                label2.Text = first;
                label3.Text = second;
            }
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            label4.Text = comboBox1.SelectedItem as string;
            comboBox1.Items.RemoveAt(comboBox1.SelectedIndex);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            string FstPass = textBox2.Text;
            string SecPass = textBox3.Text;

            if (FstPass != SecPass)
            {
                label5.Text = "uncorrect password";
            }
            else if (FstPass.Length < 6 || FstPass.Length > 12)
            {
                label5.Text = ">6 < 12";
            }

            else if (!FstPass.Any(char.IsLetter) || !FstPass.Any(char.IsDigit))
            {
                label5.Text = "uncorrect asd";
            }
            else
            {
                label5.Text = "all correct";
            }
        }
        private void button4_Click_1(object sender, EventArgs e)
        {
            string[] names = { "Anna", "Alex", "Bob", "Alice", "John", "Amy", "Michael" };
            var a = names.Where(name => name.StartsWith("A")).ToList();
            var change = names.Select(name => name == "Alice" ? "Popa" : name).ToList();
            label5.Text = string.Join(", ", change);
        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {
            pictureBox2.Image = pictureBox1.Image;
            pictureBox1.Image = null;
        }

        private void pictureBox2_Click(object sender, EventArgs e)
        {
            pictureBox1.Image = pictureBox2.Image;
            pictureBox2.Image = null;
        }

        private void listBox2_SelectedIndexChanged(object sender, EventArgs e)
        {



            int selectedNumber = int.Parse(listBox2.SelectedItem.ToString());
            long factorial = CountFactorial(selectedNumber);
            textBox1.Text = factorial.ToString();
        }

        private long CountFactorial(int number)
        {

            long factorial = 1;
            for (int i = 1; i <= number; i++)
            {
                factorial *= i;
            }
            return factorial;
        }

        private void button5_Click(object sender, EventArgs e)
        {
            label5.Text = DateTime.Now.Minute.ToString();

        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {
            toolStrip1.Text = " ";
            this.Text = "";

            string a = textBox1.Text;
            foreach (char c in a)
            {
                if (char.IsDigit(c))
                {
                    toolStrip1.Text += c;
                }
            }
            foreach (char c in a)
            {
                if (char.IsLetter(c))
                {
                    this.Text += c;
                }
            }
        }

        int currentCheckBox = 1;
        private void timer1_Tick(object sender, EventArgs e)
        {
            switch (currentCheckBox)
            {
                case 1:
                    checkBox1.Checked = true;
                    checkBox2.Checked = false;
                    checkBox3.Checked = false;
                    break;
                case 2:
                    checkBox1.Checked = false;
                    checkBox2.Checked = true;
                    checkBox3.Checked = false;
                    break;
                case 3:
                    checkBox1.Checked = false;
                    checkBox2.Checked = false;
                    checkBox3.Checked = true;
                    break;
            }

            currentCheckBox++;
            if (currentCheckBox > 3)
            {
                currentCheckBox = 1;
            }

        }

        private void toolStripLabel1_Click(object sender, EventArgs e)
        {

        }

        private void comboBox2_SelectedIndexChanged(object sender, EventArgs e)
        {
            string choosedEl = comboBox2.SelectedItem.ToString();
            toolStripStatusLabel1.Text = choosedEl;
        }

        private void toolStripStatusLabel1_Click(object sender, EventArgs e)
        {

        }
    }

}

