namespace WinFormsApp2
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            int asd = int.Parse(textBox1.Text.ToString());
            double result = 0;
            if (radioButton1.Checked)
            {
                result = Math.Sin(asd);
                label1.Text = result.ToString();
            }
            else if (radioButton2.Checked)
            {
                result = Math.Cos(asd);
                label1.Text = result.ToString();
            }
            else if (radioButton3.Checked)
            {
                result = Math.Tan(asd);
                label1.Text = result.ToString();
            }
            else if (radioButton4.Checked)
            {
                result = 1 / Math.Tan(asd);
                label1.Text = result.ToString();
            }
            else if (radioButton5.Checked)
            {
                label1.Text = "Поставьте пожалуйста " + asd;
            }
        }
    }
}
