const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 3008;

const filePath = path.join(__dirname, 'MyFile.txt');


if (!fs.existsSync(filePath)) {
    fs.writeFileSync(filePath, 'Привет! Это файл, отправленный сервером по GET-запросу.');
}

app.get('/download', (req, res) => {
    res.download(filePath, 'MyFile.txt', (err) => {
        if (err) {
            console.error('Ошибка при отправке файла:', err);
            res.status(500).send('Ошибка сервера');
        }
    });
});

app.listen(port, () => {
    console.log(`Сервер 09-08 запущен на http://localhost:${port}/download`);
});
