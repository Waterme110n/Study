const fs = require('fs');
const crypto = require('crypto');

class DataEncoding {
    static convertToBinary(inputText) {
        let binaryString = '';
        for (let char of inputText) {
            binaryString += char.charCodeAt(0).toString(2).padStart(8, '0');
        }
        return binaryString;
    }

    static createHammingMatrix(dataWord) {
        let wordLength = dataWord.length;
        let parityBits = 0;
        while (Math.pow(2, parityBits) < wordLength + parityBits + 1) {
            parityBits++;
        }
        let totalLength = wordLength + parityBits;
        let hammingMatrix = Array.from({ length: parityBits }, () => Array(totalLength).fill(0));

        for (let i = 0; i < parityBits; i++) {
            for (let j = 0; j < totalLength; j++) {
                if ((j + 1) & (1 << i)) {
                    hammingMatrix[i][j] = 1;
                }
            }
        }
        return hammingMatrix;
    }

    static calculateRedundantBits(hammingMatrix, dataWord) {
        let redundantBitsString = '';

        for (let i = 0; i < hammingMatrix.length; i++) {
            let sum = 0;
            for (let j = 0; j < dataWord.length; j++) {
                sum += hammingMatrix[i][j] * parseInt(dataWord[j], 10);
            }
            redundantBitsString += sum % 2;
        }

        return redundantBitsString;
    }

    static addErrorsToData(data, errorCount) {
        let dataArray = data.split('');
        const randomInt = crypto.randomInt;

        for (let i = 0; i < errorCount; i++) {
            let errorIndex = randomInt(data.length);
            dataArray[errorIndex] = dataArray[errorIndex] === '0' ? '1' : '0';
        }

        return dataArray.join('');
    }

    static correctDataErrors(originalData, errorData) {
        let errorVector = '';
        for (let i = 0; i < originalData.length; i++) {
            errorVector += originalData[i] ^ errorData[i];
        }
        console.log("Error Vector: " + errorVector);
        let correctedData = '';
        for (let i = 0; i < errorData.length; i++) {
            correctedData += errorData[i] ^ errorVector[i];
        }
        return correctedData;
    }
}

const runMain = async () => {
    let inputData = '';
    try {
        inputData = fs.readFileSync('test.txt', 'utf8');
    } catch (e) {
        console.error(e);
    }
    // Проверка на минимальную длину сообщения
    if (inputData.length < 2) {
        console.error("Данные должны содержать не менее 2 символов.");
        return;
    }
    inputData = DataEncoding.convertToBinary(inputData);
    console.log("Исходные данные в двоичной форме");
    console.log(inputData);

    console.log("\n Матрица Хемминга");
    let hammingMatrix = DataEncoding.createHammingMatrix(inputData);
    hammingMatrix.forEach(row => console.log(row.join(' ')));

    console.log("Избыточные биты, данные без ошибок:");
    let redundantBits = DataEncoding.calculateRedundantBits(hammingMatrix, inputData);
    console.log(redundantBits);

    let encodedData = inputData + redundantBits;
    console.log("Закодированные данные: " + encodedData);

    console.log("\nДанные с 1 ошибкой:");
    let dataWithOneError = DataEncoding.addErrorsToData(inputData, 1);
    console.log(dataWithOneError);
    console.log("Избыточные биты с одной ошибкой в данных:");
    let redundantBitsWithOneError = DataEncoding.calculateRedundantBits(hammingMatrix, dataWithOneError);
    console.log(redundantBitsWithOneError);

    console.log("\nДанные с 2 ошибками:");
    let dataWithTwoErrors = DataEncoding.addErrorsToData(inputData, 2);
    console.log(dataWithTwoErrors);
    console.log("Избыточные биты с двумя ошибками:");
    let redundantBitsWithTwoErrors = DataEncoding.calculateRedundantBits(hammingMatrix, dataWithTwoErrors);
    console.log(redundantBitsWithTwoErrors);
    console.log();

    let correctedDataWithOneError = DataEncoding.correctDataErrors(inputData, dataWithOneError);
    console.log("Исправленные данные при единичной ошибке");
    console.log(correctedDataWithOneError);
    console.log("Итоговые данные при 1й ошибке: " + (correctedDataWithOneError + redundantBitsWithOneError));

    let correctedDataWithTwoErrors = DataEncoding.correctDataErrors(inputData, dataWithTwoErrors);
    console.log("Исправленные данные при двойной ошибке");
    console.log(correctedDataWithTwoErrors);
    console.log("Итоговые данные при 2ух ошибках: " + (correctedDataWithOneError + redundantBitsWithTwoErrors));
};

runMain();
