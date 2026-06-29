using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

using Lab5Lib.Abstraction;

namespace Lab5Lib.Decorator;
public class DecRSA : Decorator
{
	public DecRSA(IWriter? writer) : base(writer)
	{
	}
	public override string? Save(string message)
	{
		// Генерация ключей RSA
		string publicKeyXml;
		byte[] encryptedData;
		message = message ?? string.Empty;
		Console.WriteLine("------------------------- " + message);
		int k1 = message.IndexOf(Constant.Delimiter);
		//if (k1 == -1)
		//	//throw new Exception("Delimiter not found");
		//	Console.WriteLine("Delimiter not found");
		//string xs = message.Substring(0, k1);
		//string xsbhcs = message.Substring(k1 + 1);
		// Вычисление хеша
		//byte[] xsbhc = Convert.FromBase64String(xsbhcs);

		var dataBytes = Encoding.UTF8.GetBytes(message);

		using (RSACryptoServiceProvider rsa = new RSACryptoServiceProvider())
		{
			publicKeyXml = rsa.ToXmlString(true);
			encryptedData = EncryptRSA(dataBytes, publicKeyXml);
		}

		// Запись в файл
		string result = $"{message}{Constant.Delimiter}{Convert.ToBase64String(encryptedData)}{Constant.Delimiter}{publicKeyXml}";
		return _writer?.Save(result);
	}

	private byte[] EncryptRSA(byte[] data, string publicKeyXml)
	{
		using (RSACryptoServiceProvider rsa = new RSACryptoServiceProvider())
		{
			rsa.FromXmlString(publicKeyXml);
			return rsa.Encrypt(data, false);
		}
	}
	//public override string? Save(string? message)
	//{
	//	var (encryptedMessage, publicKey) = ComputeRSAHash(message);

	//	string msg = $"{message}{Constant.Delimiter}{encryptedMessage}{Constant.Delimiter}{publicKey}";

	//	return _writer?.Save(msg);
	//}
	//public override string? Save(string message)
	//{
	//	// Генерация ключей RSA
	//	string publicKeyXml;
	//	byte[] encyptedData;
	//	message = message ?? string.Empty;
	//	int k1 = message.IndexOf(Constant.Delimiter);
	//	if (k1 == -1)
	//		throw new Exception("delimiter not found");
	//	string xs = message.Substring(0, k1);
	//	string xsbhcs = message.Substring(k1 + 1);
	//	// Вычисление хеша
	//	byte[] xsbhc = Convert.FromBase64String(xsbhcs);
	//	using (RSACryptoServiceProvider rsa = new RSACryptoServiceProvider())
	//	{
	//		publicKeyXml = rsa.ToXmlString(true);
	//		rsa.ImportParameters(rsa.ExportParameters(false));
	//		encyptedData = rsa.Encrypt(xsbhc, false);
	//	}

	//	// Запись в файл
	//	string result = $"{xs}{Constant.Delimiter}{Convert.ToBase64String(encyptedData)}{Constant.Delimiter}{publicKeyXml}";
	//	return _writer?.Save(result);
	//}

	//private (string, string) ComputeRSAHash(string? message)
	//{
	//	// Генерация ключей RSA
	//	string publicKeyXml;
	//	byte[] encyptedData;
	//	message = message ?? string.Empty;
	//	int k1 = message.IndexOf(Constant.Delimiter);
	//	if (k1 == -1)
	//		throw new Exception("delimiter not found");
	//	string xs = message.Substring(0, k1);
	//	string xsbhcs = message.Substring(k1 + 1);
	//	// Вычисление хеша
	//	byte[] xsbhc = Convert.FromBase64String(xsbhcs);
	//	using (RSACryptoServiceProvider rsa = new RSACryptoServiceProvider())
	//	{
	//		publicKeyXml = rsa.ToXmlString(true);
	//		rsa.ImportParameters(rsa.ExportParameters(false));
	//		encyptedData = rsa.Encrypt(xsbhc, false);
	//	}
	//	var encryptedMessage = Convert.ToBase64String(encyptedData);
	//	//if (message == null)
	//	//	return (string.Empty, string.Empty);

	//	//using RSA rsa = RSA.Create();

	//	//var dataBytes = Encoding.UTF8.GetBytes(message);

	//	//var encryptedData = rsa.Encrypt(dataBytes, RSAEncryptionPadding.Pkcs1);

	//	//var encryptedMessage = Convert.ToBase64String(encryptedData);
	//	//var publicKey = rsa.ToXmlString(false);

	//	return (encryptedMessage, publicKeyXml);
	//}
}
