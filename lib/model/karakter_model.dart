class Karakter {
  final int id;
  final String nama;
  final String? bio;
  final String profileUrl;
  final List<SeiyuKarakter> seiyus;
  final List<MovieKarakter> movies;

  Karakter({
    required this.id,
    required this.nama,
    this.bio,
    required this.profileUrl,
    required this.seiyus,
    required this.movies,
  });

  factory Karakter.fromJson(Map<String, dynamic> json) {
    return Karakter(
      id: json['id'],
      nama: json['nama'],
      bio: json['bio'],
      profileUrl: json['profile_url'],
      seiyus: (json['seiyus'] as List)
          .map((s) => SeiyuKarakter.fromJson(s))
          .toList(),
      movies: (json['movies'] as List)
          .map((m) => MovieKarakter.fromJson(m))
          .toList(),
    );
  }
}

class SeiyuKarakter {
  final int id;
  final String name;
  final String birthday;
  final String bio;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? twitterUrl;
  final String? youtubeUrl;
  final String profileUrl;

  SeiyuKarakter({
    required this.id,
    required this.name,
    required this.birthday,
    required this.bio,
    this.websiteUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.youtubeUrl,
    required this.profileUrl,
  });

  factory SeiyuKarakter.fromJson(Map<String, dynamic> json) {
    return SeiyuKarakter(
      id: json['id'],
      name: json['name'],
      birthday: json['birthday'],
      bio: json['bio'],
      websiteUrl: json['website_url'],
      instagramUrl: json['instagram_url'],
      twitterUrl: json['twitter_url'],
      youtubeUrl: json['youtube_url'],
      profileUrl: json['profile_url'],
    );
  }
}

class MovieKarakter {
  final int id;
  final String judul;
  final String sinopsis;
  final int tahunRilis;
  final String type;
  final int episode;
  final int durasi;
  final String rating;
  final String coverUrl;

  MovieKarakter({
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

  factory MovieKarakter.fromJson(Map<String, dynamic> json) {
    return MovieKarakter(
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