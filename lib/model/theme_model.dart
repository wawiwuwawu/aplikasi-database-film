class Theme {
  final int id;
  final String nama;

  Theme({
    required this.id,
    required this.nama,
  });

  // Factory constructor untuk parsing dari JSON
  factory Theme.fromJson(Map<String, dynamic> json) {
    return Theme(
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