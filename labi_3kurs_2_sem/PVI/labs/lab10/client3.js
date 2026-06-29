const WebSocket = require('ws');

const ws = new WebSocket('ws://localhost:5000');

let count = 1;

ws.on('open', () => {
    console.log('Connected to broadcast server');

    const interval = setInterval(() => {
        if (ws.readyState === WebSocket.OPEN) {
            const msg = `Client says: ${count}`;
            console.log(`Sending: ${msg}`);
            ws.send(msg);
            count++;
        }
    }, 4000); 

    setTimeout(() => {
        clearInterval(interval);
        ws.close();
        console.log('Client finished and closed connection');
    }, 20000);
});

ws.on('message', (data) => {
    console.log(`Received: ${data}`);
});
