const express = require('express');
const path = require('path');

const app = express();

function asyncFactorial(n, callback) {
    if (n === 0 || n === 1) return callback(1);

    let result = 1;
    let i = n;

    function compute() {
        if (i > 1) {
            result *= i;
            i--;
            setImmediate(compute); 
        } else {
            callback(result);
        }
    }

    setImmediate(compute);
}

app.get('/fact', (req, res) => {
    const k = parseInt(req.query.k);
    if (isNaN(k) || k < 0) {
        return res.status(400).json({ error: "Invalid parameter k. Must be a non-negative integer." });
    }

    asyncFactorial(k, (factorial) => {
        res.json({ k: k, fact: factorial });
    });
});

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index5.html'));
});

app.listen(5000, () => {
    console.log("Сервер запущен на http://localhost:5000/");
});
