using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

using Lab5Lib.Abstraction;

namespace Lab5Lib.Decorator;
public class DecMD5 : Decorator
{
	public DecMD5(IWriter? writer) : base(writer)
	{
	}
	public override string? Save(string? message)
	{
		byte[] hash = CalculateSHA512(message);


		string result = $"{message}{Constant.Delimiter}{Convert.ToBase64String(hash)}";

		return result;
	}
	private byte[] CalculateSHA512(string? message)
	{
		using SHA512 sha512 = SHA512.Create();
		byte[] data = Encoding.ASCII.GetBytes(message ?? string.Empty);
		return sha512.ComputeHash(data);
	}
	//public override string? Save(string? message) //формирование сообщения
	//{
	//	if (message != null)
	//	{
	//		// Вычисляем хеш-код сообщения с помощью sha512
	//		byte[] hash = SHA512.Create().ComputeHash(Encoding.UTF8.GetBytes(message));

	//		// Преобразуем хеш-код в строку и добавляем его к сообщению
	//		string hashedMessage = message + Constant.Delimiter + Convert.ToBase64String(hash);

	//		// Сохраняем зашифрованное сообщение с помощью декорируемого объекта-писателя
	//		return _writer?.Save(hashedMessage);
	//	}
	//	return null;
	//}

	//public override string? Save(string? message)
	//{
	//	string hashedMessage = ComputeSHA512Hash(message);

	//	string msg = $"{message}{Constant.Delimiter}{hashedMessage}";

	//	return _writer?.Save(msg);
	//}

	//private string ComputeSHA512Hash(string? message)
	//{
	//	if (message == null)
	//		return string.Empty;

	//	using SHA512 sha512 = SHA512.Create();

	//	byte[] messageBytes = Encoding.UTF8.GetBytes(message);
	//	byte[] hashBytes = sha512.ComputeHash(messageBytes);
	//	return Convert.ToBase64String(hashBytes);
	//}
}
