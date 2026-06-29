abstract class IMessage {
  void sendMessage(String message);
}

abstract class User {
  String name;
  String email;

  User(this.name, this.email);

  void displayInfo(String additionalInfo) {
    print('Name: $name, Email: $email, Info: $additionalInfo');
  }
}

class MessengerUser extends User implements IMessage {
  static int userCount = 0;

  static void displayUserCount() {
    print('Total users: $userCount');
  }

  MessengerUser(String name, String email) : super(name, email) {
    userCount++;
  }

  MessengerUser.withDefaultEmail(String name) : this(name, 'default@example.com');

  String get userName => name;

  set userName(String newName) {
    name = newName;
  }

  String get userEmail => email;

  set userEmail(String newEmail) {
    email = newEmail;
  }

  @override
  void sendMessage(String message) {
    print('$name sent a message: $message');
  }

  @override
  void displayInfo(String additionalInfo) {
    print('Name: $name, Email: $email');
  }

  void sendMessageWithTag({required String message, String tag = 'General'}) {
    print('[$tag] $name: $message');
  }

  void sendMessageWithCallback(String message, Function callback) {
    sendMessage(message);
    callback();
  }

  void sendMessageOptional(String message, [String? optionalTag]) {
    if (optionalTag != null) {
      print('[$optionalTag] $name: $message');
    } else {
      print('$name: $message');
    }
  }
}

void runMessengerLogic() {
  List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  print('Array of numbers: $numbers');

  Map<String, String> userMap = {
    'Alice': 'alice@example.com',
    'Bob': 'bob@example.com',
    'Charlie': 'charlie@example.com',
  };
  print('User Map: $userMap');

  Set<String> userSet = {'Alice', 'Bob', 'Charlie', 'Alice'};
  print('Users: $userSet');


  print('больше 5:');
  for (int number in numbers) {
    if (number < 5) {
      continue;
    }
    if (number > 10) {
      break;
    }
    print(number);
  }


  try {
    int result = divide(10, 3);
    print('результат: $result');
  } catch (e) {
    print('   $e');
  }
}

int divide(int a, int b) {
  if (b == 0) {
    throw Exception('на ноль делить нельзя');
  }
  return a ~/ b;
}