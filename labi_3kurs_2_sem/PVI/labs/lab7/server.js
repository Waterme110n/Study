const http = require('http');
const url = require('url');
const path = require('path');
const StaticFileHandler = require('./m07_01');

const staticDir = path.join(__dirname, 'static');
const fileHandler = new StaticFileHandler(staticDir);

const server = http.createServer((req, res) => {
    if (req.method !== 'GET') {
        res.writeHead(405, { 'Content-Type': 'text/plain' });
        return res.end('Method Not Allowed');
    }
    const requestUrl = url.parse(req.url, true);
    let filePath = requestUrl.pathname;

    if (!filePath.startsWith('/static/')) {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        return res.end('Not Found');
    }

    filePath = filePath.replace('/static/', '');

    if (filePath === '') {
        filePath = 'index.html';
    }

    fileHandler.handleFileRequest(res, filePath);
});


server.listen(8080, () => {
    console.log('Server running at http://localhost:8080/static/');
});
