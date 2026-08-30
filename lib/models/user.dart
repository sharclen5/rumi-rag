class User {
  final String uid;

  User({required this.uid});
}

class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String phone;
  final String gender;
  final String email;
  final String? photoUrl;
  final String role;

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.gender,
    required this.email,
    this.photoUrl,
    this.role = 'user',
  });
}
