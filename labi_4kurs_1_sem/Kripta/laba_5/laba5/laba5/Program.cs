using System;
using System.Security.Cryptography;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Diagnostics;

namespace laba5
{
    class Program
    {
        static void Main(string[] args)
        {
            var sw = new Stopwatch();

            string plainText = "podrez";
            string firstKey = "eugene";
            string secondKey = "dmitrievich";

            Console.WriteLine($"First key(using on first and third steps of encryption/decryption): {firstKey}");
            Console.WriteLine($"Second key(using on the second step of encryption/decryption): {secondKey}\n\n");
            Console.WriteLine($"Original message: {plainText}");

            sw.Start();
            string encryptedMessage = Encrypt(plainText, firstKey);
            encryptedMessage = Encrypt(encryptedMessage, secondKey);
            encryptedMessage = Encrypt(encryptedMessage, firstKey);
            sw.Stop();
            Console.WriteLine($"Encrypted message: {encryptedMessage}");
            Console.WriteLine($"Time spent on encryption in milliseconds: {sw.ElapsedMilliseconds}");

            sw.Restart();
            string decryptedMessage = Decrypt(encryptedMessage, firstKey);
            decryptedMessage = Decrypt(decryptedMessage, secondKey);
            decryptedMessage = Decrypt(decryptedMessage, firstKey);
            sw.Stop();
            Console.WriteLine($"Decrypted message: {decryptedMessage}");
            Console.WriteLine($"Time spent on decryption in milliseconds: {sw.ElapsedMilliseconds}\n\n");

            sw.Restart();
            long sizeOfFileWithEncryptedText = EncryptToFile(firstKey, secondKey);
            sw.Stop();
            Console.WriteLine("Encryption to file is ended");
            Console.WriteLine($"Time spent on encryption in milliseconds: {sw.ElapsedMilliseconds}");
            Console.WriteLine($"Size of file with encrypted text is {sizeOfFileWithEncryptedText} bytes");

            sw.Restart();
            long sizeOfFileWithDecryptedText = DecryptToFile(firstKey, secondKey);
            sw.Stop();
            Console.WriteLine("Decryption to file is ended");
            Console.WriteLine($"Time spent on decryption in milliseconds: {sw.ElapsedMilliseconds}");
            Console.WriteLine($"Size of file with decrypted text is {sizeOfFileWithDecryptedText} bytes");


            Console.WriteLine($"Number of bytes of encrypted message to number of bytes of decrypted message: {sizeOfFileWithEncryptedText / sizeOfFileWithDecryptedText}");
        }

        public static long EncryptToFile(string firstKey, string secondKey)
        {
            string pathToStartFile = "D:\\Study\\3 курс 2 семестр\\ЗИ\\laba_5\\startFile.txt";
            string pathToEncryption = "D:\\Study\\3 курс 2 семестр\\ЗИ\\laba_5\\fileWithEncryptedText.txt";

            string text;

            using (StreamReader reader = new StreamReader(pathToStartFile))
            {
                text = reader.ReadToEnd();
            }

            string encryptedText = Encrypt(text, firstKey);
            encryptedText = Encrypt(encryptedText, secondKey);
            encryptedText = Encrypt(encryptedText, firstKey);

            using (StreamWriter writer = new StreamWriter(pathToEncryption, false))
            {
                writer.WriteLine(encryptedText);
            }

            FileInfo file = new FileInfo(pathToEncryption);

            return file.Length;
        }

        public static long DecryptToFile(string firstKey, string secondKey)
        {
            string pathToEncryption = "D:\\Study\\3 курс 2 семестр\\ЗИ\\laba_5\\fileWithEncryptedText.txt";
            string pathToDecryption = "D:\\Study\\3 курс 2 семестр\\ЗИ\\laba_5\\fileWithDecryptedText.txt";

            string encryptedText;

            using (StreamReader reader = new StreamReader(pathToEncryption))
            {
                encryptedText = reader.ReadToEnd();
            }

            string decryptedText = Decrypt(encryptedText, firstKey);
            decryptedText = Decrypt(decryptedText, secondKey);
            decryptedText = Decrypt(decryptedText, firstKey);

            using (StreamWriter writer = new StreamWriter(pathToDecryption, false))
            {
                writer.WriteLine(decryptedText);
            }

            FileInfo file = new FileInfo(pathToDecryption);

            return file.Length;
        }

        public static string Encrypt(string PlainText, string Key)
        {
            byte[] EncryptedArray = UTF8Encoding.UTF8.GetBytes(PlainText);

            MD5CryptoServiceProvider objOfMD5CryptoService = new MD5CryptoServiceProvider();
            byte[] SecurityKeyArray = objOfMD5CryptoService.ComputeHash(UTF8Encoding.UTF8.GetBytes(Key));
            objOfMD5CryptoService.Clear();

            var objOfTripleDESCryptoService = new TripleDESCryptoServiceProvider();

            objOfTripleDESCryptoService.Key = SecurityKeyArray;
            objOfTripleDESCryptoService.Mode = CipherMode.ECB;
            objOfTripleDESCryptoService.Padding = PaddingMode.PKCS7;

            var objOfCryptoTransform = objOfTripleDESCryptoService.CreateEncryptor();

            byte[] ResultArray = objOfCryptoTransform.TransformFinalBlock(EncryptedArray, 0, EncryptedArray.Length);

            objOfTripleDESCryptoService.Clear();

            return Convert.ToBase64String(ResultArray, 0, ResultArray.Length);
        }

        public static string Decrypt(string CipherText, string Key)
        {
            byte[] EncryptArray = Convert.FromBase64String(CipherText);

            MD5CryptoServiceProvider objOfMD5CryptoService = new MD5CryptoServiceProvider();
            byte[] SecurityKeyArray = objOfMD5CryptoService.ComputeHash(UTF8Encoding.UTF8.GetBytes(Key));
            objOfMD5CryptoService.Clear();

            var objOfTripleDESCryptoService = new TripleDESCryptoServiceProvider();

            objOfTripleDESCryptoService.Key = SecurityKeyArray;
            objOfTripleDESCryptoService.Mode = CipherMode.ECB;
            objOfTripleDESCryptoService.Padding = PaddingMode.PKCS7;

            var objOfCryptoTransform = objOfTripleDESCryptoService.CreateDecryptor();

            byte[] ResultArray = objOfCryptoTransform.TransformFinalBlock(EncryptArray, 0, EncryptArray.Length);

            objOfTripleDESCryptoService.Clear();

            return UTF8Encoding.UTF8.GetString(ResultArray);
        }
    }
}
