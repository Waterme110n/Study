const http = require('http');

const postData = JSON.stringify({
    "__comment": "Запрос.Лабораторная работа 8/10",
    "x": 1,
    "y": 2,
    "s": "Соообщение",
    "m": ["a", "b", "c", "d"],
    "o": { "surname": "Иванов", "name": "Иван" }
});

const options = {
    hostname: 'localhost',
    port: 3004,
    path: '/',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
    }
};

const req = http.request(options, (res) => {
    console.log(`Статус: ${res.statusCode}`);

    res.setEncoding('utf8');
    res.on('data', (chunk) => {
        try {
            const response = JSON.parse(chunk);
            console.log('Ответ сервера:', response);
        } catch (err) {
            console.error('Ошибка парсинга ответа:', err.message);
        }
    });
});

req.on('error', (error) => {
    console.error(`Ошибка: ${error.message}`);
});

req.write(postData);
req.end();
