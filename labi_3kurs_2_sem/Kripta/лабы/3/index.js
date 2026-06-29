const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const writeFileAsync = promisify(fs.writeFile);


function base64_encode(s) {
    var base64chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    var r = "";
    var p = "";
    var c = s.length % 3;
    // add a right zero pad to make this string a multiple of 3 characters
    if (c > 0) {
      for (; c < 3; c++) {
        p += "=";
        s += "\0";
      }
    }
    for (c = 0; c < s.length; c += 3) {
      if (c > 0 && (c / 3 * 4) % 76 == 0) {
        r += "\r\n";
      }
      var n = (s.charCodeAt(c) << 16) + (s.charCodeAt(c + 1) << 8) + s.charCodeAt(c + 2);
      n = [(n >>> 18) & 63, (n >>> 12) & 63, (n >>> 6) & 63, n & 63];
      r += base64chars[n[0]] + base64chars[n[1]] + base64chars[n[2]] + base64chars[n[3]];
    }
    return r.substring(0, r.length - p.length) + p;
  }
  async function customConvertToBase64(inputFilePath, outputFilePath) {
    try {
      const text = await readFileAsync(inputFilePath, "utf8");
      const base64Text = base64_encode(text);
      await writeFileAsync(outputFilePath, base64Text, "utf8");
      console.log(`Текст из ${inputFilePath} успешно сконвертирован в base64 и сохранен в ${outputFilePath}.`);
    } catch (error) {
      console.error("Произошла ошибка:", error.message);
    }
  }
const inputFilePath = path.join(__dirname, 'test.txt');
const outputFilePath = path.join(__dirname, 'output.txt');
customConvertToBase64(inputFilePath, outputFilePath); 
//-----------------------------------------------------------------------
/*async function convertToBase64(inputFilePath, outputFilePath) {
    try {
        // Чтение текста из файла
        const text = await readFileAsync(inputFilePath, 'utf8');

        // Кодирование текста в base64
        const base64Text = Buffer.from(text, 'utf8').toString('base64');

        // Запись результата в другой файл
        await writeFileAsync(outputFilePath, base64Text, 'utf8');

        console.log(`Текст из ${inputFilePath} успешно сконвертирован в base64 и сохранен в ${outputFilePath}.`);
    } catch (error) {
        console.error('Произошла ошибка:', error.message);
    }
}
// Использование функции
const inputFilePath = path.join(__dirname, 'test.txt');
const outputFilePath = path.join(__dirname, 'output.txt');
convertToBase64(inputFilePath, outputFilePath); */
//------------------------------------------------------------------------
function countFrequencies(str) {
    let frequencies = {};
    for (let char of str) {
      if (frequencies[char]) {
        frequencies[char]++;
      } else {
        frequencies[char] = 1;
      }
    }
    return frequencies;
  }
function calculateEntropy(frequencies, length) {
    let entropy = 0;
    for (let char in frequencies) {
      let probability = frequencies[char] / length;
      let log2 = Math.log2(probability);
      entropy += probability * log2;
    }
    return -entropy;
  }
function printFrequencies(frequencies) {
  for (let char in frequencies) {
    console.log(`Символ ${char} встречается ${frequencies[char]} раз`);
  }
}
function calculateHartleyEntropy(size) {
  let entropy = Math.log2(size);
  return entropy;
}
function calculateRedundancy(hartleyEntropy, shannonEntropy) {
  let redundancy = (hartleyEntropy - shannonEntropy) / hartleyEntropy;
  return redundancy;
}
function processFile(filename) {
  let text = fs.readFileSync(filename, 'utf8');
  let frequencies = countFrequencies(text);
  let shannonEntropy = calculateEntropy(frequencies, text.length);
  let hartleyEntropy = calculateHartleyEntropy(Object.keys(frequencies).length);
  let redundancy = calculateRedundancy(hartleyEntropy, shannonEntropy);
  console.log(`Энтропия Шеннона файла ${filename} равна ${shannonEntropy}`);
  console.log(`Энтропия Хартли файла ${filename} равна ${hartleyEntropy}`);
  console.log(`Избыточность алфавита файла ${filename} равна ${redundancy}`);
  printFrequencies(frequencies);
}

// Задание а)
processFile('french.txt'); 
processFile('ukrainian.txt'); 


const crypto = require('crypto');

function xorBuffers(a, b) {
    let length = Math.max(a.length, b.length);
    let result = Buffer.alloc(length);

    for (let i = 0; i < length; ++i) {
        result[i] = a[i] ^ b[i];
    }

    return result;
}

function padBuffer(buffer, length) {
    if (buffer.length >= length) {
        return buffer;
    }

    let padded = Buffer.alloc(length);
    buffer.copy(padded);

    return padded;
}

function bufferToBits(buffer) {
    let bits = '';
    for (let byte of buffer) {
        bits += byte.toString(2).padStart(8, '0');
    }
    return bits;
}

// Пример использования
let a = Buffer.from('Осадчий', 'utf8');
let b = Buffer.from('Павел', 'utf8');

console.log('Ваша фамилия в битах: ', bufferToBits(a));
console.log('Ваше имя в битах: ', bufferToBits(b));

// Дополняем буферы до одинаковой длины
let maxLength = Math.max(a.length, b.length);
a = padBuffer(a, maxLength);
b = padBuffer(b, maxLength);

// Выполняем операцию XOR
let xorResult = xorBuffers(a, b);

console.log('Результат XOR в битах: ', bufferToBits(xorResult));

// Выполняем операцию aXORbXORb
let axorbxorResult = xorBuffers(xorResult, b);

console.log('Результат aXORbXORb в битах: ', bufferToBits(axorbxorResult));


 




