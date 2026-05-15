class User {
  final String uid;

  User({required this.uid});
}

class UserData {
  final String uid;
  final String name;
  final String gender;
  final int age;
  final double weight;
  final double height;

  UserData({
    required this.uid,
    required this.name,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
  });
}
