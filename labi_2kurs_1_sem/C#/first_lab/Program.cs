namespace first_lab;

class Program
{

    

    static void Main(string[] args)
    {

       
        Variables variables = new Variables();
        Strings strings = new Strings();
        Arrays arrays = new Arrays();
        Tuples tuples = new Tuples();

        Console.WriteLine("Input task:");
        string masterChoice =  Console.ReadLine();

        switch (masterChoice) {
            case "1":

                Console.WriteLine("Input subtask:");

                string slaveChoiceVariables = Console.ReadLine();

                switch (slaveChoiceVariables)
                {
                    case "a":
                        variables.pointA();
                        break;

                    case "b":
                        variables.pointB();

                        break;

                    case "c":
                        variables.pointC();

                        break;

                    case "d":
                        variables.pointD();

                        break;

                    case "e":
                        variables.pointE();

                        break;

                }



                break;

            case "2":

                string slaveChoiceStrings = Console.ReadLine();

                switch (slaveChoiceStrings)
                {
                    case "a":
                        strings.pointA();
                        break;

                    case "b":
                        strings.pointB();
                        break;

                    case "c":
                        strings.pointC();
                        break;

                    case "d":
                        strings.pointD();
                        break;


                }

                break;


            case "3":


                string slaveChoiceArrays = Console.ReadLine();

                switch (slaveChoiceArrays)
                {
                    case "a":
                        arrays.pointA();
                        break;

                    case "b":
                        arrays.pointB();
                        break;

                    case "c":
                        arrays.pointC();
                        break;

                    case "d":
                        arrays.pointD();
                        break;


                }

                break;

            case "4":

                string slaveChoiceTuples = Console.ReadLine();

                switch (slaveChoiceTuples)
                {
                    case "a":
                        tuples.pointA();
                        break;

                    case "b":
                        tuples.pointB();
                        break;

                    case "c":
                        tuples.pointC();
                        break;

                }

                break;

        }














    }

}

