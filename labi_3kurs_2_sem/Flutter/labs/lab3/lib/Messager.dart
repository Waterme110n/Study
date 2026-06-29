import 'dart:convert';
import 'dart:async';

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

mixin MessageSender {
  void sendMessage(String message) {
    print('Sending message: $message');
  }
}

class MessengerUser extends User with MessageSender implements IMessage,Comparable<MessengerUser>  {
  @override
  int compareTo(MessengerUser other) {
    return name.compareTo(other.name);
  }

  String toJson() {
    return jsonEncode({
      'name': name,
      'email': email,
    });
  }

  Future<void> sendMessageAsync(String message) async {
    await Future.delayed(Duration(seconds: 1));
    sendMessage(message);
  }

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

class UserIterator implements Iterator<User?> {
  final List<User> _users;
  int _index = -1;

  UserIterator(this._users);

  @override
  User? get current => (_index >= 0 && _index < _users.length) ? _users[_index] : null;

  @override
  bool moveNext() {
    if (_index + 1 < _users.length) {
      _index++;
      return true;
    }
    return false;
  }
}

class UserCollection implements Iterable<MessengerUser> {
  final List<MessengerUser> users;

  UserCollection(this.users);

  @override
  Iterator<MessengerUser> get iterator => users.iterator;

  @override
  int get length => users.length;

  @override
  bool get isEmpty => users.isEmpty;

  @override
  bool get isNotEmpty => users.isNotEmpty;

  @override
  MessengerUser get first => users.first;

  @override
  MessengerUser get last => users.last;

  MessengerUser get single {
    if (users.length != 1) {
      throw StateError('There must be exactly one element.');
    }
    return users.first;
  }

  @override
  MessengerUser elementAt(int index) => users.elementAt(index);

  @override
  bool any(bool Function(MessengerUser element) test) => users.any(test);

  @override
  bool contains(Object? element) => users.contains(element);

  @override
  Iterable<R> map<R>(R Function(MessengerUser e) toElement) => users.map(toElement);

  @override
  void forEach(void Function(MessengerUser element) f) => users.forEach(f);

  @override
  Iterable<MessengerUser> where(bool Function(MessengerUser element) test) => users.where(test);

  @override
  Iterable<R> expand<R>(Iterable<R> Function(MessengerUser element) f) => users.expand(f);

  @override
  bool every(bool Function(MessengerUser element) test) => users.every(test);

  @override
  MessengerUser firstWhere(bool Function(MessengerUser element) test, {MessengerUser Function()? orElse}) {
    return users.firstWhere(test, orElse: orElse);
  }

  @override
  MessengerUser lastWhere(bool Function(MessengerUser element) test, {MessengerUser Function()? orElse}) {
    return users.lastWhere(test, orElse: orElse);
  }

  @override
  MessengerUser singleWhere(bool Function(MessengerUser element) test, {MessengerUser Function()? orElse}) {
    return users.singleWhere(test, orElse: orElse);
  }

  @override
  void addAll(Iterable<MessengerUser> iterable) => users.addAll(iterable);

  @override
  List<MessengerUser> toList({bool growable = true}) => users.toList(growable: growable);

  @override
  Set<MessengerUser> toSet() => users.toSet();

  @override
  String join([String separator = '']) => users.map((user) => user.name).join(separator);

  @override
  Iterable<MessengerUser> followedBy(Iterable<MessengerUser> other) => users.followedBy(other);

  @override
  R fold<R>(R initialValue, R Function(R previous, MessengerUser element) combine) {
    return users.fold(initialValue, combine);
  }

  @override
  MessengerUser reduce(MessengerUser Function(MessengerUser previous, MessengerUser element) combine) {
    return users.reduce(combine);
  }

  @override
  Iterable<MessengerUser> get reversed => users.reversed;

  @override
  Iterable<MessengerUser> skip(int count) => users.skip(count);

  @override
  Iterable<MessengerUser> take(int count) => users.take(count);

  @override
  Iterable<MessengerUser> skipWhile(bool Function(MessengerUser element) test) => users.skipWhile(test);

  @override
  Iterable<MessengerUser> takeWhile(bool Function(MessengerUser element) test) => users.takeWhile(test);

  @override
  Iterable<T> cast<T>() => users.cast<T>();

  @override
  Iterable<T> whereType<T>() => users.whereType<T>();
}

class MessageStream {
  final StreamController<String> _broadcastController = StreamController<String>.broadcast();
  final StreamController<String> _singleSubscriptionController = StreamController<String>();

  void sendMessage(String message) {
    _broadcastController.add(message);
    _singleSubscriptionController.add(message);
  }

  Stream<String> get broadcastStream => _broadcastController.stream;

  Stream<String> get singleSubscriptionStream => _singleSubscriptionController.stream;

  void close() {
    _broadcastController.close();
    _singleSubscriptionController.close();
  }
}
void runStreamDemo() {
  final messageStream = MessageStream();

  // Подписка на Broadcast Stream
  messageStream.broadcastStream.listen((message) {
    print('Broadcast Received: $message');
  });

  // Подписка на Single Subscription Stream
  messageStream.singleSubscriptionStream.listen((message) {
    print('Single Subscription Received: $message');
  });

  messageStream.sendMessage('Hello from the stream!');

  messageStream.close();
}

void runAsyncDemo() async {
  MessengerUser user = MessengerUser('Alice', 'alice@example.com');
  await user.sendMessageAsync('Hello, World!');
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