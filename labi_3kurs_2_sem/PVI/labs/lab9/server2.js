const http = require('http');
const url = require('url');

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const query = parsedUrl.query;

    const x = parseFloat(query.x);
    const y = parseFloat(query.y);

    if (!isNaN(x) && !isNaN(y)) {
        const result = x + y;
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end(`Resault x + y = ${result}`);
    } else {
        res.writeHead(400, { 'Content-Type': 'text/plain' });
        res.end('Error');
    }
});

server.listen(3001, () => {
    console.log('Сервер запущен на http://localhost:3001');
});
