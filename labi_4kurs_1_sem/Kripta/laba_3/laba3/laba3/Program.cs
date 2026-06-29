using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace lab3
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.OutputEncoding = System.Text.Encoding.UTF8;
            Console.InputEncoding = System.Text.Encoding.UTF8;
            var sw = new Stopwatch();

            

            string message = "qwertyuiopasdfghjklzxcvbn";
            Console.WriteLine($"Исходное сообщение: {message}");
            sw.Start();
            string encryptedMessage = SnakePermutationEncryptionOfGerman(message);
            sw.Stop();
            Console.WriteLine($"\nЗашифрованное сообщение: {encryptedMessage}");
            sw.Restart();
            Console.WriteLine($"Время потраченное на шифрование в миллисекундах: {sw.ElapsedMilliseconds}\n");
            string decryptedMessage = SnakePermutationDecryptionOfGerman(encryptedMessage);
            sw.Stop();
            Console.WriteLine($"\nРасшифрованное сообщение: {decryptedMessage}");
            Console.WriteLine($"Время потраченное на расшифрование в миллисекундах: {sw.ElapsedMilliseconds}\n\n");

            Console.WriteLine("_________________________________________________________________________________");

            string firstKey = "pavel";
            string secondKey = "osadc";
            Console.WriteLine($"Исходное сообщение: {message}");
            Console.WriteLine($"Первый ключ = {firstKey}, второй ключ = {secondKey}");
            sw.Restart();
            string encryptedMessageByMultiplePermutation = MultiplePermutationEncryptionOfGerman(message, firstKey, secondKey);
            sw.Stop();
            Console.WriteLine($"\nЗашифрованное сообщение множественной перестановкой: {encryptedMessageByMultiplePermutation}");
            sw.Restart();
            Console.WriteLine($"Время потраченное на шифрование в миллисекундах: {sw.ElapsedMilliseconds}\n");
            string decryptedMessageByMultiplePermutation = MultiplePermutationDecryptionOfGerman(encryptedMessageByMultiplePermutation, firstKey, secondKey);
            sw.Stop();
            Console.WriteLine($"\nРасшифрованное сообщение множественной перестановкой: {decryptedMessageByMultiplePermutation}");
            Console.WriteLine($"Время потраченное на расшифрование в миллисекундах: {sw.ElapsedMilliseconds}\n\n");


            Console.WriteLine("\n\nЧастотные характеристики исходного сообщения:");
            MessageFrequencyCalculation(message);
            Console.WriteLine("Частотные характеристики зашифрованного сообщения методом маршрутной перестановки(змейкой):");
            MessageFrequencyCalculation(encryptedMessage);
            Console.WriteLine("Частотные характеристики зашифрованного сообщения методом множественной перестановки:");
            MessageFrequencyCalculation(encryptedMessageByMultiplePermutation);

            Console.ReadLine();
        }

        public static string SnakePermutationEncryptionOfGerman(string message)
        {
            string encryptedMessage = "";
            char[,] matrix = new char[5,5];
            const int n = 5;
            string[] arr = new string[n * n];

            for (int i = 0; i < n; i++)
            {
                for(int j = 0; j < n;j++)
                {
                    matrix[i, j] = message[i * n + j];
                }
            }

            Console.WriteLine("\nМатрица:");
            for (int i = 0; i < n; i++)
            {
                
                for (int j = 0; j < n; j++)
                {
                    Console.Write(matrix[i, j] + " ");
                }
                Console.WriteLine();
            }

            int k, lim;
            k = 0;

            for (int i = 0; i < 2 * n; ++i)
            {
                lim = i >= n ? n - 1 : i;

                if (i % 2 == 0)
                    for (int j = lim; j >= i - lim; --j)
                        arr[k++] += matrix[i - j, j];

                else
                    for (int j = i - lim; j <= lim; ++j)
                        arr[k++] += matrix[i - j, j];
            }

            for (int i = 0; i < n * n; ++i)
            {
                encryptedMessage += arr[i];
            }

            return encryptedMessage;
        }

        public static string SnakePermutationDecryptionOfGerman(string encryptedMessage)
        {
            string decryptedMessage = "";
            char[,] matrix = new char[5, 5];
            string[] temp = new string[9];

            int position = 0;
            for(int i = 1; i <= temp.Length; i++)
            {
                if(i <= 5)
                {
                    temp[i - 1] = encryptedMessage.Substring(position, i);
                    position += i;
                }
                if(i > 5 && i <= 9)
                {
                    temp[i - 1] = encryptedMessage.Substring(position, i - (i % 5) - (i % 5));
                    position += i - (i % 5) - (i % 5);
                }
            }

            //foreach (var x in temp)
            //    Console.Write(x + "|");

            matrix[0, 0] = temp[0][0];//1
            matrix[4, 4] = temp[8][0];
            matrix[0, 1] = temp[1][1];//2
            matrix[1, 0] = temp[1][0];
            matrix[3, 4] = temp[7][1];
            matrix[4, 3] = temp[7][0];
            matrix[0, 2] = temp[2][0];//3
            matrix[1, 1] = temp[2][1];
            matrix[2, 0] = temp[2][2];
            matrix[2, 4] = temp[6][0];
            matrix[3, 3] = temp[6][1];
            matrix[4, 2] = temp[6][2];
            matrix[0, 3] = temp[3][3];//4
            matrix[1, 2] = temp[3][2];
            matrix[2, 1] = temp[3][1];
            matrix[3, 0] = temp[3][0];
            matrix[1, 4] = temp[5][3];
            matrix[2, 3] = temp[5][2];
            matrix[3, 2] = temp[5][1];
            matrix[4, 1] = temp[5][0];
            matrix[0, 4] = temp[4][0];//5
            matrix[1, 3] = temp[4][1];
            matrix[2, 2] = temp[4][2];
            matrix[3, 1] = temp[4][3];
            matrix[4, 0] = temp[4][4];

            for(int i = 0; i < 5; i++)
            {
                for(int j = 0; j < 5; j++)
                {
                    decryptedMessage += matrix[i, j];
                }
            }

            return decryptedMessage;
        }



        static List<CharNum> listCharNumFirst;
        static List<CharNum> listCharNumSecond;
        public static string MultiplePermutationEncryptionOfGerman(string message, string firstKey, string secondKey)
        {
            string fill = " ";

            for (int i = message.Length; i < firstKey.Length * secondKey.Length; i++)
            {
                message += fill;
            }
            string newText = "";
            // Матрица в которой производим шифрование
            char[,] matrix = new char[secondKey.Length, firstKey.Length];

            // Счетчик символов в строке
            int countSymbols = 0;

            // Переводим строки в массивы типа char
            char[] charsFirstKey = firstKey.ToCharArray();
            char[] charsSecondKey = secondKey.ToCharArray();
            char[] charStringUser = message.ToCharArray();

            // Создаем списки в которых будут храниться символы и порядковые номера символов
            listCharNumFirst =
                new List<CharNum>(firstKey.Length);

            listCharNumSecond =
                new List<CharNum>(secondKey.Length);

            // Заполняем символами из ключей
            listCharNumFirst = FillListKey(charsFirstKey);
            listCharNumSecond = FillListKey(charsSecondKey);

            // Заполняем порядковыми номерами
            listCharNumFirst = FillingSerialsNumber(listCharNumFirst);
            listCharNumSecond = FillingSerialsNumber(listCharNumSecond);

            // Заполнение матрицы строкой пользователя
            for (int i = 0; i < listCharNumSecond.Count; i++)
            {
                for (int j = 0; j < listCharNumFirst.Count; j++)
                {
                    matrix[i, j] = charStringUser[countSymbols++];
                }
            }

            Console.WriteLine("Мтарица:");
            for (int i = 0; i < listCharNumSecond.Count; i++)
            {
                for (int j = 0; j < listCharNumFirst.Count; j++)
                {
                    Console.Write(matrix[i, j] + " ");
                }
                Console.WriteLine();
            }


            countSymbols = 0;
            // Заполнение матрицы с учетом шифрования. 
            // Переставляем столбцы по порядку следования в первом ключе. 
            // Затем переставляем строки по порядку следования во втором ключа. 
            for (int i = 0; i < listCharNumSecond.Count; i++)
            {
                for (int j = 0; j < listCharNumFirst.Count; j++)
                {
                    matrix[listCharNumSecond[i].NumberInWord,
                       listCharNumFirst[j].NumberInWord] = charStringUser[countSymbols++];
                }
            }

            for (int i = 0; i < listCharNumFirst.Count; i++)
            {
                for (int j = 0; j < listCharNumSecond.Count; j++)
                {
                    newText += matrix[j, i];
                }
            }
            //return newText;
            return newText;
        }

        public static string MultiplePermutationDecryptionOfGerman(string encryptedMessage, string firstKey, string secondKey)
        {
            char[,] newMatrix = new char[secondKey.Length, firstKey.Length];
            List<int> list1 = new List<int>();
            List<int> list2 = new List<int>();
            foreach (CharNum index in listCharNumFirst)
            {
                list1.Add(index.NumberInWord);
            }
            foreach (CharNum index in listCharNumSecond)
            {
                list2.Add(index.NumberInWord);
            }
            int k = 0;


            encryptedMessage += " ";
            for (int i = 0; i < firstKey.Length; i++)
            {
                int x = list1.IndexOf(i);
                for (int j = 0; j < secondKey.Length; j++)
                {
                    int y = list2.IndexOf(j);
                    //Console.WriteLine("'" + encryptedMessage[k] + "'");
                    newMatrix[y, x] = encryptedMessage[k];
                    k++;
                }
            }

            string oldText = "";

            for (int i = 0; i < secondKey.Length; i++)
            {
                for (int j = 0; j < firstKey.Length; j++)
                {
                    oldText += newMatrix[i, j];
                }
            }

            return oldText;
        }

        public static int GetNumberInThealphabet(char s)
        {
            string str = @"AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz";

            int number = str.IndexOf(s) / 2;

            return number;
        }

        
        private static List<CharNum> FillListKey(char[] chars)
        {
            List<CharNum> listKey = new List<CharNum>(chars.Length);

            for (int i = 0; i < chars.Length; i++)
            {
                CharNum charNum = new CharNum()
                {
                    Ch = chars[i],
                    NumberInWord = GetNumberInThealphabet(chars[i])
                };

                listKey.Add(charNum);
            }
            return listKey;
        }

        /// Заполнение символов ключей, порядковыми номерами.
        private static List<CharNum> FillingSerialsNumber(List<CharNum> listCharNum)
        {
            int count = 0;

            var result = listCharNum.OrderBy(a =>
                a.NumberInWord);

            foreach (var i in result)
            {
                i.NumberInWord = count++;
            }

            return listCharNum;
        }
        class CharNum
        {
            #region Fields
            /// <summary>
            /// Символ.
            /// </summary>
            private char _ch;
            /// <summary>
            /// Порядковый номер зависящий от алфавита.
            /// </summary>
            private int _numberInWord;
            #endregion Fieds

            #region Properties
            /// Символ.
            public char Ch
            {
                get { return _ch; }
                set
                {
                    if (_ch == value)
                        return;
                    _ch = value;
                }
            }
            /// Порядковый номер в строке, зависящий от алфавита.
            public int NumberInWord
            {
                get { return _numberInWord; }
                set
                {
                    if (_numberInWord == value)
                        return;
                    _numberInWord = value;
                }
            }
            #endregion Properties
        }

        public static void MessageFrequencyCalculation(string str)
        {
            var res = str
                .GroupBy(c => c)
                .ToDictionary(g => g.Key, g => g.Count());
            //foreach (var ch in res)
            //{
            //    Console.WriteLine("'" + ch.Key + "'" + " : " + ch.Value);
            //}
            //Console.WriteLine();
            foreach (var ch in res)
            {
                Console.Write("'" + ch.Key + "'" + " : ");
                for (int i = 0; i < ch.Value; i++)
                {
                    Console.Write("*");
                }
                Console.WriteLine();
            }
        }
    }
}
