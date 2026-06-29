const express = require('express');
const nodemailer = require('nodemailer');
const path = require('path');

const app = express();
const port = 3000;

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname)));


app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});


app.post('/send', (req, res) => {
  const { from, to, message } = req.body;


  let transporter = nodemailer.createTransport({
    service: 'mail.ru',  
    auth: {
      user: 'pashalab6noda@mail.ru',  
      pass: 'ATMEranzxUSMFXiPnUGX', 
    }
  });

  // Определяем параметры письма
  let mailOptions = {
    from: from,  
    to: to,
    subject: 'Message from Node.js App',
    html: `<p>${message}</p>`  
  };

  transporter.sendMail(mailOptions, (err, info) => {
    if (err) {
      console.error(err);  
      return res.status(500).send('Ошибка при отправке письма');
    }
    res.send('Письмо успешно отправлено');
  });
});


app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
