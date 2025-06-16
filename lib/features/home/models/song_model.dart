import 'dart:convert';

class SongModel {
  final String id;
  final String song_name;
  final String artist;
  final String thumbnail_url;
  final String song_url;
  final String hex_code;//color code
  final String lyrics;
  final String genre;  // Added genre field 
  //happy, sad, angry, etc.

  SongModel({
    required this.id,
    required this.song_name,
    required this.artist,
    required this.thumbnail_url,
    required this.song_url,
    required this.hex_code,
    required this.lyrics,
    required this.genre,  // Added genre parameter
  });

  SongModel copyWith({
    String? id,
    String? song_name,
    String? artist,
    String? thumbnail_url,
    String? song_url,
    String? hex_code,
    String? lyrics,
    String? genre,  // Added genre parameter
  }) {
    return SongModel(
      id: id ?? this.id,
      song_name: song_name ?? this.song_name,
      artist: artist ?? this.artist,
      thumbnail_url: thumbnail_url ?? this.thumbnail_url,
      song_url: song_url ?? this.song_url,
      hex_code: hex_code ?? this.hex_code,
      lyrics: lyrics ?? this.lyrics,
      genre: genre ?? this.genre,  // Set genre if provided
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'song_name': song_name,
      'artist': artist,
      'thumbnail_url': thumbnail_url,
      'song_url': song_url,
      'hex_code': hex_code,
      'lyrics': lyrics,
      'genre': genre,  // Added genre to the map
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] ?? '',
      song_name: map['song_name'] ?? '',
      artist: map['artist'] ?? '',
      thumbnail_url: map['thumbnail_url'] ?? '',
      song_url: map['song_url'] ?? '',
      hex_code: map['hex_code'] ?? '',
      lyrics: map['lyrics'] ?? 'Lyrics not available',
      genre: map['genre'] ?? '',  // Set genre from map
    );
  }

  String toJson() => json.encode(toMap());

  factory SongModel.fromJson(String source) =>
      SongModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SongModel(id: $id, song_name: $song_name, artist: $artist, thumbnail_url: $thumbnail_url, song_url: $song_url, hex_code: $hex_code, lyrics: ${lyrics.substring(0, lyrics.length > 30 ? 30 : lyrics.length)}..., genre: $genre)';
  }

  @override
  bool operator ==(covariant SongModel other) {
    return other.id == id &&
        other.song_name == song_name &&
        other.artist == artist &&
        other.thumbnail_url == thumbnail_url &&
        other.song_url == song_url &&
        other.hex_code == hex_code &&
        other.lyrics == lyrics &&
        other.genre == genre;  // Compare genre
  }

  @override
  int get hashCode {
    return id.hashCode ^
        song_name.hashCode ^
        artist.hashCode ^
        thumbnail_url.hashCode ^
        song_url.hashCode ^
        hex_code.hashCode ^
        lyrics.hashCode ^
        genre.hashCode;  // Include genre in hashCode
  }
}
