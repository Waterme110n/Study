const http = require('http');

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('hello from server 09-01!');
});

server.listen(3000, () => {
    console.log('Сервер запущен на http://localhost:3000');
});
