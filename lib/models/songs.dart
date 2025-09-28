class Song {
  final String songName;
  final String artistName;
  final String albumArtImagePath; // can be asset path or file path/URL
  final String audioPath;          // asset path or device file path

  Song({
    required this.songName,
    required this.artistName,
    required this.albumArtImagePath,
    required this.audioPath,
  });

  Map<String, dynamic> toJson() => {
        'songName': songName,
        'artistName': artistName,
        'albumArtImagePath': albumArtImagePath,
        'audioPath': audioPath,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        songName: json['songName'] as String,
        artistName: json['artistName'] as String,
        albumArtImagePath: json['albumArtImagePath'] as String,
        audioPath: json['audioPath'] as String,
      );
}