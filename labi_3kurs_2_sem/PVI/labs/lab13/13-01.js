const net = require('net');
const server = net.createServer(socket => {
    socket.on('data', data => {
        const message = data.toString().trim();
        socket.write(`ECHO: ${message}\n`);
    });
});
server.listen(3000, () => console.log('Server running on port 3000'));