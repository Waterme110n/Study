const http = require('http');
const querystring = require('querystring');

const server = http.createServer((req, res) => {
    if (req.method === 'POST') {
        let body = '';
        
        req.on('data', chunk => body += chunk);
        
        req.on('end', () => {
            const data = querystring.parse(body);
            const x = parseFloat(data.x);
            const y = parseFloat(data.y);
            const s = data.s;

            const result = `Получено: x=${x}, y=${y}, s="${s}"`;

            res.writeHead(200, { 'Content-Type': 'text/plain' });
            res.end(result);
        });
    } else {
        res.writeHead(405, { 'Content-Type': 'text/plain' });
        res.end('Метод не поддерживается');
    }
});

server.listen(3002, () => {
    console.log('Сервер 09-03 запущен на http://localhost:3002');
});
