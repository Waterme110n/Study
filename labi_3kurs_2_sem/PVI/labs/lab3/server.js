const express = require('express');
const readline = require('readline');

const app = express();
let appState = "norm";

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

app.get('/', (req, res) => {
    res.send(`<h1>${appState}</h1>`);
});

function promptUser() {
    rl.question("Введите состояние (norm, stop, test, idle, exit): ", (newState) => {
        newState = newState.trim();
        if (["norm", "stop", "test", "idle"].includes(newState)) {
            appState = newState;
        } else if (newState === "exit") {
            console.log("Выход из приложения...");
            process.exit(0);
        } else {
            console.log(`Ошибка: '${newState}' - неизвестное состояние`);
        }
        promptUser();
    });
}

app.listen(5000, () => {
    console.log("Сервер запущен на http://localhost:5000");
    promptUser();
});
