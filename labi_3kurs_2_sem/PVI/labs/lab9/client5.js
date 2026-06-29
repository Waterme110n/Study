const http = require('http');

const xmlData = `
<request id="28">
    <x value="1"/>
    <x value="2"/>
    <m value="a"/>
    <m value="b"/>
    <m value="c"/>
</request>
`;

const options = {
    hostname: 'localhost',
    port: 3005,
    path: '/',
    method: 'POST',
    headers: {
        'Content-Type': 'application/xml',
        'Content-Length': Buffer.byteLength(xmlData)
    }
};

const req = http.request(options, (res) => {
    console.log(`Статус ответа: ${res.statusCode}`);
    res.setEncoding('utf8');
    res.on('data', (chunk) => {
        console.log('Ответ сервера:\n', chunk);
    });
});

req.on('error', (error) => {
    console.error(`Ошибка: ${error.message}`);
});

req.write(xmlData);
req.end();
