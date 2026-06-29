const net = require('net');
const client = net.connect(3000, 'localhost', () => {
    client.write('Hello from client 13-02\n');
});
client.on('data', data => console.log('Received:', data.toString()));
client.on('end', () => client.end());