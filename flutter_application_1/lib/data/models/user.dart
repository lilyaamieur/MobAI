class UserModel {
  final int id;
  final DateTime createdAt;
  final String userName;
  final String bio;

  UserModel({
    required this.id,
    required this.createdAt,
    required this.userName,
    required this.bio,
  });

  // Convert Supabase JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'],
      bio: json['bio'],
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
      'bio': bio,
    };
  }
}
