using System;
using System.Collections.Generic;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            List<char> Alphabet = new List<char> { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
                'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' };
            List<char> LeftRotor = new List<char> { 'E', 'S', 'O', 'V', 'P', 'Z', 'J', 'A', 'Y', 'Q', 'U', 'I',
                'R', 'H', 'X', 'L', 'N', 'F', 'T', 'G', 'K', 'D', 'C', 'M', 'W', 'B' };
            List<char> MeadleRotor = new List<char> { 'B', 'D', 'F', 'H', 'J', 'L', 'C', 'P', 'R', 'T', 'X', 'V',
                'Z', 'N', 'Y', 'E', 'I', 'W', 'G', 'A', 'K', 'M', 'U', 'S', 'Q', 'O' };
            List<char> RightRotor = new List<char> { 'A', 'J', 'D', 'K', 'S', 'I', 'R', 'U', 'X', 'B', 'L', 'H', 'W',
                'T', 'M', 'C', 'Q', 'G', 'Z', 'N', 'P', 'Y', 'F', 'V', 'O', 'E' };
            List<char> Reflector = new List<char> { 'A', 'R', 'B', 'D', 'C', 'O', 'E', 'J',
                'F', 'N', 'G', 'T', 'H', 'K', 'I', 'V', 'L', 'M', 'P', 'W', 'Q', 'Z', 'S', 'X', 'U', 'Y' };

            string text = "PODREZ";
            string encode = "";
            int[] position=new int[3];
            string[] read = Console.ReadLine().Split(',');

            for (int i = 0; i < read.Length; i++)
            {
                position[i] = Int32.Parse(read[i]);
            }

            for (int i = 0; i < text.Length; i++)
            {
                char saveChar;
                int saveIndex;
                saveIndex = Alphabet.IndexOf(text[i]);
                saveIndex = Alphabet.IndexOf(RightRotor[(saveIndex + position[3]) % Alphabet.Count]);
                saveIndex = Alphabet.IndexOf(MeadleRotor[(saveIndex + position[0]) % Alphabet.Count]);
                saveIndex = Alphabet.IndexOf(LeftRotor[(saveIndex + position[0]) % Alphabet.Count]);
                saveIndex = Reflector.IndexOf(Alphabet[saveIndex]);
                if (saveIndex % 2 == 0)
                    saveChar = Reflector[++saveIndex];
                else
                    saveChar = Reflector[--saveIndex];

                saveIndex = Alphabet.IndexOf(Reflector[saveIndex]);
                saveIndex = LeftRotor.IndexOf(Alphabet[(saveIndex + position[4]) % Alphabet.Count]);
                saveIndex = MeadleRotor.IndexOf(Alphabet[(saveIndex + position[0]) % Alphabet.Count]);
                saveIndex = RightRotor.IndexOf(Alphabet[(saveIndex + position[0]) % Alphabet.Count]);

                encode += Alphabet[saveIndex];

                position[2]++;
                if (position[2] == 26)
                {
                    position[2] = 0;
                    position[1]++;
                }
                if (position[1] == 26)
                {
                    position[1] = 0;
                    position[0]++;
                }
            }
            Console.WriteLine(encode);
        }
    }
}
