const http = require('http');
const querystring = require('querystring');

const postData = querystring.stringify({
    x: 7,
    y: 3,
    s: 'строка'
});

const options = {
    hostname: 'localhost',
    port: 3002,
    path: '/',
    method: 'POST',
    headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(postData)
    }
};

const req = http.request(options, (res) => {
    console.log(`Статус: ${res.statusCode}`);

    res.setEncoding('utf8');
    res.on('data', (chunk) => {
        console.log(`Ответ: ${chunk}`);
    });
});

req.on('error', (error) => {
    console.error(`Ошибка: ${error.message}`);
});

req.write(postData);
req.end();
