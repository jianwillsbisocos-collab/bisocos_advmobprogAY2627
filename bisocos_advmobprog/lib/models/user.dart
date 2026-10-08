class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.phone,
    this.gender = '',
    this.image = '',
    this.accessToken,
  });

  final int id;
  final String username;
  final String email;
  final String firstname;
  final String lastname;
  final String phone;
  final String gender;
  final String image;
  final String? accessToken;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: (json['id'] as num?)?.toInt() ?? 0,
    username: json['username'] as String? ?? '',
    email: json['email'] as String? ?? '',
    firstname:
        json['firstName'] as String? ?? json['firstname'] as String? ?? '',
    lastname: json['lastName'] as String? ?? json['lastname'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    gender: json['gender'] as String? ?? '',
    image: json['image'] as String? ?? '',
    accessToken: json['accessToken'] as String? ?? json['token'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'firstName': firstname,
    'lastName': lastname,
    'phone': phone,
    'gender': gender,
    'image': image,
    if (accessToken != null) 'accessToken': accessToken,
  };
}
