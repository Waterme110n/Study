const crypto = require("crypto");
const array = new Uint8Array(1);

for (let i = 0; i < 5; ++i) {
    crypto.getRandomValues(array);
    console.log(array[0]);
}
console.log("---------------------------------------------------------------");

function deriveKey(password, salt, keyLength) {
    return crypto.pbkdf2Sync(password, salt, 100000, keyLength, 'sha256');
}

const encryptionKey = deriveKey('myEncryptionKey', 'mySalt', 32);

// Функция для упаковки ключа с использованием AES-KW
function wrapKey(key, wrappingKey) {
    const cipher = crypto.createCipheriv('aes-256-ecb', wrappingKey, '');
    const wrappedKey = Buffer.concat([cipher.update(key), cipher.final()]);
    return wrappedKey;
}

// Функция для распаковки ключа с использованием AES-KW
function unwrapKey(wrappedKey, wrappingKey) {
    const decipher = crypto.createDecipheriv('aes-256-ecb', wrappingKey, '');
    const unwrappedKey = Buffer.concat([decipher.update(wrappedKey), decipher.final()]);
    return unwrappedKey;
}

// Функция для шифрования строки с использованием AES-CTR
function encryptAESCTR(text, key) {
    const iv = crypto.randomBytes(16); // Генерация случайного инициализационного вектора
    const cipher = crypto.createCipheriv('aes-256-ctr', key, iv);
    const encrypted = Buffer.concat([cipher.update(text), cipher.final()]);
    return {
        iv: iv.toString('hex'),
        encryptedData: encrypted.toString('hex')
    };
}

// Функция для дешифрования строки с использованием AES-CTR
function decryptAESCTR(encryptedData, key, iv) {
    const decipher = crypto.createDecipheriv('aes-256-ctr', key, Buffer.from(iv, 'hex'));
    const decrypted = Buffer.concat([decipher.update(Buffer.from(encryptedData, 'hex')), decipher.final()]);
    return decrypted.toString();
}

// Функция для хеширования строки с использованием SHA-256
function hashSHA256(text) {
    const hash = crypto.createHash('sha256');
    hash.update(text);
    return hash.digest('hex');
}

// Функция для подписи сообщения с использованием RSA-PSS
function signMessageRSA(message, privateKey) {
    const sign = crypto.createSign('RSA-SHA256');
    sign.update(message);
    return sign.sign(privateKey, 'hex');
}

// Функция для проверки подлинности подписи сообщения с использованием RSA-PSS
function verifyMessageRSA(message, signature, publicKey) {
    const verify = crypto.createVerify('RSA-SHA256');
    verify.update(message);
    return verify.verify(publicKey, signature, 'hex');
}

// Пример использования функций
const surname = 'Осадчий';

// Упаковка ключа
const wrappedKey = wrapKey(encryptionKey, encryptionKey);
console.log('Упакованный ключ:', wrappedKey);

// Распаковка ключа
const unwrappedKey = unwrapKey(wrappedKey, encryptionKey);
console.log('Распакованный ключ:', unwrappedKey);

// Шифрование
const encryptedData = encryptAESCTR(surname, unwrappedKey);
console.log('Зашифрованные данные:', encryptedData);

// Дешифрование
const decryptedData = decryptAESCTR(encryptedData.encryptedData, unwrappedKey, encryptedData.iv);
console.log('Расшифрованные данные:', decryptedData);

// Хеширование
const hashedData = hashSHA256(surname);
console.log('Хеш данных:', hashedData);

// Подписание сообщения
const privateKey = crypto.generateKeyPairSync('rsa', {
    modulusLength: 2048,
    privateKeyEncoding: {
        type: 'pkcs8',
        format: 'pem'
    },
    publicKeyEncoding: {
        type: 'spki',
        format: 'pem'
    }
}).privateKey;
const signature = signMessageRSA(surname, privateKey);
console.log('Подпись сообщения:', signature);

// Проверка подлинности подписи
const publicKey = crypto.createPublicKey(privateKey);
const isSignatureValid = verifyMessageRSA(surname, signature, publicKey);
console.log('Проверка подлинности подписи:', isSignatureValid);
console.log("---------------------------------------------------------------");