const express = require('express');
const path = require('path');
const app = express();
const port = 5000;

app.get('/html', (req, res) => {
    try {
        const filePath = path.join(__dirname, 'index1.html');
        res.sendFile(filePath);
    } catch (err) {
        console.error('Critical error:', err);
        res.status(500).send('Server Error');
    }
});

app.listen(port, () => {
    console.log(`Сервер запущен на http://localhost:${port}/html`);
});