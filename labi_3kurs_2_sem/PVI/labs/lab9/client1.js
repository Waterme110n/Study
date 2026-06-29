const http = require('http');

const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/',
    method: 'GET'
};

const req = http.request(options, (res) => {
    console.log(`Статус: ${res.statusCode}`);
    console.log(`Сообщение: ${res.statusMessage}`);
    console.log(`IP: ${res.socket.remoteAddress}`);
    console.log(`Порт: ${res.socket.remotePort}`);

    res.setEncoding('utf8');
    res.on('data', (chunk) => {
        console.log(`Тело ответа: ${chunk}`);
    });
});

req.on('error', (error) => {
    console.error(`Ошибка: ${error.message}`);
});

req.end();
