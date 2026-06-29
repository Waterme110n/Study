const net = require('net');
const clients = new Map(); // Храним суммы для каждого клиента

const server = net.createServer(socket => {
    console.log('Client connected');
    clients.set(socket, { sum: 0, buffer: Buffer.alloc(0) });

    socket.on('data', data => {
        const clientData = clients.get(socket);
        clientData.buffer = Buffer.concat([clientData.buffer, data]);
        
        while (clientData.buffer.length >= 4) {
            const num = clientData.buffer.readInt32LE(0);
            clientData.sum += num;
            clientData.buffer = clientData.buffer.subarray(4);
            console.log(`Received number: ${num}, current sum: ${clientData.sum}`);
        }
    });

    socket.on('end', () => {
        console.log('Client disconnected');
        clients.delete(socket);
    });
});

// Отправка сумм каждые 5 секунд
setInterval(() => {
    clients.forEach((data, socket) => {
        const sumBuffer = Buffer.alloc(4);
        sumBuffer.writeInt32LE(data.sum, 0);
        socket.write(sumBuffer);
        console.log(`Sent sum ${data.sum} to client`);
    });
}, 5000);

server.listen(3000, () => console.log('Server running on port 3000'));