import 'dart:io';
import 'package:flutter/material.dart';
import 'package:apollo/models/songs.dart';

class AlbumArt extends StatelessWidget {
  final Song song;
  final double size;

  const AlbumArt({super.key, required this.song, this.size = 150});

  @override
  Widget build(BuildContext context) {
    final path = song.albumArtImagePath;

    if (path.isEmpty) {
      // no path → show default
      return _defaultIcon();
    }

    ImageProvider? provider;

    if (path.startsWith('/') || path.startsWith('file://')) {
      // imported file
      provider = FileImage(File(path.replaceFirst('file://', '')));
    } else if (path.startsWith('http')) {
      // remote url
      provider = NetworkImage(path);
    } else {
      // asset path
      provider = AssetImage(path);
    }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: provider,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultIcon(),
        ),
      );
  }

  Widget _defaultIcon() => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.music_note,
          size: size * 0.5,
          color: Colors.grey,
        ),
      );
}
