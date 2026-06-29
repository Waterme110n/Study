#include <iostream>
#include <cstring>
#include <unistd.h>
#include <arpa/inet.h>

int main()
{
	int server_fd = socket(AF_INET, SOCK_STREAM, 0);
	sockaddr_in addr = {AF_INET, htons(3000), INADDR_ANY};
	bind(server_fd, (sockaddr *)&addr, sizeof(addr));
	listen(server_fd, 5);

	while (true)
	{
		sockaddr_in client_addr;
		socklen_t len = sizeof(client_addr);
		int client_fd = accept(server_fd, (sockaddr *)&client_addr, &len);
		char buffer[1024] = {0};
		read(client_fd, buffer, 1024);
		std::string echo = "ECHO: " + std::string(buffer);
		send(client_fd, echo.c_str(), echo.size(), 0);
		close(client_fd);
	}
	close(server_fd);
	return 0;
}