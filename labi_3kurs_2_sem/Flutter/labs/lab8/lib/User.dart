import 'package:hive/hive.dart';

part 'User.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String username;

  @HiveField(1)
  String role;

  User(this.username, this.role);

  void changeRole() {
    role = (role == 'admin') ? 'user' : 'admin';
    print(role);
  }
}