const net = require('net');
const client = net.connect(3000);

let counter = 0;
const interval = setInterval(() => {
    const num = Math.floor(Math.random() * 100);
    const buffer = Buffer.alloc(4);
    buffer.writeInt32LE(num, 0);
    client.write(buffer);
    console.log(`Sent number: ${num}`);
    
    if (++counter >= 20) {
        clearInterval(interval);
        setTimeout(() => client.end(), 1000);
    }
}, 1000);

client.on('data', data => {
    console.log('Current sum:', data.readInt32LE(0));
});

client.on('end', () => console.log('Client stopped'));