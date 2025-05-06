class Staff {
  final int id;
  final String name;
  final String? birthday;
  final String role;
  final String? bio;
  final String? profileUrl;
  final List<MovieStaff> movies;

  Staff({
    required this.id,
    required this.name,
    this.birthday,
    required this.role,
    this.bio,
    this.profileUrl,
    this.movies = const [],
  });

  Staff copyWith({
    int? id,
    String? name,
    String? birthday,
    String? role,
    String? bio,
    String? profileUrl,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      birthday: json['birthday'] as String?,
      role: json['role'] as String? ?? 'Staff',
      bio: json['bio'] as String?,
      profileUrl: json['profile_url'] as String?,
      movies: (json['movies'] as List<dynamic>?)
          ?.map((m) => MovieStaff.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class MovieStaff {
  final int id;
  final String judul;
  final String? sinopsis;
  final int? tahunRilis;
  final String? type;
  final int? episode;
  final int? durasi;
  final String? rating;
  final String? coverUrl;

  MovieStaff({
    required this.id,
    required this.judul,
    this.sinopsis,
    this.tahunRilis,
    this.type,
    this.episode,
    this.durasi,
    this.rating,
    this.coverUrl,
  });

  factory MovieStaff.fromJson(Map<String, dynamic> json) {
    return MovieStaff(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      judul: json['judul'] as String? ?? 'Untitled',
      sinopsis: json['sinopsis'] as String?,
      tahunRilis: json['tahun_rilis'] is int
          ? json['tahun_rilis'] as int
          : int.tryParse('${json['tahun_rilis']}'),
      type: json['type'] as String?,
      episode: json['episode'] is int
          ? json['episode'] as int
          : int.tryParse('${json['episode']}'),
      durasi: json['durasi'] is int
          ? json['durasi'] as int
          : int.tryParse('${json['durasi']}'),
      rating: json['rating'] as String?,
      coverUrl: json['cover_url'] as String?,
    );
  }
}
