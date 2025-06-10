class Credentials {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? bio;
  final String? profileUrl;
  final String? createdAt;

  Credentials({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.bio,
    this.profileUrl,
    this.createdAt,
  });

  // Konversi dari JSON ke Credentials
  factory Credentials.fromJson(Map<String, dynamic> json) {
    return Credentials(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      role: json['role'],
      bio: json['bio'],
      profileUrl: json['profile_url'],
      createdAt: json['created_at'],
    );
  }

  // Konversi dari Credentials ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'bio': bio,
      'profile_url': profileUrl,
      'created_at': createdAt,
    };
  }
}
