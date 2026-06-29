const express = require('express');
const path = require('path');
const app = express();
const port = 5000;

app.get('/png', (req, res) => {
  res.sendFile(path.join(__dirname, 'image.png'));
});

app.listen(port, () => {
  console.log(`Сервер запущен: http://localhost:${port}/png`);
});