using Lab5Lib;
using Lab5Lib.Abstraction;
using Lab5Lib.Decorator;

using System.Security.Cryptography;
using System.Text;

public class DecSHA512 : Decorator
{
	public DecSHA512(IWriter? writer) : base(writer)
	{
	}
	//public override string? Save(string? message)
	//{
	//	if (message != null)
	//	{
	//		// Вычисляем хеш-код сообщения с помощью MD5
	//		byte[] hash = MD5.Create().ComputeHash(Encoding.UTF8.GetBytes(message));

	//		// Преобразуем хеш-код в строку и добавляем его к сообщению
	//		string hashedMessage = message + Constant.Delimiter + Convert.ToBase64String(hash);

	//		// Сохраняем зашифрованное сообщение с помощью декорируемого объекта-писателя
	//		return _writer?.Save(hashedMessage);
	//	}

	//	return null;
	//}
	public override string? Save(string? message)
	{

		byte[] hash = CalculateMD5(message);

		string result = $"{message}{Constant.Delimiter}{Convert.ToBase64String(hash)}";

		return result;
	}

	private byte[] CalculateMD5(string? message)
	{
		using MD5 md5 = MD5.Create();
		byte[] data = Encoding.ASCII.GetBytes(message ?? string.Empty);
		return md5.ComputeHash(data);
	}
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

	//	using MD5 md5 = MD5.Create();

	//	byte[] messageBytes = Encoding.UTF8.GetBytes(message);
	//	byte[] hashBytes = md5.ComputeHash(messageBytes);
	//	return Convert.ToBase64String(hashBytes);
	//}
}