const express = require('express');
const app = express();
const port = 5000;

app.get('/api/name', (req, res) => {
  res.set('Content-Type', 'text/plain');
  res.send('Осадчий Павел Андреевич');
});

app.listen(port, () => {
  console.log(`Сервер запущен: http://localhost:${port}/api/name`);
});