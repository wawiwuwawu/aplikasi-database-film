class Seiyu {
  final int id;
  final String name;
  final String? birthday;
  final String? bio;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? twitterUrl;
  final String? youtubeUrl;
  final String? profileUrl;
  final List<KarakterSeiyu> karakters;
  final List<MovieSeiyu> movies;

  Seiyu({
    required this.id,
    required this.name,
    this.birthday,
    this.bio,
    this.websiteUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.youtubeUrl,
    this.profileUrl,
    this.karakters = const [],
    this.movies = const [],
  });

  Seiyu copyWith({
    int? id,
    String? name,
    String? birthday,
    String? bio,
    String? websiteUrl,
    String? instagramUrl,
    String? twitterUrl,
    String? youtubeUrl,
    String? profileUrl,
  }) {
    return Seiyu(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      bio: bio ?? this.bio,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }

  factory Seiyu.fromJson(Map<String, dynamic> json) {
    return Seiyu(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      birthday: json['birthday'] as String?,
      bio: json['bio'] as String?,
      websiteUrl: json['website_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      profileUrl: json['profile_url'] as String?,
      karakters: (json['karakters'] as List<dynamic>?)
          ?.map((k) => KarakterSeiyu.fromJson(k as Map<String, dynamic>))
          .toList() ?? [],
      movies: (json['movies'] as List<dynamic>?)
          ?.map((m) => MovieSeiyu.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class KarakterSeiyu {
  final int id;
  final String nama;
  final String? bio;
  final String? profileUrl;

  KarakterSeiyu({
    required this.id,
    required this.nama,
    this.bio,
    this.profileUrl,
  });

  factory KarakterSeiyu.fromJson(Map<String, dynamic> json) {
    return KarakterSeiyu(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      nama: json['nama'] as String? ?? 'Unknown',
      bio: json['bio'] as String?,
      profileUrl: json['profile_url'] as String?,
    );
  }
}

class MovieSeiyu {
  final int id;
  final String judul;
  final String? sinopsis;
  final int? tahunRilis;
  final String? type;
  final int? episode;
  final int? durasi;
  final String? rating;
  final String? coverUrl;

  MovieSeiyu({
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

  factory MovieSeiyu.fromJson(Map<String, dynamic> json) {
    return MovieSeiyu(
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