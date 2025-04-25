class Movie {
  final int id;
  final String judul;
  final String sinopsis;
  final int tahunRilis;
  final String thema;
  final String genre;
  final String studio;
  final String type;
  final int episode;
  final int durasi;
  final String rating;
  final String coverUrl;

  Movie({
    required this.id,
    required this.judul,
    required this.sinopsis,
    required this.tahunRilis,
    required this.thema,
    required this.genre,
    required this.studio,
    required this.type,
    required this.episode,
    required this.durasi,
    required this.rating,
    required this.coverUrl,
  });

  Movie copyWith({
    int? id,
    String? judul,
    String? sinopsis,
    int? tahunRilis,
    String? thema,
    String? genre,
    String? studio,
    String? type,
    int? episode,
    int? durasi,
    String? rating,
    String? coverUrl,
  }) {
    return Movie(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      sinopsis: sinopsis ?? this.sinopsis,
      tahunRilis: tahunRilis ?? this.tahunRilis,
      thema: thema ?? this.thema,
      genre: genre ?? this.genre,
      studio: studio ?? this.studio,
      type: type ?? this.type,
      episode: episode ?? this.episode,
      durasi: durasi ?? this.durasi,
      rating: rating ?? this.rating,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      judul: json['judul'],
      sinopsis: json['sinopsis'],
      tahunRilis: json['tahun_rilis'],
      thema: json['thema'],
      genre: json['genre'],
      studio: json['studio'],
      type: json['type'],
      episode: json['episode'],
      durasi: json['durasi'],
      rating: json['rating'],
      coverUrl: json['cover_url'],
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      totalPages: json['total_pages'],
      totalItems: json['total_items'],
      itemsPerPage: json['items_per_page'],
    );
  }
}

class MovieResponse {
  final List<Movie> movies;
  final Pagination pagination;

  MovieResponse({
    required this.movies,
    required this.pagination,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      movies: (json['movies'] as List)
          .map((e) => Movie.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}