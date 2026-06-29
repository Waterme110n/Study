const dgram = require('dgram');
const server = dgram.createSocket('udp4');

server.on('message', (msg, rinfo) => {
    const message = msg.toString();
    console.log(`Server received: ${message} from ${rinfo.address}:${rinfo.port}`);
    const response = `ECHO: ${message}`;
    server.send(response, rinfo.port, rinfo.address);
});

server.on('listening', () => {
    const address = server.address();
    console.log(`UDP Server listening on ${address.address}:${address.port}`);
});

server.bind(3000);