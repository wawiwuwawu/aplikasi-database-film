class Karakter {
  final int id;
  final String nama;
  final String? bio;
  final String? profileUrl;
  final List<SeiyuKarakter> seiyus;
  final List<MovieKarakter> movies;

  Karakter({
    required this.id,
    required this.nama,
    this.bio,
    this.profileUrl,
    this.seiyus = const [],
    this.movies = const [],
  });

  Karakter copyWith({
    int? id,
    String? nama,
    String? bio,
    String? profileUrl,
  }) {
    return Karakter(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      bio: bio ?? this.bio,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }

  factory Karakter.fromJson(Map<String, dynamic> json) {
    return Karakter(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      nama: json['nama'] as String? ?? 'Nama tidak tersedia',
      bio: json['bio'] as String?,
      profileUrl: json['profile_url'] as String?,
      seiyus: (json['seiyus'] as List<dynamic>?)
          ?.map((s) => SeiyuKarakter.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
      movies: (json['movies'] as List<dynamic>?)
          ?.map((m) => MovieKarakter.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class SeiyuKarakter {
  final int id;
  final String name;
  final String? birthday;
  final String? bio;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? twitterUrl;
  final String? youtubeUrl;
  final String? profileUrl;

  SeiyuKarakter({
    required this.id,
    required this.name,
    this.birthday,
    this.bio,
    this.websiteUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.youtubeUrl,
    this.profileUrl,
  });

  factory SeiyuKarakter.fromJson(Map<String, dynamic> json) {
    return SeiyuKarakter(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      birthday: json['birthday'] as String?,
      bio: json['bio'] as String?,
      websiteUrl: json['website_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      profileUrl: json['profile_url'] as String?,
    );
  }
}

class MovieKarakter {
  final int id;
  final String judul;
  final String? sinopsis;
  final int? tahunRilis;
  final String? type;
  final int? episode;
  final int? durasi;
  final String? rating;
  final String? coverUrl;

  MovieKarakter({
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

  factory MovieKarakter.fromJson(Map<String, dynamic> json) {
    return MovieKarakter(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      judul: json['judul'] as String? ?? 'Untitled',
      sinopsis: json['sinopsis'] as String?,
      tahunRilis: json['tahun_rilis'] is int ? json['tahun_rilis'] as int : int.tryParse('${json['tahun_rilis']}'),
      type: json['type'] as String?,
      episode: json['episode'] is int ? json['episode'] as int : int.tryParse('${json['episode']}'),
      durasi: json['durasi'] is int ? json['durasi'] as int : int.tryParse('${json['durasi']}'),
      rating: json['rating'] as String?,
      coverUrl: json['cover_url'] as String?,
    );
  }
}