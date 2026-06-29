namespace Laba01
{
    partial class Form1
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            clear = new Button();
            firstnumber = new TextBox();
            secondnumber = new TextBox();
            result = new TextBox();
            label2 = new Label();
            label3 = new Label();
            save = new Button();
            extract = new Button();
            label1 = new Label();
            comboBox1 = new ComboBox();
            label4 = new Label();
            send = new Button();
            error2 = new Label();
            error1 = new Label();
            SuspendLayout();
            // 
            // clear
            // 
            clear.Location = new Point(442, 82);
            clear.Margin = new Padding(2);
            clear.Name = "clear";
            clear.Size = new Size(70, 27);
            clear.TabIndex = 5;
            clear.Text = "Clear";
            clear.UseVisualStyleBackColor = true;
            clear.Click += clear_Click;
            // 
            // firstnumber
            // 
            firstnumber.Location = new Point(21, 43);
            firstnumber.Margin = new Padding(2);
            firstnumber.Name = "firstnumber";
            firstnumber.Size = new Size(133, 23);
            firstnumber.TabIndex = 8;
            // 
            // secondnumber
            // 
            secondnumber.Location = new Point(302, 43);
            secondnumber.Margin = new Padding(2);
            secondnumber.Name = "secondnumber";
            secondnumber.Size = new Size(136, 23);
            secondnumber.TabIndex = 9;
            // 
            // result
            // 
            result.Location = new Point(516, 44);
            result.Margin = new Padding(2);
            result.Name = "result";
            result.ReadOnly = true;
            result.Size = new Size(268, 23);
            result.TabIndex = 10;
            // 
            // label2
            // 
            label2.Location = new Point(329, 21);
            label2.Margin = new Padding(2, 0, 2, 0);
            label2.Name = "label2";
            label2.Size = new Size(96, 20);
            label2.TabIndex = 12;
            label2.Text = "Значение 2";
            // 
            // label3
            // 
            label3.Location = new Point(617, 21);
            label3.Margin = new Padding(2, 0, 2, 0);
            label3.Name = "label3";
            label3.Size = new Size(96, 20);
            label3.TabIndex = 13;
            label3.Text = "Результат";
            // 
            // save
            // 
            save.Location = new Point(516, 82);
            save.Margin = new Padding(2);
            save.Name = "save";
            save.Size = new Size(137, 27);
            save.TabIndex = 15;
            save.Text = "Сохранить";
            save.UseVisualStyleBackColor = true;
            save.Click += save_Click;
            // 
            // extract
            // 
            extract.Location = new Point(657, 82);
            extract.Margin = new Padding(2);
            extract.Name = "extract";
            extract.Size = new Size(127, 26);
            extract.TabIndex = 16;
            extract.Text = "Извлечь";
            extract.UseVisualStyleBackColor = true;
            extract.Click += extract_Click;
            // 
            // label1
            // 
            label1.Location = new Point(21, 21);
            label1.Margin = new Padding(2, 0, 2, 0);
            label1.Name = "label1";
            label1.Size = new Size(96, 20);
            label1.TabIndex = 17;
            label1.Text = "Значение 1";
            // 
            // comboBox1
            // 
            comboBox1.FormattingEnabled = true;
            comboBox1.Items.AddRange(new object[] { "+", "-", "*", "/", "остаток от деления", "целая часть от деления" });
            comboBox1.Location = new Point(158, 43);
            comboBox1.Margin = new Padding(2);
            comboBox1.Name = "comboBox1";
            comboBox1.Size = new Size(140, 23);
            comboBox1.TabIndex = 18;
            comboBox1.Text = "+";
            // 
            // label4
            // 
            label4.Location = new Point(179, 21);
            label4.Margin = new Padding(2, 0, 2, 0);
            label4.Name = "label4";
            label4.Size = new Size(85, 16);
            label4.TabIndex = 19;
            label4.Text = "Операция";
            // 
            // send
            // 
            send.Location = new Point(442, 43);
            send.Margin = new Padding(2);
            send.Name = "send";
            send.Size = new Size(70, 23);
            send.TabIndex = 7;
            send.Text = "=";
            send.UseVisualStyleBackColor = true;
            send.Click += send_Click;
            // 
            // error2
            // 
            error2.ForeColor = Color.Red;
            error2.Location = new Point(302, 82);
            error2.Margin = new Padding(2, 0, 2, 0);
            error2.Name = "error2";
            error2.Size = new Size(133, 61);
            error2.TabIndex = 21;
            // 
            // error1
            // 
            error1.ForeColor = Color.Red;
            error1.Location = new Point(21, 82);
            error1.Margin = new Padding(2, 0, 2, 0);
            error1.Name = "error1";
            error1.Size = new Size(133, 61);
            error1.TabIndex = 20;
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = SystemColors.Control;
            ClientSize = new Size(799, 163);
            Controls.Add(error2);
            Controls.Add(error1);
            Controls.Add(label4);
            Controls.Add(comboBox1);
            Controls.Add(label1);
            Controls.Add(extract);
            Controls.Add(save);
            Controls.Add(label3);
            Controls.Add(label2);
            Controls.Add(result);
            Controls.Add(secondnumber);
            Controls.Add(firstnumber);
            Controls.Add(send);
            Controls.Add(clear);
            Location = new Point(15, 15);
            Margin = new Padding(2);
            Name = "Form1";
            ResumeLayout(false);
            PerformLayout();
        }

        private System.Windows.Forms.ComboBox comboBox1;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Button send;

        private System.Windows.Forms.Label label1;

        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button save;
        private System.Windows.Forms.Button extract;

        private System.Windows.Forms.TextBox result;

        private System.Windows.Forms.TextBox firstnumber;
        private System.Windows.Forms.TextBox secondnumber;

        private System.Windows.Forms.Button clear;

        private System.Windows.Forms.Label error2;
        private System.Windows.Forms.Label error1;

        #endregion
    }
}
