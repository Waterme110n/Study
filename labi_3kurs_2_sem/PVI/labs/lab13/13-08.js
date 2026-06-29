const net = require('net');

const port = parseInt(process.argv[2]);
if (isNaN(port) || (port !== 40000 && port !== 50000)) {
  console.error('Please provide valid port (40000 or 50000)');
  process.exit(1);
}

const client = net.connect({ port }, () => {
  console.log(`Connected to server on port ${port}`);
  
  let counter = 1;
  // Отправляем число каждую секунду
  const interval = setInterval(() => {
    const buffer = Buffer.alloc(4);
    buffer.writeInt32LE(counter, 0);
    client.write(buffer);
    console.log(`Sent number: ${counter}`);
    counter++;
  }, 1000);

  // Автоматическое отключение через 20 сек
  setTimeout(() => {
    clearInterval(interval);
    client.end();
  }, 20000);
});

client.on('data', data => {
  console.log('Server response:', data.toString());
});

client.on('end', () => {
  console.log('Disconnected from server');
});

client.on('error', err => {
  console.error('Connection error:', err.message);
});