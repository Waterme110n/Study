abstract class IMessage {
  void sendMessage(String message);
}

class User {
  final String id;
  final String name;
  final String email;
  final String status;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      status: map['status'],
    );
  }
  
  void displayInfo(String additionalInfo) {
    print('Name: $name, Email: $email, Info: $additionalInfo');
  }
}

class MessengerUser extends User implements IMessage {
  static int userCount = 0;

  MessengerUser({required String id, required String name, required String email, required String status})
      : super(id: id, name: name, email: email, status: status) {
    userCount++;
  }

  MessengerUser.withDefaultEmail({required String id, required String name, String email = 'default@example.com', required String status})
      : this(id: id, name: name, email: email, status: status);

  static void displayUserCount() {
    print('Total users: $userCount');
  }

  @override
  void sendMessage(String message) {
    print('$name sent a message: $message');
  }

  @override
  void displayInfo(String additionalInfo) {
    print('Name: $name, Email: $email, Status: $status, Info: $additionalInfo');
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