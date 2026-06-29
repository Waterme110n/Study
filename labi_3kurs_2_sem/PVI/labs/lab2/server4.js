const express = require("express");
const path = require("path");

const app = express();
const PORT = 5000;


app.get("/xmlhttprequest", (req, res) => {
    res.sendFile(path.join(__dirname, "xmlhttprequest.html"));
});

app.get("/api/name", (req, res) => {
    res.json({ lastName: "Осадчий", firstName: "Павел", middleName: "Андреевич" });
});

app.listen(PORT, () => {
    console.log(`Сервер запущен на http://localhost:${PORT}/xmlhttprequest`);
});
