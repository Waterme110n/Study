const net = require('net');
const server = net.createServer();

// Хранилище для данных клиентов
const clients = new Map();

server.on('connection', socket => {
    console.log(`New client connected: ${socket.remoteAddress}:${socket.remotePort}`);
    
    // Инициализация данных клиента
    clients.set(socket, {
        sum: 0,
        buffer: Buffer.alloc(0),
        clientId: `${socket.remoteAddress}:${socket.remotePort}`
    });

    socket.on('data', data => {
        const clientData = clients.get(socket);
        clientData.buffer = Buffer.concat([clientData.buffer, data]);
        
        // Обработка 32-битных чисел
        while (clientData.buffer.length >= 4) {
            const num = clientData.buffer.readInt32LE(0);
            clientData.sum += num;
            clientData.buffer = clientData.buffer.subarray(4);
            console.log(`[${clientData.clientId}] Received number: ${num}, current sum: ${clientData.sum}`);
        }
    });

    socket.on('end', () => {
        console.log(`Client disconnected: ${clients.get(socket).clientId}`);
        clients.delete(socket);
    });

    socket.on('error', err => {
        console.error(`Client error: ${err.message}`);
        clients.delete(socket);
    });
});

// Отправка сумм каждые 5 секунд
setInterval(() => {
    clients.forEach((clientData, socket) => {
        const sumBuffer = Buffer.alloc(4);
        sumBuffer.writeInt32LE(clientData.sum, 0);
        socket.write(sumBuffer);
        console.log(`[${clientData.clientId}] Sent sum: ${clientData.sum}`);
    });
}, 5000);

server.listen(3000, () => {
    console.log('Server 13-05 listening on port 3000');
});