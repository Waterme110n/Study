const express = require('express');

const app = express();

function factorial(n) {
    if (n === 0 || n === 1) return 1;
    return n * factorial(n - 1);
}

app.get('/fact', (req, res) => {
    const k = parseInt(req.query.k);
    if (isNaN(k) || k < 0) {
        return res.status(400).json({ error: "Invalid parameter k. Must be a non-negative integer." });
    }
    res.json({ k: k, fact: factorial(k) });
});

app.listen(5000, () => {
    console.log("Сервер запущен на http://localhost:5000/fact?k=3");
});
