#pragma warning(disable:4996)
#include <iostream>
#include <conio.h>

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

unsigned long CharToLong(char* ip_)
{
    unsigned long out = 0, tmp = 0;
    int m = 24;
    char* buff = new char[3];
    for (int i = 0, k = 0; ip_[i] != '\0'; i++)
    {
        if (ip_[i] == '.')
        {
            tmp = (unsigned long)atoi(buff);
            out = out | (tmp << m);
            m -= 8;
            k = 0;
            tmp = 0;
            delete buff;
            buff = new char[3];
        }
        else if (ip_[i + 1] == '\0')
        {
            buff[k++] = ip_[i];
            tmp = (unsigned long)atoi(buff);
            out = out | (tmp << m);
            m -= 8;
            k = 0;
            tmp = 0;
            delete buff;
            buff = new char[3];
        }
        else
        {
            buff[k++] = ip_[i];
        }
    }
    return out;
}

void LongToString(unsigned long ip, char* out)
{
    unsigned long mask = 4278190080;
    unsigned long tmp = 0;
    int m = 24;
    char* buff[4];
    for (int i = 0; i < 4; i++)
    {
        buff[i] = new char[3];
        tmp = (ip & mask) >> m;
        sprintf(buff[i], "%d", tmp);
        strcat(out, buff[i]);
        if (i < 3)
            strcat(out, ".");

        tmp = 0;
        if (i < 3)
            m -= 8;
        mask >>= 8;
    }
    strcat(out, "\0");
}

bool CheckMask(unsigned long mask)
{
    int m = 1, temp = 0, count = 0, a = mask, check = 0;
    for (int i = 0; i < 32; i++)
    {
        temp = a & m;
        if (temp == 1)
            count++;
        a >>= 1;
    }
    for (int i = 0; i < count; i++)
    {
        check = (check | 1) << 1;
    }
    check <<= 32 - count - 1;
    return (check == mask);
}

int main()
{
    setlocale(LC_CTYPE, "Russian");
    unsigned long ip, mask, host, subnet, broadcast;
    char* ip_, * mask_, host_[256] = "", subnet_[256] = "", broadcast_[256] = "";
    bool flag = true;
    ip_ = new char[16];
    mask_ = new char[16];
    do
    {
        if (!flag) cout << "Неверно введён адрес!" << endl;
        cout << "IP: ";
        cin >> ip_;
    } while (!(flag = CheckAddress(ip_)));
    ip = CharToLong(ip_);
    flag = true;
    do
    {
        if (!flag) cout << "Неверно введена маска!" << endl;
        cout << "Маска: ";
        cin >> mask_;
    } while (!(flag = (CheckAddress(mask_) && CheckMask(CharToLong(mask_)))));
    mask = CharToLong(mask_);

    subnet = ip & mask;
    host = ip & ~mask;
    broadcast = ip & mask | ~mask;

    LongToString(subnet, subnet_);
    LongToString(host, host_);
    LongToString(broadcast, broadcast_);

    printf("ID сети: %s\n", subnet_);
    printf("ID хоста: % s\n", host_);
    printf("Широковещательный адрес: %s\n", broadcast_);

    return 0;
}