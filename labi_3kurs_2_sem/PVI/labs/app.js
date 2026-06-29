// Функция для прямого преобразования Барроуза-Уилера
function bwt(input) {
    const length = input.length;
    let table = [];

    for (let i = 0; i < length; i++) {
        table.push(input.substring(length - i) + input.substring(0, length - i));
    }

    console.log("Таблица циклических сдвигов:");
    table.forEach(row => console.log(row));

    table.sort();

    console.log("\nОтсортированная таблица:");
    table.forEach(row => console.log(row));

    let lastColumn = '';
    for (let row of table) {
        lastColumn += row.charAt(length - 1);
    }
    const originalRow = table.indexOf(input);

    return [lastColumn, originalRow.toString()];
}

// Функция для обратного преобразования Барроуза-Уилера
function invBwt(lastColumn, originalRow) {
    const length = lastColumn.length;
    let table = Array(length).fill('');

    for (let i = 0; i < length; i++) {
        for (let j = 0; j < length; j++) {
            table[j] = lastColumn.charAt(j) + table[j];
        }
        table.sort();

        console.log("Шаг " + (i + 1) + ":");
        table.forEach(row => console.log(row));
        console.log();
    }

    return table[originalRow];
}

// Главная функция
function main() {
    const input = "ваня";

    console.time("Время выполнения прямого преобразования");
    const bwtResult = bwt(input);
    console.timeEnd("Время выполнения прямого преобразования");

    console.log("Результат BWT: " + bwtResult);

    console.time("Время выполнения обратного преобразования");
    const invBwtResult = invBwt(bwtResult[0], parseInt(bwtResult[1]));
    console.timeEnd("Время выполнения обратного преобразования");

    console.log("Результат обратного преобразования: " + invBwtResult);
}

main();
