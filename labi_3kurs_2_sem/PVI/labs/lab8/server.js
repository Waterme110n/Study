const express = require('express');
const app = express();
const PORT = 3000;
const fs = require('fs');
const path = require('path');
const multer = require('multer');
const bodyParser = require('body-parser');
const xml2js = require('xml2js');

app.use(bodyParser.text({ type: 'application/xml' }));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// 01 
// Получение и установка параметра KeepAliveTimeout
app.get('/connection', (req, res) => {
    const keepAliveTimeout = app.get('keepAliveTimeout') || 5000; 
    res.send(`Текущее значение KeepAliveTimeout: ${keepAliveTimeout} мс`);
});

app.get('/connection/set=:set', (req, res) => {
    const newTimeout = parseInt(req.params.set, 10);
    if (!isNaN(newTimeout)) {
        app.set('keepAliveTimeout', newTimeout);
        res.send(`Установлено новое значение KeepAliveTimeout = ${newTimeout} мс`);
    } else {
        res.status(400).send('Ошибка: неверное значение таймаута');
    }
});

// 02
// Заголовки запроса и ответа
app.get('/headers', (req, res) => {
    const requestHeaders = JSON.stringify(req.headers, null, 2);
    res.set('X-Custom-Header', 'NodeJS-Lab-Header');

    res.send(`
        <h1>Заголовки запроса:</h1>
        <pre>${requestHeaders}</pre>
        <h1>Заголовки ответа:</h1>
        <pre>${JSON.stringify(res.getHeaders(), null, 2)}</pre>
    `);
});

// 03
// Работа с параметрами x и y
app.get('/parameter', (req, res) => {
    const { x, y } = req.query;

    const numX = parseFloat(x);
    const numY = parseFloat(y);

    if (!isNaN(numX) && !isNaN(numY)) {
        const sum = numX + numY;
        const diff = numX - numY;
        const prod = numX * numY;
        const quot = numY !== 0 ? (numX / numY).toFixed(2) : 'деление на 0';

        res.send(`
            <h1>Результат:</h1>
            <p>Сумма: ${sum}</p>
            <p>Разность: ${diff}</p>
            <p>Произведение: ${prod}</p>
            <p>Частное: ${quot}</p>
        `);
    } else {
        res.status(400).send('Ошибка: x и y должны быть числами');
    }
});

// 04
// Работа с параметрами x и y (в URI)
app.get('/parameter/:x/:y', (req, res) => {
    const { x, y } = req.params;

    const numX = parseFloat(x);
    const numY = parseFloat(y);

    if (!isNaN(numX) && !isNaN(numY)) {
        const sum = numX + numY;
        const diff = numX - numY;
        const prod = numX * numY;
        const quot = numY !== 0 ? (numX / numY).toFixed(2) : 'деление на 0';

        res.send(`
            <h1>Результат:</h1>
            <p>Сумма: ${sum}</p>
            <p>Разность: ${diff}</p>
            <p>Произведение: ${prod}</p>
            <p>Частное: ${quot}</p>
        `);
    } else {
        res.send(`<h1>Ошибка: x и y должны быть числами</h1><p>URI: ${req.originalUrl}</p>`);
    }
});

// 05
// Закрытие сервера через 10 секунд
app.get('/close', (req, res) => {
    res.send('<h1>Сервер будет остановлен через 10 секунд...</h1>');
    console.log('Сервер завершит работу через 10 секунд...');
    setTimeout(() => {
        console.log('Сервер остановлен.');
        process.exit(0);
    }, 10000);
});

// 06
// Отображение IP и портов клиента и сервера
app.get('/socket', (req, res) => {
    const clientIp = req.socket.remoteAddress;
    const clientPort = req.socket.remotePort;

    const serverIp = req.socket.localAddress;
    const serverPort = req.socket.localPort;

    res.send(`
        <h1>Информация о сокете:</h1>
        <p>IP клиента: ${clientIp}</p>
        <p>Порт клиента: ${clientPort}</p>
        <p>IP сервера: ${serverIp}</p>
        <p>Порт сервера: ${serverPort}</p>
    `);
});

// 07
// Порционная обработка данных запроса
app.post('/req-data', (req, res) => {
    let body = '';

    req.on('data', chunk => {
        body += chunk;
        console.log(`Получена часть данных: ${chunk}`);
    });

    req.on('end', () => {
        console.log('Данные полностью получены.');
        res.send(`
            <h1>Данные получены:</h1>
            <pre>${body}</pre>
        `);
    });
});

// 08
// Установка статуса и сообщения
app.get('/resp-status', (req, res) => {
    const code = parseInt(req.query.code);
    const mess = req.query.mess;

    if (!isNaN(code) && mess) {
        res.status(code).send(`<h1>Ответ с кодом ${code}</h1><p>${mess}</p>`);
    } else {
        res.status(400).send('<h1>Ошибка: отсутствует параметр code или mess</h1>');
    }
});


// 09
// HTML-форма
app.get('/formparameter', (req, res) => {
    res.send(`
        <form method="POST" action="/formparameter">
            <label>Текст: <input type="text" name="textInput" /></label><br/>
            <label>Число: <input type="number" name="numberInput" /></label><br/>
            <label>Дата: <input type="date" name="dateInput" /></label><br/>
            <label>Чекбокс: <input type="checkbox" name="checkInput" value="yes" /></label><br/>
            <label>Радио 1: <input type="radio" name="radioInput" value="option1" /></label>
            <label>Радио 2: <input type="radio" name="radioInput" value="option2" /></label><br/>
            <label>Textarea: <textarea name="textareaInput"></textarea></label><br/>
            <input type="submit" name="submitBtn" value="Сохранить" />
            <input type="submit" name="submitBtn" value="Удалить" />
        </form>
    `);
});


// Обработка POST-запроса с формы
app.post('/formparameter', (req, res) => {
    res.send(`
        <h1>Получены параметры формы:</h1>
        <pre>${JSON.stringify(req.body, null, 2)}</pre>
    `);
});


// 10
// Обработка JSON-запроса
app.post('/json', (req, res) => {
    const { x, y, s, m, o } = req.body;

    if (typeof x !== 'number' || typeof y !== 'number' || typeof s !== 'string' ||
        !Array.isArray(m) || typeof o !== 'object' || !o.surname || !o.name) {
        return res.status(400).json({ error: 'Неверная структура данных' });
    }

    const response = {
        "__comment": "Ответ.Лабораторная работа 8/10",
        "x_plus_y": x + y,
        "Concatenation_s_o": `${s}: ${o.surname}, ${o.name}`,
        "Length_m": m.length
    };

    res.json(response);
});


// 11
//xml
app.post('/xml', (req, res) => {
    const xmlData = req.body;

    xml2js.parseString(xmlData, (err, result) => {
        if (err) {
            return res.status(400).send('<error>Невалидный XML</error>');
        }

        const request = result.request;
        const requestId = request.$.id || 'unknown';

        // Получение значений x
        const xValues = request.x?.map(x => parseFloat(x.$.value)) || [];
        const sumX = xValues.reduce((acc, val) => acc + val, 0);

        // Получение значений m
        const mValues = request.m?.map(m => m.$.value) || [];
        const concatM = mValues.join('');

        const responseXml = `
<response id="33" request="${requestId}">
    <sum element="x" result="${sumX}" />
    <concat element="m" result="${concatM}" />
</response>
        `;

        res.set('Content-Type', 'application/xml');
        res.send(responseXml.trim());
    });
});

// 12
app.get('/files', (req, res) => {
    const dirPath = path.join(__dirname, 'static');

    fs.readdir(dirPath, (err, files) => {
        if (err) {
            return res.status(500).send('Ошибка при чтении директории');
        }

        const fileCount = files.length;
        res.setHeader('X-static-files-count', fileCount);
        res.send(`Количество файлов в директории "static": ${fileCount}`);
    });
});

// 13
app.get('/files/:filename', (req, res) => {
    const filename = req.params.filename;
    const filePath = path.join(__dirname, 'static', filename);

    fs.access(filePath, fs.constants.F_OK, (err) => {
        if (err) {
            return res.status(404).send(`<h1>Файл "${filename}" не найден</h1>`);
        }

        res.sendFile(filePath);
    });
});


// Настройка хранилища для загружаемых файлов
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, path.join(__dirname, 'static')); 
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname); 
    }
});

const upload = multer({ storage });

// ===== GET /upload =====
app.get('/upload', (req, res) => {
    res.send(`
        <h1>Загрузка файла</h1>
        <form method="POST" action="/upload" enctype="multipart/form-data">
            <input type="file" name="myfile" required />
            <br><br>
            <button type="submit">Загрузить</button>
        </form>
    `);
});

// ===== POST /upload =====
app.post('/upload', upload.single('myfile'), (req, res) => {
    if (!req.file) {
        return res.status(400).send('Файл не загружен.');
    }

    res.send(`
        <h1>Файл загружен!</h1>
        <p>Имя файла: ${req.file.originalname}</p>
        <p>Размер: ${req.file.size} байт</p>
        <a href="/files/${req.file.originalname}">Открыть файл</a>
    `);
});


app.listen(PORT, () => {
    console.log(`Сервер запущен на http://localhost:${PORT}`);
});