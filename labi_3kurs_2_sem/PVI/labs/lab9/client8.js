const http = require('http');
const fs = require('fs');

const options = {
    hostname: 'localhost',
    port: 3008,
    path: '/download',
    method: 'GET'
};

const req = http.request(options, (res) => {
    if (res.statusCode === 200) {
        const fileStream = fs.createWriteStream('DownloadedFile.txt');
        res.pipe(fileStream);

        fileStream.on('finish', () => {
            console.log('Файл успешно получен и сохранён как DownloadedFile.txt');
        });
    } else {
        console.log(`Ошибка: статус ответа ${res.statusCode}`);
    }
});

req.on('error', (e) => {
    console.error(`Ошибка запроса: ${e.message}`);
});

req.end();
