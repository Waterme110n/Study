const dgram = require('dgram');
const client = dgram.createSocket('udp4');

const message = 'Hello UDP Server';
client.send(message, 3000, 'localhost', (err) => {
    if (err) throw err;
    console.log(`Client sent: ${message}`);
});

client.on('message', (msg) => {
    console.log(`Client received: ${msg.toString()}`);
    client.close();
});

client.on('error', (err) => {
    console.error(`Client error: ${err.stack}`);
});