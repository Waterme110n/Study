const WebSocket = require('ws');

const PORT = 4000;
const wss = new WebSocket.Server({ port: PORT });

console.log(`WebSocket server running on ws://localhost:${PORT}`);

wss.on('connection', (ws) => {
    console.log('Client connected');

    let serverMsgCount = 0;
    let lastClientNum = 0;

    ws.on('message', (message) => {
        console.log(`Received: ${message}`);
        const match = message.toString().match(/: (\d+)/);
        if (match) lastClientNum = parseInt(match[1]);

        const interval = setInterval(() => {
            serverMsgCount++;
            if (ws.readyState === WebSocket.OPEN) {
                ws.send(`10-01-server: ${lastClientNum}->${serverMsgCount}`);
            }
        }, 5000);

        setTimeout(() => {
            clearInterval(interval);
            if (ws.readyState === WebSocket.OPEN) {
                ws.close();
                console.log('WS closed after 25 seconds');
            }
        }, 25000);
    });
});
