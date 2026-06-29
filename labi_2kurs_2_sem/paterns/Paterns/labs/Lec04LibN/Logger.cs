using System.Xml.Linq;

namespace Lec04LibN;

public partial class Logger : ILogger
{
	private static Logger? instance = null;

	//private string _logFileName = string.Format(@"../../{0}/Data/LOG{1}.txt", Directory.GetCurrentDirectory(), DateTime.Now.ToString("yyyyMMdd-HH-mm-ss"));

	//private string _fullLogFileName = Path.Combine(Directory.GetCurrentDirectory(), "Data", Instance._logFileName);

	private string _logFileName;
	private string _fullLogFileName;

	private string _dateString = $"{DateTime.Now.ToString("MM-dd-yyyy")} {DateTime.Now.ToString("hh-mm-ss")}";

	private int _id;

	private List<string> _namespacesLogs = new List<string>();

	public Logger()
	{
		_id = 0000;
		_logFileName = $"LOG{DateTime.Now.ToString("yyyyMMdd-HH-mm-ss")}.txt";
		_fullLogFileName = Path.Combine(Directory.GetCurrentDirectory(), "../" ,"../", "../", "Data", _logFileName);
	}

	private static Logger Instance
	{
		get
		{
			if (instance == null)
			{
				instance = new Logger();
			}
			return instance;
		}
	}

	public static Logger create()
	{
		if (instance == null)
		{
			instance = new Logger();
		}
		return instance;
	}

	public void start(string title)
	{
		Instance._id++;
		Instance._namespacesLogs.Add(title);
		wrileLine("STRT", "");
	}

	public void log(string message)
	{
		Instance._id++;
		wrileLine("INFO", message);
	}

	public void stop()
	{

		Instance._id++;

		string removedNamespace = string.Empty;

		if (_namespacesLogs.Count > 0)
		{
			//removedNamespace = _namespacesLogs.Last();

			_namespacesLogs.RemoveAt(_namespacesLogs.Count - 1);

			wrileLine("STOP", "");

			return;
		}

		wrileLine("STOP", "");
	}

	private void wrileLine(string logType, string message)
	{
		string logID = _id.ToString("D6");

		string allNamespaces = string.Empty;

		foreach (string name in Instance._namespacesLogs)
		{
			allNamespaces += $"{name}:";
		}

		string log =  $"{logID}-{Instance._dateString}-{logType} {allNamespaces} {message}";

		writeInFile(logType, message, log);
	}

	private void writeInFile(string logType, string message, string log)
	{
		string logID = _id.ToString("D6");

		if (File.Exists(_fullLogFileName))
		{
			using (StreamWriter sw = File.AppendText(_fullLogFileName))
			{
				sw.WriteLine(log);
			}

			return;
		}

		using (StreamWriter sw = File.AppendText(_fullLogFileName))
		{
			sw.WriteLine($"{logID}-{Instance._dateString} INIT");
		}

		Instance._id++;

		wrileLine(logType, message);
	}
}
