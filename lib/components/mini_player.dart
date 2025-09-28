// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:apollo/components/album_art.dart';
import 'package:apollo/models/playlist_provider.dart';
import 'package:apollo/models/miniplayer_provider.dart'; 
import 'package:apollo/pages/song_page.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlaylistProvider, MiniPlayerProvider>(
      builder: (context, playlistProvider, miniPlayerProvider, child) {
        // Don't show miniplayer if disabled in settings
        if (!miniPlayerProvider.isMiniPlayerEnabled) {
          return const SizedBox.shrink();
        }

        // Don't show miniplayer if no song is selected or playlist is empty
        if (playlistProvider.currentSongIndex == null || 
            playlistProvider.playlist.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentSong = playlistProvider.playlist[playlistProvider.currentSongIndex!];
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Container(
          height: 72,
          // MODIFIED: Increased bottom margin from 8 to 16
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 16), 
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colors.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SongPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Album Art
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AlbumArt(song: currentSong, size: 56),
                    ),
                    const SizedBox(width: 12),
                    
                    // Song Info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong.songName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentSong.artistName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    
                    // Controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Previous Button
                        IconButton(
                          onPressed: playlistProvider.playPreviousSong,
                          icon: const Icon(Icons.skip_previous),
                          iconSize: 24,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        
                        // Play/Pause Button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: playlistProvider.pauseOrResume,
                            icon: Icon(
                              playlistProvider.isPlaying 
                                  ? Icons.pause 
                                  : Icons.play_arrow,
                              color: colors.inversePrimary,
                            ),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        
                        // Next Button  
                        IconButton(
                          onPressed: playlistProvider.playNextSong,
                          icon: const Icon(Icons.skip_next),
                          iconSize: 24,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}