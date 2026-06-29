#pragma warning(disable:4996)
#include <iostream>

using namespace std;

bool CheckAddress(char* ip_)
{
    int points = 0;
    int numbers = 0;
    char* buff;
    buff = new char[3];

    for (int i = 0; ip_[i] != '\0'; i++)
    {
        if (ip_[i] <= '9' && ip_[i] >= '0')
        {
            if (numbers > 3)
                return false;
            buff[numbers++] = ip_[i];
        }
        else
        {
            if (ip_[i] == '.')
            {
                if (atoi(buff) > 255)
                    return false;
                if (numbers == 0)
                    return false;
                numbers = 0;
                points++;
                delete[] buff;
                buff = new char[3];
            }
            else
                return false;
        }
    }
    if (points != 3)
        return false;
    if (numbers == 0 || numbers > 3)
        return false;
    return true;
}

int main()
{
    setlocale(LC_CTYPE, "Russian");
    char* ip_;
    bool flag = true;
    ip_ = new char[16];

    do
    {
        if (!flag) cout << "Неверно введён адрес!" << endl;
        cout << "IP: ";
        cin >> ip_;
    } while (!(flag = CheckAddress(ip_)));

    cout << "IP адрес корректен." << endl;

    return 0;
}