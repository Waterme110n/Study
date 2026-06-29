#include <iostream>
#include <cstring>
#include <arpa/inet.h>
#include <unistd.h>

int main()
{
	// Создание сокета
	int sock = socket(AF_INET, SOCK_STREAM, 0);
	if (sock < 0)
	{
		std::cerr << "Socket creation failed" << std::endl;
		return 1;
	}

	// Настройка адреса сервера
	sockaddr_in addr;
	addr.sin_family = AF_INET;
	addr.sin_port = htons(3000);
	inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);

	// Подключение к серверу
	if (connect(sock, (sockaddr *)&addr, sizeof(addr)) < 0)
	{
		std::cerr << "Connection failed" << std::endl;
		close(sock);
		return 1;
	}

	// Отправка сообщения
	const char *message = "Hello from C++";
	if (send(sock, message, strlen(message), 0) < 0)
	{
		std::cerr << "Send failed" << std::endl;
	}

	// Получение ответа
	char buffer[1024] = {0};
	ssize_t bytes_read = read(sock, buffer, sizeof(buffer));
	if (bytes_read > 0)
	{
		std::cout << "Server: " << buffer << std::endl;
	}
	else
	{
		std::cerr << "Read failed or connection closed" << std::endl;
	}

	// Закрытие сокета
	close(sock);
	return 0;
}