const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const db = require('./bd_file');

const app = express();
const PORT = 5000;

app.use(bodyParser.json());

app.use(express.static(path.join(__dirname)));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Получить все записи
app.get('/api/db', async (req, res) => {
    const records = await db.select();
    res.json(records);
});

// Добавить запись
app.post('/api/db', async (req, res) => {
    const { name, bday } = req.body;
    if (!name || !bday) return res.status(400).json({ error: "Поля 'name' и 'bday' обязательны" });

    const newRecord = await db.insert({ name, bday });
    res.json(newRecord);
});

// Обновить запись
app.put('/api/db', async (req, res) => {
    const { id, name, bday } = req.body;
    if (!id || !name || !bday) return res.status(400).json({ error: "Поля 'id', 'name' и 'bday' обязательны" });

    const updatedRecord = await db.update({ id, name, bday });
    if (updatedRecord) {
        res.json(updatedRecord);
    } else {
        res.status(404).json({ error: "Запись не найдена" });
    }
});

// Удалить запись
app.delete('/api/db', async (req, res) => {
    const id = parseInt(req.query.id);
    if (isNaN(id)) return res.status(400).json({ error: "Неверный ID" });

    const deletedRecord = await db.delete(id);
    if (deletedRecord) {
        res.json(deletedRecord);
    } else {
        res.status(404).json({ error: "Запись не найдена" });
    }
});

// Запуск сервера
app.listen(PORT, () => {
    console.log(`Сервер запущен на http://localhost:${PORT}`);
});
