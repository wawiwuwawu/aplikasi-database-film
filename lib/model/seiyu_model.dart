class Seiyu {
  final int id;
  final String name;
  final String birthday;
  final String bio;
  final String websiteUrl;
  final String instagramUrl;
  final String twitterUrl;
  final String youtubeUrl;
  final String profileUrl;
  final List<KarakterSeiyu> karakters;
  final List<MovieSeiyu> movies;

  Seiyu({
    required this.id,
    required this.name,
    required this.birthday,
    required this.bio,
    required this.websiteUrl,
    required this.instagramUrl,
    required this.twitterUrl,
    required this.youtubeUrl,
    required this.profileUrl,
    required this.karakters,
    required this.movies,
  });

  factory Seiyu.fromJson(Map<String, dynamic> json) {
    return Seiyu(
      id: json['id'],
      name: json['name'],
      birthday: json['birthday'],
      bio: json['bio'],
      websiteUrl: json['website_url'],
      instagramUrl: json['instagram_url'],
      twitterUrl: json['twitter_url'],
      youtubeUrl: json['youtube_url'],
      profileUrl: json['profile_url'],
      karakters: (json['karakters'] as List)
          .map((k) => KarakterSeiyu.fromJson(k))
          .toList(),
      movies: (json['movies'] as List)
          .map((m) => MovieSeiyu.fromJson(m))
          .toList(),
    );
  }
}

class KarakterSeiyu {
  final int id;
  final String nama;
  final String bio;
  final String profileUrl;

  KarakterSeiyu({
    required this.id,
    required this.nama,
    required this.bio,
    required this.profileUrl,
  });

  factory KarakterSeiyu.fromJson(Map<String, dynamic> json) {
    return KarakterSeiyu(
      id: json['id'],
      nama: json['nama'],
      bio: json['bio'],
      profileUrl: json['profile_url'],
    );
  }
}

class MovieSeiyu {
  final int id;
  final String judul;
  final String sinopsis;
  final int tahunRilis;
  final String type;
  final int episode;
  final int durasi;
  final String rating;
  final String coverUrl;

  MovieSeiyu({
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

  factory MovieSeiyu.fromJson(Map<String, dynamic> json) {
    return MovieSeiyu(
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