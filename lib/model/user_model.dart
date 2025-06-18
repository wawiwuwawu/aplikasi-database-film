class User {
  final int id;
  final String name;
  final String email;
  final String? password;
  final String role;
  final String? bio;
  final String? profileUrl;
  final String? deleteHash;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role,
    this.bio,
    this.profileUrl,
    this.deleteHash,
    this.createdAt,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? bio,
    String? profileUrl,
    String? deleteHash,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      profileUrl: profileUrl ?? this.profileUrl,
      deleteHash: deleteHash ?? this.deleteHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? '-',
      email: json['email'] as String? ?? '-',
      password: json['password'] as String?,
      role: json['role'] as String? ?? '-',
      bio: json['bio'] as String?,
      profileUrl: json['profile_url'] as String?,
      deleteHash: json['delete_hash'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'bio': bio,
      'profile_url': profileUrl,
      'delete_hash': deleteHash,
      'created_at': createdAt,
    };
  }
}
