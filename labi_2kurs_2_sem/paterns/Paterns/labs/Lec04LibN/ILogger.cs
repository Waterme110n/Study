namespace Lec04LibN;

public interface ILogger
{
	void start(string title);
	void log(string message);
	void stop();
}