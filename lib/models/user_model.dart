class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? token;
  final String? profileImage; // <-- store URL

  UserModel({
    this.id,
    this.name,
    this.email,
    this.token,
    this.profileImage, // URL now
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'],
    name: map['name'],
    email: map['email'],
    token: map['token'],
    profileImage: map['profileImage'],
  );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
