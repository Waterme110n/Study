const fs = require('fs');
const http = require('http');
const FormData = require('form-data');

const form = new FormData();
form.append('myfile', fs.createReadStream('MyFile.txt'));

const options = {
    method: 'POST',
    hostname: 'localhost',
    port: 3006,
    path: '/',
    headers: form.getHeaders()
};

const req = http.request(options, (res) => {
    console.log(`Статус ответа: ${res.statusCode}`);
    res.setEncoding('utf8');
    res.on('data', (chunk) => {
        console.log('Ответ сервера:\n', chunk);
    });
});

form.pipe(req);

req.on('error', (e) => {
    console.error(`Ошибка: ${e.message}`);
});
