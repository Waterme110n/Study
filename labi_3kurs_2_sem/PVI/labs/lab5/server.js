const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const db = require('./db_file');
const readline = require('readline');
const http = require('http');

const app = express();
const server = http.createServer(app);
const PORT = 5000;

// Статистика
let stats = {
    startTime: null,
    endTime: null,
    requestCount: 0,
    commitCount: 0
};

// Таймеры
let shutdownTimer = null;
let commitInterval = null;
let statsTimeout = null;

//  для сбора статистики
app.use((req, res, next) => {
    if (stats.startTime && !stats.endTime) {
        stats.requestCount++;
    }
    next();
});

app.use(bodyParser.json());
app.use(express.static(path.join(__dirname)));

// Маршруты
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/api/db', async (req, res) => {
    const records = await db.select();
    res.json(records);
});

app.post('/api/db', async (req, res) => {
    const { name, bday } = req.body;
    if (!name || !bday) return res.status(400).json({ error: "Поля 'name' и 'bday' обязательны" });
    const newRecord = await db.insert({ name, bday });
    res.json(newRecord);
});

app.put('/api/db', async (req, res) => {
    const { id, name, bday } = req.body;
    if (!id || !name || !bday) return res.status(400).json({ error: "Поля 'id', 'name' и 'bday' обязательны" });
    const updatedRecord = await db.update({ id, name, bday });
    updatedRecord ? res.json(updatedRecord) : res.status(404).json({ error: "Запись не найдена" });
});

app.delete('/api/db', async (req, res) => {
    const id = parseInt(req.query.id);
    if (isNaN(id)) return res.status(400).json({ error: "Неверный ID" });
    const deletedRecord = await db.delete(id);
    deletedRecord ? res.json(deletedRecord) : res.status(404).json({ error: "Запись не найдена" });
});

app.get('/api/ss', (req, res) => {
    res.json({
        start: stats.startTime?.toISOString() || null,
        finish: stats.endTime?.toISOString() || null,
        request: stats.requestCount,
        commit: stats.commitCount
    });
});

// Обработка команд
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.on('line', (input) => {
    const [cmd, param] = input.trim().split(' ');
    
    // Остановка сервера
    if (cmd === 'sd') {
        if (shutdownTimer) clearTimeout(shutdownTimer);
        if (!param) {
            console.log('Отмена остановки сервера');
            return;
        }
        shutdownTimer = setTimeout(() => {
            server.close(() => {
                console.log('Сервер остановлен');
                process.exit(0);
            });
        }, param * 1000);
        shutdownTimer.unref();
        console.log(`Сервер остановится через ${param} сек`);
    }
    
    // Периодический коммит
    else if (cmd === 'sc') {
        if (commitInterval) clearInterval(commitInterval);
        if (!param) {
            console.log('Периодический коммит отменён');
            return;
        }
        commitInterval = setInterval(async () => {
            await db.commit();
            stats.commitCount++;
            console.log('Выполнен COMMIT');
        }, param * 1000);
        commitInterval.unref();
        console.log(`Коммит каждые ${param} сек`);
    }
    
    // Сбор статистики
    else if (cmd === 'ss') {
        if (statsTimeout) clearTimeout(statsTimeout);
        if (!param) {
            stats.endTime = new Date();
            console.log('Сбор статистики остановлен');
            return;
        }
        stats.startTime = new Date();
        stats.endTime = null;
        stats.requestCount = 0;
        stats.commitCount = 0;
        statsTimeout = setTimeout(() => {
            stats.endTime = new Date();
            console.log('Сбор статистики завершён');
        }, param * 1000);
        statsTimeout.unref();
        console.log(`Сбор статистики на ${param} сек`);
    }
});

// Запуск сервера
server.listen(PORT, () => {
    console.log(`Сервер запущен на http://localhost:${PORT}`);
});