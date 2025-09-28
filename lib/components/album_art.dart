import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apollo/models/songs.dart';
import 'package:apollo/themes/theme_provider.dart';

class AlbumArt extends StatelessWidget {
  final Song song;
  final double size;

  const AlbumArt({super.key, required this.song, this.size = 150});

  @override
  Widget build(BuildContext context) {
    final path = song.albumArtImagePath;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    ImageProvider? provider;

    if (path.isEmpty) return _defaultIcon(isDark);
    if (path.startsWith('/') || path.startsWith('file://')) {
      provider = FileImage(File(path.replaceFirst('file://', '')));
    } else if (path.startsWith('http')) {
      provider = NetworkImage(path);
    } else {
      provider = AssetImage(path);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.black87 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.white.withOpacity(0.03), Colors.black.withOpacity(0.05)]
              : [Colors.white.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: provider,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _defaultIcon(isDark),
            ),
            // subtle shine overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent
                        ]
                      : [
                          Colors.white.withOpacity(0.3),
                          Colors.transparent
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultIcon(bool isDark) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? Colors.black87 : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.music_note,
          size: size * 0.5,
          color: isDark ? Colors.grey[400] : Colors.grey[700],
        ),
      );
}
