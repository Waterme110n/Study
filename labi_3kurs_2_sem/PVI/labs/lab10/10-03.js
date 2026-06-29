const WebSocket = require('ws');

const PORT = 5000;
const wss = new WebSocket.Server({ port: PORT });

console.log(`Broadcast WS-server running on ws://localhost:${PORT}`);

wss.on('connection', (ws) => {
    console.log('New client connected');

    ws.on('message', (message) => {
        console.log(`Received: ${message}`);

        wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(`Broadcast: ${message}`);
            }
        });
    });

    ws.on('close', () => {
        console.log('Client disconnected');
    });
});
