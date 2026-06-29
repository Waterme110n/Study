using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Lab6Lib.Abstraction;
public interface ISubscriber //интерфейс подписчика
{
    void update(string eventname);
}
