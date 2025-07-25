import 'dart:convert';

class Movie {
  final int id;
  final String judul;
  final String sinopsis;
  final int tahunRilis;
  final String type;
  final int episode;
  final int durasi;
  final String rating;
  final String coverUrl;
  final List<Genre> genres;
  final List<ThemeMovie> themes;
  final List<Staff> staffs;
  final List<Seiyu> seiyus;
  final List<Karakter> karakters;
  final int savedCount;
  final int watchingCount;
  final int finishedCount;

  Movie({
    required this.id,
    required this.judul,
    required this.sinopsis,
    required this.tahunRilis,
    required this.type,
    required this.episode,
    required this.durasi,
    required this.rating,
    required this.coverUrl,
    required this.genres,
    required this.themes,
    required this.staffs,
    required this.seiyus,
    required this.karakters,
    this.savedCount = 0,
    this.watchingCount = 0,
    this.finishedCount = 0,
  });

  Movie copyWith({
    int? id,
    String? judul,
    String? sinopsis,
    int? tahunRilis,
    String? type,
    int? episode,
    int? durasi,
    String? rating,
    String? coverUrl,
    List<Genre>? genres,
    List<ThemeMovie>? themes,
    List<Staff>? staffs,
    List<Seiyu>? seiyus,
    List<Karakter>? karakters,
    int? savedCount,
    int? watchingCount,
    int? finishedCount,
  }) {
    return Movie(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      sinopsis: sinopsis ?? this.sinopsis,
      tahunRilis: tahunRilis ?? this.tahunRilis,
      type: type ?? this.type,
      episode: episode ?? this.episode,
      durasi: durasi ?? this.durasi,
      rating: rating ?? this.rating,
      coverUrl: coverUrl ?? this.coverUrl,
      genres: genres ?? this.genres,
      themes: themes ?? this.themes,
      staffs: staffs ?? this.staffs,
      seiyus: seiyus ?? this.seiyus,
      karakters: karakters ?? this.karakters,
      savedCount: savedCount ?? this.savedCount,
      watchingCount: watchingCount ?? this.watchingCount,
      finishedCount: finishedCount ?? this.finishedCount,
    );
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      sinopsis: json['sinopsis'] ?? '',
      tahunRilis: json['tahun_rilis'] ?? 0,
      type: json['type'] ?? '',
      episode: json['episode'] ?? 0,
      durasi: json['durasi'] ?? 0,
      rating: json['rating'] ?? '',
      coverUrl: json['cover_url'] ?? '',
      genres: (json['genres'] is List)
          ? (json['genres'] as List).map((e) => Genre.fromJson(e)).toList()
          : [],
      themes: (json['themes'] is List)
          ? (json['themes'] as List).map((e) => ThemeMovie.fromJson(e)).toList()
          : [],
      staffs: (json['staffs'] is List)
          ? (json['staffs'] as List).map((e) => Staff.fromJson(e)).toList()
          : [],
      seiyus: (json['seiyus'] is List)
          ? (json['seiyus'] as List).map((e) => Seiyu.fromJson(e)).toList()
          : [],
      karakters: (json['karakters'] is List)
          ? (json['karakters'] as List).map((e) => Karakter.fromJson(e)).toList()
          : [],
      savedCount: json['savedCount'] ?? 0,
      watchingCount: json['watchingCount'] ?? 0,
      finishedCount: json['finishedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'sinopsis': sinopsis,
      'tahun_rilis': tahunRilis,
      'type': type,
      'episode': episode,
      'durasi': durasi,
      'rating': rating,
      'cover_url': coverUrl,
      'genres': genres.map((g) => g.toJson()).toList(),
      'themes': themes.map((t) => t.toJson()).toList(),
      'staffs': staffs.map((s) => s.toJson()).toList(),
      'seiyus': seiyus.map((s) => s.toJson()).toList(),
      'karakters': karakters.map((k) => k.toJson()).toList(),
      'saved_count': savedCount,
      'watching_count': watchingCount,
      'finished_count': finishedCount,
    };
  }

  // Encode a list of Movie objects to a JSON string
  static String encodeList(List<Movie> movies) {
    return jsonEncode(movies.map((m) => m.toJson()).toList());
  }

  // Decode a JSON string to a list of Movie objects
  static List<Movie> decodeList(String moviesJson) {
    if (moviesJson.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(moviesJson);
      return decoded.map((e) => Movie.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}

class Genre {
  final int id;
  final String nama;

  Genre({required this.id, required this.nama});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'], nama: json['nama']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}

class ThemeMovie {
  final int id;
  final String nama;

  ThemeMovie({required this.id, required this.nama});

  factory ThemeMovie.fromJson(Map<String, dynamic> json) {
    return ThemeMovie(id: json['id'], nama: json['nama']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}

class Staff {
  final int id;
  final String name;
  final String role;
  final String profileUrl;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.profileUrl,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      profileUrl: json['profile_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'profile_url': profileUrl,
    };
  }
}

class Seiyu {
  final int id;
  final String name;
  final String profileUrl;
  final List<SeiyuKarakter> karakters;
  final SeiyuMovie seiyuMovie;

  Seiyu({
    required this.id,
    required this.name,
    required this.profileUrl,
    required this.karakters,
    required this.seiyuMovie,
  });

  factory Seiyu.fromJson(Map<String, dynamic> json) {
    return Seiyu(
      id: json['id'],
      name: json['name'],
      profileUrl: json['profile_url'],
      karakters: (json['karakters'] is List)
          ? (json['karakters'] as List).map((k) => SeiyuKarakter.fromJson(k)).toList()
          : [],
      seiyuMovie: json['SeiyuMovie'] != null
          ? SeiyuMovie.fromJson(json['SeiyuMovie'])
          : SeiyuMovie(karakterId: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_url': profileUrl,
      'karakters': karakters.map((k) => k.toJson()).toList(),
      'SeiyuMovie': seiyuMovie.toJson(),
    };
  }
}

class SeiyuKarakter {
  final int id;
  final String nama;

  SeiyuKarakter({required this.id, required this.nama});

  factory SeiyuKarakter.fromJson(Map<String, dynamic> json) {
    return SeiyuKarakter(id: json['id'], nama: json['nama']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}

class SeiyuMovie {
  final int karakterId;

  SeiyuMovie({required this.karakterId});

  factory SeiyuMovie.fromJson(Map<String, dynamic> json) {
    return SeiyuMovie(karakterId: json['karakter_id']);
  }

  Map<String, dynamic> toJson() {
    return {
      'karakter_id': karakterId,
    };
  }
}

class Karakter {
  final int id;
  final String nama;
  final String profileUrl;

  Karakter({required this.id, required this.nama, required this.profileUrl});

  factory Karakter.fromJson(Map<String, dynamic> json) {
    return Karakter(
      id: json['id'],
      nama: json['nama'],
      profileUrl: json['profile_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'profile_url': profileUrl,
    };
  }
}
