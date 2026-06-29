const http = require('http');

const server = http.createServer((req, res) => {
    if (req.method === 'POST' && req.headers['content-type'] === 'application/json') {
        let body = '';

        req.on('data', chunk => body += chunk);

        req.on('end', () => {
            try {
                const data = JSON.parse(body);
                const x = data.x;
                const y = data.y;
                const s = data.s;
                const m = data.m;
                const o = data.o;

                const response = {
                    "__comment": "Ответ.Лабораторная работа 8/10",
                    x_plus_y: x + y,
                    Concatenation_s_o: `${s}: ${o.surname}, ${o.name}`,
                    Length_m: Array.isArray(m) ? m.length : 0
                };

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(response));
            } catch (err) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Ошибка парсинга JSON' }));
            }
        });
    } else {
        res.writeHead(415, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Ожидался JSON' }));
    }
});

server.listen(3004, () => {
    console.log('Сервер 09-04 запущен на http://localhost:3004');
});
