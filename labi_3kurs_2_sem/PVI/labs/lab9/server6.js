const express = require('express');
const multer = require('multer');
const fs = require('fs');

const app = express();
const port = 3006;

const upload = multer({ dest: 'uploads/' }); 

app.post('/', upload.single('myfile'), (req, res) => {
    const file = req.file;

    if (!file) {
        return res.status(400).send('Файл не получен');
    }

    // Чтение содержимого загруженного файла
    fs.readFile(file.path, 'utf8', (err, data) => {
        if (err) return res.status(500).send('Ошибка чтения файла');

        res.send(`Файл успешно получен!\nИмя файла: ${file.originalname}\nСодержимое:\n${data}`);
    });
});

app.listen(port, () => {
    console.log(`Сервер 09-06 запущен на http://localhost:${port}`);
});
