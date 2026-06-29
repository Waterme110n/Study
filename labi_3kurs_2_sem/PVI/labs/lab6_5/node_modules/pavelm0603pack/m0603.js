
const nodemailer = require('nodemailer');

const SENDER_EMAIL = 'pashalab6noda@mail.ru';  
const RECIPIENT_EMAIL = 'pavelasadchy@gmail.com';  


const transporter = nodemailer.createTransport({
  service: 'mail.ru',  
  auth: {
    user: SENDER_EMAIL,
    pass: 'ATMEranzxUSMFXiPnUGX'    
  }
});


function send(message) {
  const mailOptions = {
    from: SENDER_EMAIL,       
    to: RECIPIENT_EMAIL,    
    subject: 'Message from Node.js App',  
    html: `<p>${message}</p>`,  
  };

  transporter.sendMail(mailOptions, (err, info) => {
    if (err) {
      console.error('Ошибка при отправке письма:', err);
    } else {
      console.log('Письмо отправлено успешно:', info);
    }
  });
}

module.exports = { send };
