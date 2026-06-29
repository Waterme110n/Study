using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Input;

namespace MyApp.Commands
{
    public static class WindowCommands
    {
        static WindowCommands()
        {
            Exit = new RoutedUICommand(
                "Exit", 
                "Exit", 
                typeof(WindowCommands) 
            );
        }

        public static RoutedUICommand Exit { get; set; }
    }
}
