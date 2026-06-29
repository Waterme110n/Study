const net = require('net');
const x = parseInt(process.argv[2]);

if (isNaN(x)) {
    console.error('Please provide a valid number as argument');
    process.exit(1);
}

const client = net.connect(3000, () => {
    console.log(`Connected to server. Will send number ${x} every second`);
});

let counter = 0;
const interval = setInterval(() => {
    const buffer = Buffer.alloc(4);
    buffer.writeInt32LE(x, 0);
    client.write(buffer);
    console.log(`Sent number: ${x}`);
    
    if (++counter >= 20) {
        clearInterval(interval);
        setTimeout(() => client.end(), 1000);
    }
}, 1000);

client.on('data', data => {
    console.log('Received sum:', data.readInt32LE(0));
});

client.on('end', () => {
    console.log('Disconnected from server');
    clearInterval(interval);
});