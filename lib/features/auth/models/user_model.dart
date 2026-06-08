class UserModel {
  final int id;
  final String name;
  final String email;
  final List<String> interests;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.interests,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      interests: List<String>.from(json['interests'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'interests': interests,
  };
}