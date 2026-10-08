class UserModel {
  const UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.contactNumber,
    required this.username,
    required this.email,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final int age;
  final String contactNumber;
  final String username;
  final String email;

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] as String? ?? '',
    firstName: map['firstName'] as String? ?? '',
    lastName: map['lastName'] as String? ?? '',
    age: (map['age'] as num?)?.toInt() ?? 0,
    contactNumber: map['contactNumber'] as String? ?? '',
    username: map['username'] as String? ?? '',
    email: map['email'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'firstName': firstName,
    'lastName': lastName,
    'age': age,
    'contactNumber': contactNumber,
    'username': username,
    'email': email,
  };
}
