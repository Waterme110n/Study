const http = require('http');

const x = 5;
const y = 10;

const options = {
    hostname: 'localhost',
    port: 3001,
    path: `/calculate?x=${x}&y=${y}`,
    method: 'GET'
};

const req = http.request(options, (res) => {
    console.log(`Статус: ${res.statusCode}`);

    res.setEncoding('utf8');
    res.on('data', (chunk) => {
        console.log(`Тело ответа: ${chunk}`);
    });
});

req.on('error', (error) => {
    console.error(`Ошибка: ${error.message}`);
});

req.end();
