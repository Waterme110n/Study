const WebSocket = require('ws');

const ws = new WebSocket('ws://localhost:4000');
let count = 1;

ws.on('open', () => {
    console.log('Connected to server');

    const sendInterval = setInterval(() => {
        if (ws.readyState === WebSocket.OPEN) {
            const msg = `10-01-client: ${count}`;
            console.log(`Send: ${msg}`);
            ws.send(msg);
            count++;
        }
    }, 3000);

    setTimeout(() => {
        clearInterval(sendInterval);
        console.log('Stopped sending messages');
        if (ws.readyState === WebSocket.OPEN) {
            ws.close();
        }
    }, 25000);
});

ws.on('message', (data) => {
    console.log(`Received from server: ${data}`);
});

ws.on('close', () => {
    console.log('Connection closed');
});
