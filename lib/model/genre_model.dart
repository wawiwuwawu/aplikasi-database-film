class Genre {
  final int id;
  final String nama;

  Genre({
    required this.id,
    required this.nama,
  });

  // Factory constructor untuk parsing dari JSON
  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      nama: json['nama'],
    );
  }

  // Method untuk konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}