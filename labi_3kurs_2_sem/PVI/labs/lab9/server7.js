const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 3007;


const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/'); 
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname); 
    }
    
});
const upload = multer({ storage: storage });
app.post('/', upload.single('image'), (req, res) => {
    if (!req.file) {
        return res.status(400).send('Файл не был получен');
    }

    const fileSizeMB = (req.file.size / 1024 / 1024).toFixed(2);

    res.send(`Файл ${req.file.originalname} успешно загружен.\nРазмер: ${fileSizeMB} МБ\nСохранено как: ${req.file.filename}`);
});

app.listen(port, () => {
    console.log(`Сервер 09-07 запущен на http://localhost:${port}`);
});
