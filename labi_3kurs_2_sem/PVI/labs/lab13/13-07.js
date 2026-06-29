const net = require('net');

// Функция создания сервера для конкретного порта
function createServer(port) {
  const server = net.createServer(socket => {
    console.log(`Client connected to port ${port}`);
    
    socket.on('data', data => {
      // Проверяем, что пришло минимум 4 байта (32-битное число)
      if (data.length >= 4) {
        const num = data.readInt32LE(0);
        const response = `ECHO: ${num}`;
        socket.write(response);
        console.log(`[Port ${port}] Received: ${num}, Sent: ${response}`);
      }
    });

    socket.on('end', () => {
      console.log(`Client disconnected from port ${port}`);
    });

    socket.on('error', err => {
      console.error(`Port ${port} error:`, err.message);
    });
  });

  server.listen(port, () => {
    console.log(`Server listening on port ${port}`);
  });

  return server;
}

// Создаем серверы для двух портов
createServer(40000);
createServer(50000);

console.log('Multi-port server started');