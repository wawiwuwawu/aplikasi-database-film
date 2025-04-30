class Credentials {
  final String id;
  final String name;
  final String email;
  final String role;

  Credentials({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Konversi dari JSON ke Credentials
  factory Credentials.fromJson(Map<String, dynamic> json) {
    return Credentials(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  // Konversi dari Credentials ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
