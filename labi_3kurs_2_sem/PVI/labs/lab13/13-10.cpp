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
	servaddr.sin_port = htons(3000);
	inet_pton(AF_INET, "127.0.0.1", &servaddr.sin_addr);

	const char *message = "Hello UDP Server from C++";
	sendto(sockfd, message, strlen(message), 0,
		   (const sockaddr *)&servaddr, sizeof(servaddr));
	std::cout << "Message sent: " << message << std::endl;

	char buffer[1024];
	socklen_t len = sizeof(servaddr);
	ssize_t n = recvfrom(sockfd, buffer, sizeof(buffer), 0,
						 (sockaddr *)&servaddr, &len);
	if (n > 0)
	{
		buffer[n] = '\0';
		std::cout << "Server response: " << buffer << std::endl;
	}

	close(sockfd);
	return 0;
}