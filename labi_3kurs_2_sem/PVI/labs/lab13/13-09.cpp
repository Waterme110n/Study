#include <iostream>
#include <cstring>
#include <arpa/inet.h>
#include <unistd.h>

int main()
{
	int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd < 0)
	{
		std::cerr << "Socket creation failed" << std::endl;
		return 1;
	}

	sockaddr_in servaddr = {0};
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = INADDR_ANY;
	servaddr.sin_port = htons(3000);

	if (bind(sockfd, (const sockaddr *)&servaddr, sizeof(servaddr)) < 0)
	{
		std::cerr << "Bind failed" << std::endl;
		close(sockfd);
		return 1;
	}

	std::cout << "UDP Server listening on port 3000" << std::endl;

	while (true)
	{
		char buffer[1024];
		sockaddr_in cliaddr;
		socklen_t len = sizeof(cliaddr);

		ssize_t n = recvfrom(sockfd, buffer, sizeof(buffer), 0,
							 (sockaddr *)&cliaddr, &len);
		if (n > 0)
		{
			buffer[n] = '\0';
			std::cout << "Received: " << buffer << std::endl;

			std::string echo = "ECHO: " + std::string(buffer);
			sendto(sockfd, echo.c_str(), echo.size(), 0,
				   (const sockaddr *)&cliaddr, len);
		}
	}

	close(sockfd);
	return 0;
}