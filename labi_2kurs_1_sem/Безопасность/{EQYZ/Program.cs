using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

class Program
{
	static void Main()
	{
		string surname = "Осадчий";

		// Генерация ключей шифрования
		byte[][] encryptionKeys = new byte[7][];
		for (int i = 0; i < 7; i++)
		{
			encryptionKeys[i] = GenerateEncryptionKey();
		}

		// Запись ключей шифрования в файл
		string keyFilePath = "encryption_keys.txt";
		WriteEncryptionKeysToFile(encryptionKeys, keyFilePath);

		// Шифрование и сохранение зашифрованных данных
		string encryptedDataFilePath = "encrypted_data.txt";
		EncryptAndSaveData(surname, encryptionKeys, encryptedDataFilePath);

		// Хеширование и сохранение хэш-значения
		string hashFilePath = "hash_value.txt";
		byte[] hashValue = ComputeHashValue(surname);
		SaveHashValueToFile(hashValue, hashFilePath);

		Console.WriteLine("Шифрование, дешифрование и хеширование завершено.");
	}

	static byte[] GenerateEncryptionKey()
	{
		using (var aes = new AesCryptoServiceProvider())
		{
			aes.KeySize = 192; // Установка длины ключа AES в 192 бита
			aes.GenerateKey();
			return aes.Key;
		}












			}

	static void WriteEncryptionKeysToFile(byte[][] keys, string filePath)
	{
		using (StreamWriter writer = new StreamWriter(filePath))
		{
			foreach (byte[] key in keys)
			{
				writer.WriteLine(Convert.ToBase64String(key));
			}
		}
	}

	static void EncryptAndSaveData(string data, byte[][] encryptionKeys, string filePath)
	{
		using (var aes = new AesCryptoServiceProvider())
		{
			aes.KeySize = 192;
			aes.Mode = CipherMode.CBC;
			aes.Padding = PaddingMode.PKCS7;

			foreach (byte[] key in encryptionKeys)
			{
				aes.Key = key;
				aes.GenerateIV();

				using (ICryptoTransform encryptor = aes.CreateEncryptor())
				using (var memoryStream = new MemoryStream())
				{
					// Запись IV перед зашифрованными данными
					memoryStream.Write(aes.IV, 0, aes.IV.Length);

					using (var cryptoStream = new CryptoStream(memoryStream, encryptor, CryptoStreamMode.Write))
					using (var writer = new StreamWriter(cryptoStream))
					{
						writer.Write(data);
					}

					byte[] encryptedData = memoryStream.ToArray();
					File.WriteAllBytes(filePath, encryptedData);
				}
			}
		}
	}

	// хеширование по аллгоритму SHA1 
	static byte[] ComputeHashValue(string data)
	{
		using (var sha1 = new SHA1CryptoServiceProvider())
		{
			byte[] inputBuffer = Encoding.Unicode.GetBytes(data);
			return sha1.ComputeHash(inputBuffer);
		}
	}

	static void SaveHashValueToFile(byte[] hashValue, string filePath)
	{
		File.WriteAllBytes(filePath, hashValue);
	}
}