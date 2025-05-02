class Staff {
  final int id;
  final String name;
  final String birthday;
  final String role;
  final String bio;
  final String profileUrl;
  final List<MovieStaff> movies;

  Staff({
    required this.id,
    required this.name,
    required this.birthday,
    required this.role,
    required this.bio,
    required this.profileUrl,
    required this.movies,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      birthday: json['birthday'],
      role: json['role'],
      bio: json['bio'],
      profileUrl: json['profile_url'],
      movies: (json['movies'] as List)
          .map((movie) => MovieStaff.fromJson(movie))
          .toList(),
    );
  }
}

class MovieStaff {
  final int id;
  final String judul;
  final String sinopsis;
  final int tahunRilis;
  final String type;
  final int episode;
  final int durasi;
  final String rating;
  final String coverUrl;

  MovieStaff({
    required this.id,
    required this.judul,
    required this.sinopsis,
    required this.tahunRilis,
    required this.type,
    required this.episode,
    required this.durasi,
    required this.rating,
    required this.coverUrl,
  });

  factory MovieStaff.fromJson(Map<String, dynamic> json) {
    return MovieStaff(
      id: json['id'],
      judul: json['judul'],
      sinopsis: json['sinopsis'],
      tahunRilis: json['tahun_rilis'],
      type: json['type'],
      episode: json['episode'],
      durasi: json['durasi'],
      rating: json['rating'],
      coverUrl: json['cover_url'],
    );
  }
}